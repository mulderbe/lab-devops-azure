terraform {
  backend "azurerm" {
    resource_group_name  = "rg-lab-tfstate"
    storage_account_name = "stlabtfstate1111ccc" # el nombre de tu storage (Hoja de datos, fila 5)
    container_name       = "tfstate"
    key                  = "dev.tfstate" # nombre del archivo de state del entorno dev
    use_azuread_auth     = true          # entra con Entra ID (rol C del Lab 1), no con clave
  }
}
