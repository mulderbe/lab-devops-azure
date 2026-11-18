# identity.tf — la identidad del plano de control del clúster y su permiso sobre la subnet.

# Identidad asignada por el usuario: existe ANTES que el clúster, así el permiso
# sobre la subnet ya está listo cuando AKS la necesita.
resource "azurerm_user_assigned_identity" "aks" {
  name                = "id-aks-${local.nombre}"
  location            = data.azurerm_resource_group.dev.location
  resource_group_name = data.azurerm_resource_group.dev.name
  tags                = local.tags
}

# AKS necesita unir los nodos a la subnet y crear el balanceador.
# Lo permite la condición del rol B del Lab 1, que amplías en el Paso 0.
resource "azurerm_role_assignment" "aks_red" {
  scope                = azurerm_subnet.aks.id
  role_definition_name = "Network Contributor"
  principal_id         = azurerm_user_assigned_identity.aks.principal_id
}

# Igual que en el Key Vault del Lab 2: los roles tardan en propagarse.
resource "time_sleep" "espera_rbac_red" {
  create_duration = "60s"
  depends_on      = [azurerm_role_assignment.aks_red]
}
