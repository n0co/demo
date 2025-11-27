output "internal-vnet-id" {
  value = azurerm_virtual_network.internal.id
}
output "internal-ip" {
  value = azurerm_network_interface.internal.private_ip_address
}
output "internal_vnet_name" {
  value = azurerm_virtual_network.internal.name
}
output "internal_subnet_id" {
  value = azurerm_subnet.internal.id
}