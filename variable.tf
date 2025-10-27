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
  type = list
}

variable "subnet_range" {
  type = list
}

variable "pip_allocation" {
  type = string
  default = "Static"
}