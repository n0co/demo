output "resource-group-name" {
  value = azurerm_resource_group.main.name
}

output "resource-location" {
  value = azurerm_resource_group.main.location
}

output "ssh-command" {
  value = "ssh ${azurerm_linux_virtual_machine.main-vm.admin_username}@${module.network.vm-pip} -i ${local_file.ssh_key.filename} -vv"
}