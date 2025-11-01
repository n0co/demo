variable "resource_location" {
  type = string
}

variable "subscription_id" {
  type = string
}

variable "username" {
  description = "Username for Virtual Machines"
  default     = "azureuser"
}

variable "vmsize" {
  description = "Size of the VMs"
  default     = "Standard_F2"
}
variable "network_range" {
  type = list(any)
}

variable "subnet_range" {
  type = list(any)
}

variable "pip_allocation" {
  type    = string
  default = "Static"
}

variable "password" {
  description = "Password for Virtual Machines"
  type        = string
  sensitive   = true
}
variable "network_range_internal" {
  type = list(any)
}

variable "subnet_range_internal" {
  type = list(any)
}
variable "internal_username" {
  description = "Username for Internal Virtual Machines"
  default     = "kage"
}