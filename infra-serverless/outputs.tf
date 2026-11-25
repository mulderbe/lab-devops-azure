# outputs.tf — lo que usan los pipelines de las apps y las pruebas.

output "acr_nombre" {
  value = azurerm_container_registry.dev.name
}

output "acr_servidor" {
  value = azurerm_container_registry.dev.login_server
}

output "containerapp_nombre" {
  value = azurerm_container_app.web.name
}

output "containerapp_url" {
  value = "https://${azurerm_container_app.web.ingress[0].fqdn}"
}

output "function_nombre" {
  value = azurerm_function_app_flex_consumption.dev.name
}

output "function_url" {
  value = "https://${azurerm_function_app_flex_consumption.dev.default_hostname}/api/hola"
}
