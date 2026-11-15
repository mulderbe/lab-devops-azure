# main.tf — piezas comunes: nombres, etiquetas, quién soy y el grupo de recursos.

locals {
  nombre = "${var.prefijo}-${var.entorno}" # lab-dev

  tags = {
    proyecto       = "lab-devops" # igual que en el Lab 1
    entorno        = var.entorno
    gestionado-por = "terraform"
  }
}

# Datos de la identidad con la que corre Terraform (sp-lab-iac): tenant y Id. de objeto.
data "azurerm_client_config" "actual" {}

# 4 caracteres al azar para nombres que deben ser únicos en todo Azure (el Key Vault).
resource "random_string" "sufijo" {
  length  = 4
  upper   = false
  special = false
}

resource "azurerm_resource_group" "dev" {
  name     = "rg-${local.nombre}" # rg-lab-dev
  location = var.location
  tags     = local.tags
}
