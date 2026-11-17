# providers.tf — la identidad (sp-lab-iac) llega por las variables ARM_* del pipeline.
provider "azurerm" {
  resource_provider_registrations = "none" # se registran a mano en el Paso 0
  storage_use_azuread             = true
  features {}
}
