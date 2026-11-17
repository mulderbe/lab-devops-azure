# outputs.tf — lo que usan el pipeline de la app y los pasos 5 a 8.

output "aks_nombre" {
  value = azurerm_kubernetes_cluster.dev.name
}

output "aks_grupo_nodos" {
  value = azurerm_kubernetes_cluster.dev.node_resource_group
}

output "app_client_id" {
  description = "Client ID de la identidad de la app (va en la ServiceAccount)"
  value       = azurerm_user_assigned_identity.app.client_id
}

output "oidc_issuer_url" {
  value = azurerm_kubernetes_cluster.dev.oidc_issuer_url
}
