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


resource "azurerm_network_security_group" "main" { # NSG and SSH Rule
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
    source_address_prefix      = "foobar"
    destination_address_prefix = "*"
  }

}

module "network" {
  source              = "./modules/network"
  resource-group-name = azurerm_resource_group.main.name
  resource-location   = azurerm_resource_group.main.location
  network_range       = var.network_range
  subnet_range        = var.subnet_range
  pip_allocation      = var.pip_allocation
}

resource "azurerm_subnet_network_security_group_association" "nsg-associationm" { # associate nsg to subnet
  subnet_id                 = module.network.subnet-id
  network_security_group_id = azurerm_network_security_group.main.id
}

resource "tls_private_key" "vm-ssh-key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

data "azurerm_client_config" "current" {}

resource "azurerm_key_vault" "main" {
  name                        = "main-vault${random_string.vm-name.result}"
  location                    = azurerm_resource_group.main.location
  resource_group_name         = azurerm_resource_group.main.name
  enabled_for_disk_encryption = true
  tenant_id                   = data.azurerm_client_config.current.tenant_id
  soft_delete_retention_days  = 7
  purge_protection_enabled    = false
  rbac_authorization_enabled  = false


  sku_name = "standard"

  access_policy {
    tenant_id = data.azurerm_client_config.current.tenant_id
    object_id = data.azurerm_client_config.current.object_id

    key_permissions = [
      "Get",
      "Create",
      "Delete",
      "List",
      "Recover",
      "Restore",
      "UnwrapKey",
      "WrapKey",
      "List"
    ]

    secret_permissions = [
      "Get",
      "List",
      "Set",
      "Delete",
      "Recover",
      "Restore",
      "Purge"
    ]
  }
}

resource "azurerm_key_vault_secret" "ssh_private_key" {
  name         = "ssh-private-key"
  value        = tls_private_key.vm-ssh-key.private_key_openssh
  key_vault_id = azurerm_key_vault.main.id
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
    module.network.network-interface-id
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

module "internal" {
  source                          = "./modules/internal-vm"
  network_range_internal          = var.network_range_internal
  subnet_range_internal           = var.subnet_range_internal
  password                        = var.password
  username                        = var.internal_username
  resource-group-name             = azurerm_resource_group.main.name
  resource-location               = azurerm_resource_group.main.location
  vm_private_ip_address           = module.network.vm_private_ip_address
  internal_web_private_ip_address = module.internal_web.internal_web_ip
}

resource "azurerm_virtual_network_peering" "internal-peer1to2" {
  name                      = "internal-peer1to2"
  resource_group_name       = azurerm_resource_group.main.name
  virtual_network_name      = module.network.vnet_name
  remote_virtual_network_id = module.internal.internal-vnet-id
}

resource "azurerm_virtual_network_peering" "internal-peer2to1" {
  name                      = "internal-peer2to1"
  resource_group_name       = azurerm_resource_group.main.name
  virtual_network_name      = module.internal.internal_vnet_name
  remote_virtual_network_id = module.network.vnet_id
}


module "internal_web" {
  source = "./modules/internal-web"

  resource-group-name = azurerm_resource_group.main.name
  resource-location   = azurerm_resource_group.main.location
  internal_subnet_id  = module.internal.internal_subnet_id
  password            = var.password
}

