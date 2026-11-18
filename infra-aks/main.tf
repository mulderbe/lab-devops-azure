# main.tf — nombres, etiquetas y lo que este stack LEE del stack base (no lo administra).

locals {
  nombre = "${var.prefijo}-${var.entorno}" # lab-dev

  tags = {
    proyecto       = "lab-devops"
    entorno        = var.entorno
    gestionado-por = "terraform"
    stack          = "aks"
  }
}

data "azurerm_client_config" "actual" {}

# "data" = leer algo que ya existe. Si borras infra/, este stack deja de funcionar:
# por eso el orden es siempre base primero, AKS después (y al revés para borrar).
data "azurerm_resource_group" "dev" {
  name = "rg-${local.nombre}"
}

data "azurerm_virtual_network" "dev" {
  name                = "vnet-${local.nombre}"
  resource_group_name = data.azurerm_resource_group.dev.name
}

data "azurerm_key_vault" "dev" {
  name                = var.key_vault_nombre
  resource_group_name = data.azurerm_resource_group.dev.name
}
