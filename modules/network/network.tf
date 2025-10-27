resource "azurerm_virtual_network" "main" { # vnet
  name                = "main-vnet"
  address_space       = var.network_range
  location            = var.resource-location
  resource_group_name = var.resource-group-name
}

resource "azurerm_subnet" "main" { # vm subnet
  name                 = "main-subnet"
  resource_group_name  = var.resource-group-name
  virtual_network_name = azurerm_virtual_network.main.name
  address_prefixes     = var.subnet_range
}

resource "azurerm_public_ip" "main" { # vm public ip
  name                = "main-pip"
  resource_group_name = var.resource-group-name
  location            = var.resource-location
  allocation_method   = var.pip_allocation

}

resource "azurerm_network_interface" "main" { #  vm NIC
  name                  = "main-nic"
  location              = var.resource-location
  resource_group_name   = var.resource-group-name
  ip_forwarding_enabled = false

  ip_configuration {
    name                          = "vm-IP"
    subnet_id                     = azurerm_subnet.main.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.main.id
  }
}