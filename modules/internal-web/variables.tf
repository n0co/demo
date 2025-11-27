variable "username" {
  description = "Username for Virtual Machines"
  default     = "kageweb"
}
variable "password" {
  description = "Password for Virtual Machines"
  type        = string
  sensitive   = true
}

variable "vmsize" {
  description = "Size of the VMs"
  default     = "Standard_F2"
}


variable "resource-group-name" {
  type = string
}

variable "resource-location" {
  type = string
}

variable "internal_subnet_id" {
  type = string
}
