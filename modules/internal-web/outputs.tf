output "internal_web_ip" {
  value = azurerm_network_interface.internal_web.private_ip_address
}
