output "subnet-id" {
  value = azurerm_subnet.main.id
}
output "network-interface-id" {
  value = azurerm_network_interface.main.id
}

output "vm-pip" {
  value = azurerm_public_ip.main.ip_address
}