# main.tf — nombres, etiquetas y lo que este stack LEE del stack base (no lo administra).

locals {
  nombre = "${var.prefijo}-${var.entorno}" # lab-dev

  tags = {
    proyecto       = "lab-devops"
    entorno        = var.entorno
    gestionado-por = "terraform"
    stack          = "serverless"
  }
}

data "azurerm_client_config" "actual" {}

# "data" = leer algo que ya existe. Orden: base primero, serverless después (y al revés para borrar).
data "azurerm_resource_group" "dev" {
  name = "rg-${local.nombre}"
}

data "azurerm_key_vault" "dev" {
  name                = var.key_vault_nombre
  resource_group_name = data.azurerm_resource_group.dev.name
}

data "azurerm_log_analytics_workspace" "dev" {
  name                = "law-${local.nombre}"
  resource_group_name = data.azurerm_resource_group.dev.name
}

# 4 caracteres al azar para los nombres que deben ser únicos en todo Azure
# (registry, storage y Function App). Igual que el sufijo del Key Vault en el Lab 2.
resource "random_string" "sufijo" {
  length  = 4
  upper   = false
  special = false
}
