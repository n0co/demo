resource "random_string" "vm-name" {
  length  = 6
  upper   = false
  lower   = true
  numeric = true
  special = false
}

resource "azurerm_resource_group" "main" {
  name     = "vm-resource-group"
  location = var.resource_location # East US
}

resource "azurerm_virtual_network" "main" { # vnet
  name                = "main-vnet"
  address_space       = ["10.10.0.0/24"]
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
}

resource "azurerm_subnet" "main" { # vm subnet
  name                 = "main-subnet"
  resource_group_name  = azurerm_resource_group.main.name
  virtual_network_name = azurerm_virtual_network.main.name
  address_prefixes     = ["10.10.0.0/27"]
}

resource "azurerm_public_ip" "main" { # vm public ip
  name                = "main-pip"
  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location
  allocation_method   = "Static"

}

resource "azurerm_network_interface" "main" { #  vm NIC
  name                  = "main-nic"
  location              = azurerm_resource_group.main.location
  resource_group_name   = azurerm_resource_group.main.name
  ip_forwarding_enabled = false

  ip_configuration {
    name                          = "vm-IP"
    subnet_id                     = azurerm_subnet.main.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.main.id
  }
}


resource "azurerm_network_security_group" "main" { # on prem nsg and SSH rule
  name                = "main-nsg"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name

  security_rule {
    name                       = "SSH-Access"
    priority                   = 1001
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "foo-bar"
    destination_address_prefix = "*"
  }

}

resource "azurerm_subnet_network_security_group_association" "nsg-associationm" { # associate nsg to subnet
  subnet_id                 = azurerm_subnet.main.id
  network_security_group_id = azurerm_network_security_group.main.id
}

resource "tls_private_key" "vm-ssh-key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "local_file" "ssh_key" {
  content  = tls_private_key.vm-ssh-key.private_key_openssh
  filename = "${path.module}/id_rsa_vm.pk"
}


resource "azurerm_linux_virtual_machine" "main-vm" {
  name                = "linux-vm${random_string.vm-name.result}"
  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location
  size                = var.vmsize
  admin_username      = var.username
  network_interface_ids = [
    azurerm_network_interface.main.id
  ]

  admin_ssh_key {
    username   = var.username
    public_key = tls_private_key.vm-ssh-key.public_key_openssh
  }

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

output "ssh-command" {
  value = "ssh ${azurerm_linux_virtual_machine.main-vm.admin_username}@${azurerm_linux_virtual_machine.main-vm.public_ip_address} -i ${local_file.ssh_key.filename} -vv"
}