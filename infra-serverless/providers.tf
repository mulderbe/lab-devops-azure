# providers.tf — la identidad (sp-lab-iac) llega por las variables ARM_* del pipeline.
provider "azurerm" {
  resource_provider_registrations = "none" # se registraron a mano en el Lab 1
  storage_use_azuread             = true

  features {
    storage {
      # Sin esto, Terraform lee propiedades del storage de la Function por el plano de DATOS
      # y sp-lab-iac necesitaría roles de datos de colas y blobs: el plan fallaría con 403.
      # Este stack no usa queue_properties ni static_website, así que no hace falta.
      data_plane_available = false
    }
  }
}
