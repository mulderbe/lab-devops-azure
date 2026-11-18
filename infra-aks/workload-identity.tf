# workload-identity.tf — la identidad de la app y la confianza con el clúster (Paso 7).

locals {
  app_namespace       = "app"
  app_service_account = "sa-app"
}

resource "azurerm_user_assigned_identity" "app" {
  name                = "id-app-${local.nombre}"
  location            = data.azurerm_resource_group.dev.location
  resource_group_name = data.azurerm_resource_group.dev.name
  tags                = local.tags
}

# "Confía en los tokens que emita ESTE clúster para ESTA cuenta de servicio".
# Es lo mismo que hiciste en el Lab 1 con GitHub (gh-main, gh-pr), pero el emisor es AKS.
resource "azurerm_federated_identity_credential" "app" {
  name                      = "fic-aks-${local.app_namespace}-${local.app_service_account}"
  user_assigned_identity_id = azurerm_user_assigned_identity.app.id
  issuer                    = azurerm_kubernetes_cluster.dev.oidc_issuer_url
  subject                   = "system:serviceaccount:${local.app_namespace}:${local.app_service_account}"
  audience                  = ["api://AzureADTokenExchange"]
}

# Solo lectura de secretos, en ese Key Vault. Permitido por la condición del rol B (Lab 1).
resource "azurerm_role_assignment" "app_kv" {
  scope                = data.azurerm_key_vault.dev.id
  role_definition_name = "Key Vault Secrets User"
  principal_id         = azurerm_user_assigned_identity.app.principal_id
}
