variable "region" {
  type    = string
  default = ""
}

variable "environment" {
  type    = string
  default = ""
}

variable "resource_name_prefix" {
  type        = string
  default     = ""
  description = "Prefix to lead resource name (prefix-environment-resource)"
}

variable "vpc_cidr_block" {
  type    = string
  default = ""
}

variable "subnet_info" {
  type = map(object({
    network = string
    az      = string
    ip      = string
  }))
  default = {
    public-0-a = {
      az      = ""
      ip      = ""
      network = ""
    }
  }
  description = "The first subnet must be the first PUBLIC subnet"
}