resource "azurerm_network_interface" "internal_web" {
  name                = "internal-web-nic"
  location            = var.resource-location
  resource_group_name = var.resource-group-name

  ip_configuration {
    name                          = "internal-web-nic"
    subnet_id                     = var.internal_subnet_id
    private_ip_address_allocation = "Dynamic"
  }
}

resource "azurerm_linux_virtual_machine" "internal_web-vm" {
  name                = "internal-web-linux-machine"
  resource_group_name = var.resource-group-name
  location            = var.resource-location
  size                = var.vmsize
  admin_username      = var.username
  admin_password      = var.password
  disable_password_authentication = false
  network_interface_ids = [
    azurerm_network_interface.internal_web.id
  ]

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts"
    version   = "latest"
  }
}
