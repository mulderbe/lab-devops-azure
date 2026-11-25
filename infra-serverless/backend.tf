# backend.tf — mismo storage de los labs anteriores, pero OTRO archivo de state.
# Así el Lab 5 se crea y se borra sin tocar el stack base (infra/) ni el de AKS (infra-aks/).
terraform {
  backend "azurerm" {
    resource_group_name  = "rg-lab-tfstate"
    storage_account_name = "stlabtfstate1111ccc" # el mismo de infra/backend.tf
    container_name       = "tfstate"
    key                  = "dev-serverless.tfstate" # infra/ usa dev.tfstate; infra-aks/, dev-aks.tfstate
    use_azuread_auth     = true
  }
}
