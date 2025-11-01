variable "resource-group-name" {
  type = string
}

variable "resource-location" {
  type = string
}

variable "network_range" {
  type = list
}

variable "subnet_range" {
  type = list
}

variable "pip_allocation" {
  type = string
  default = "null"
}