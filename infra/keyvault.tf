# keyvault.tf — Key Vault en modo RBAC, sus permisos, sus secretos y sus logs.

resource "azurerm_key_vault" "dev" {
  name                       = "kv-${local.nombre}-${random_string.sufijo.result}" # p. ej. kv-lab-dev-a1b2
  location                   = azurerm_resource_group.dev.location
  resource_group_name        = azurerm_resource_group.dev.name
  tenant_id                  = data.azurerm_client_config.actual.tenant_id
  sku_name                   = "standard"
  rbac_authorization_enabled = true  # permisos con roles de Azure, no con directivas de acceso
  soft_delete_retention_days = 7     # lo mínimo que permite Azure
  purge_protection_enabled   = false # Lab. Producción: true (nadie puede purgar antes de tiempo)
  tags                       = local.tags

  # Lab: acceso público, protegido por identidad + rol.
  # Producción: public_network_access_enabled = false y un private endpoint.
}

# --- Permisos (plano de datos) ---------------------------------------------------------

# sp-lab-iac podrá crear y borrar secretos. Lo permite la condición del rol B del Lab 1.
resource "azurerm_role_assignment" "kv_terraform" {
  scope                = azurerm_key_vault.dev.id
  role_definition_name = "Key Vault Secrets Officer"
  principal_id         = data.azurerm_client_config.actual.object_id
}

# Tú podrás leer los secretos en el portal (Lab 1, fila 11).
resource "azurerm_role_assignment" "kv_admin_lectura" {
  scope                = azurerm_key_vault.dev.id
  role_definition_name = "Key Vault Secrets User"
  principal_id         = var.admin_object_id
}

# Los roles tardan en propagarse. Sin esta espera, el primer apply suele fallar con 403.
resource "time_sleep" "espera_rbac_kv" {
  create_duration = "90s"
  depends_on      = [azurerm_role_assignment.kv_terraform]
}

# --- Secretos ---------------------------------------------------------------------------

# Clave SSH de la VM, generada por Terraform. Queda en el state en texto plano.
resource "tls_private_key" "vm" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "azurerm_key_vault_secret" "vm_ssh_privada" {
  name         = "vm-ssh-clave-privada"
  value        = tls_private_key.vm.private_key_openssh
  key_vault_id = azurerm_key_vault.dev.id
  content_type = "text/plain"
  depends_on   = [time_sleep.espera_rbac_kv]
}

# Secreto de prueba que leerá la VM con su propia identidad.
resource "azurerm_key_vault_secret" "mensaje" {
  name         = "mensaje-lab"
  value        = "Si lees esto, la identidad administrada de la VM funciona"
  key_vault_id = azurerm_key_vault.dev.id
  depends_on   = [time_sleep.espera_rbac_kv]
}

# --- Logs de auditoría: quién leyó qué secreto y cuándo ---------------------------------

resource "azurerm_monitor_diagnostic_setting" "kv" {
  name                       = "diag-kv-a-law"
  target_resource_id         = azurerm_key_vault.dev.id
  log_analytics_workspace_id = azurerm_log_analytics_workspace.dev.id

  enabled_log {
    category_group = "audit"
  }
}
