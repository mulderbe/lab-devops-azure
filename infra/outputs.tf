# outputs.tf — datos que Terraform muestra al terminar y que usan las pruebas del Paso 8.

output "grupo_recursos" {
  value = azurerm_resource_group.dev.name
}

output "key_vault_nombre" {
  value = azurerm_key_vault.dev.name
}

output "log_analytics_nombre" {
  value = azurerm_log_analytics_workspace.dev.name
}

output "vm_nombre" {
  value = one(azurerm_linux_virtual_machine.web[*].name) # null si vm_enabled = false
}

output "vm_ip_privada" {
  value = one(azurerm_network_interface.vm[*].private_ip_address)
}
