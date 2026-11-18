# access.tf — quién puede usar kubectl en el clúster (plano de datos de Kubernetes).

# Tú, desde tu PC.
resource "azurerm_role_assignment" "aks_admin" {
  scope                = azurerm_kubernetes_cluster.dev.id
  role_definition_name = "Azure Kubernetes Service RBAC Cluster Admin"
  principal_id         = var.admin_object_id
}

# sp-lab-iac, para que el pipeline de la app (Paso 6) despliegue.
# Lab: administrador de todo el clúster. Producción: "RBAC Writer" solo en su namespace.
resource "azurerm_role_assignment" "aks_pipeline" {
  scope                = azurerm_kubernetes_cluster.dev.id
  role_definition_name = "Azure Kubernetes Service RBAC Cluster Admin"
  principal_id         = data.azurerm_client_config.actual.object_id
}
