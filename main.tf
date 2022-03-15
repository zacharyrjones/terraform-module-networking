provider "aws" {
  region = var.region
}

# VPC
resource "aws_vpc" "main" {
  cidr_block           = var.vpc_cidr_block
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = "${var.resource_name_prefix}-${var.environment}-VPC"
  }
}

# IGW
resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "${var.resource_name_prefix}-${var.environment}-igw"
  }
}

# SUBNETS
resource "aws_subnet" "main" {
  for_each          = var.subnet_info
  vpc_id            = aws_vpc.main.id
  cidr_block        = each.value.cidr
  availability_zone = "${var.region}${each.value.az}"

  tags = {
    Name    = "${var.resource_name_prefix}-${var.environment}-${each.key}"
    Network = each.value.network
  }
  depends_on = [aws_internet_gateway.main]
}

# NATS
resource "aws_nat_gateway" "main" {
  allocation_id = aws_eip.main.id
  subnet_id     = aws_subnet.main[0].id

  tags = {
    Name = "${var.resource_name_prefix}-${var.environment}-nat"
  }
  depends_on = [aws_internet_gateway.main]
}

resource "aws_eip" "main" {
  vpc        = true
  depends_on = [aws_internet_gateway.main]
}

# ROUTE TABLES
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "10.0.0.0/0"
    gateway_id = aws_internet_gateway.main.id
  }

  tags = {
    Name    = "public route table"
    Network = "public"
  }
}

resource "aws_route_table" "private" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block     = "10.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.main.id
  }

  tags = {
    Name    = "private route table"
    Network = "private"
  }
}

resource "aws_route_table_association" "main" {
  for_each       = aws_subnet.main
  subnet_id      = each.value.id
  route_table_id = each.value.tags["Network"] == "Public" ? aws_route_table.public.id : aws_route_table.private.id
}
