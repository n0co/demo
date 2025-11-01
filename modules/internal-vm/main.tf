resource "azurerm_virtual_network" "internal" { # vnet
  name                = "internal-vnet"
  address_space       = var.network_range_internal
  location            = var.resource-location
  resource_group_name = var.resource-group-name
}

resource "azurerm_subnet" "internal" { # vm subnet
  name                 = "internal-subnet"
  resource_group_name  = var.resource-group-name
  virtual_network_name = azurerm_virtual_network.internal.name
  address_prefixes     = var.subnet_range_internal
}

resource "azurerm_network_security_group" "internal" { # NSG and SSH Rule
  name                = "internal-nsg"
  location            = var.resource-location
  resource_group_name = var.resource-group-name

  security_rule {
    name                       = "Internal-Access"
    priority                   = 1001
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "*"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "${var.vm_private_ip_address}"
    destination_address_prefix = "*"
  }

}

resource "azurerm_subnet_network_security_group_association" "internal-nsg-association" { # associate nsg to subnet
  subnet_id                 = azurerm_subnet.internal.id
  network_security_group_id = azurerm_network_security_group.internal.id
}

resource "azurerm_network_interface" "internal" {
  name                = "internal-nic"
  location            = var.resource-location
  resource_group_name = var.resource-group-name

  ip_configuration {
    name                          = "internal-nic"
    subnet_id                     = azurerm_subnet.internal.id
    private_ip_address_allocation = "Dynamic"
  }
}

resource "azurerm_linux_virtual_machine" "internal-vm" {
  name                = "internal-linux-machine"
  resource_group_name = var.resource-group-name
  location            = var.resource-location
  size                = var.vmsize
  admin_username      = var.username
  admin_password      = var.password
  disable_password_authentication = false
  network_interface_ids = [
    azurerm_network_interface.internal.id
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
