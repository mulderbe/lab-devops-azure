# backend.tf — mismo storage del Lab 1, pero OTRO archivo de state.
# Así el clúster tiene su propio state y se puede borrar sin tocar el stack base (infra/).
terraform {
  backend "azurerm" {
    resource_group_name  = "rg-lab-tfstate"
    storage_account_name = "stlabtfstate1111ccc" # el mismo de infra/backend.tf
    container_name       = "tfstate"
    key                  = "dev-aks.tfstate" # infra/ usa dev.tfstate
    use_azuread_auth     = true
  }
}
