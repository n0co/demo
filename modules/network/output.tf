output "subnet-id" {
  value = azurerm_subnet.main.id
}
output "network-interface-id" {
  value = azurerm_network_interface.main.id
}

output "vm-pip" {
  value = azurerm_public_ip.main.ip_address
}
output "vnet_name" {
  value = azurerm_virtual_network.main.name
}
output "vm_private_ip_address" {
  value = azurerm_network_interface.main.private_ip_address
}
output "vnet_id" {
  value = azurerm_virtual_network.main.id
}