variable "username" {
  description = "Username for Virtual Machines"
  default     = "kage"
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

variable "network_range_internal" {
  type = list
}

variable "subnet_range_internal" {
  type = list
}

variable "resource-group-name" {
  type = string
}

variable "resource-location" {
  type = string
}
variable "vm_private_ip_address" {
  type = string
}
