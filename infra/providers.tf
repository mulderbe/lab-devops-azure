# providers.tf — cómo se conecta Terraform a Azure.
# La identidad (sp-lab-iac) NO está aquí: llega por las variables de entorno ARM_*
# que carga el script scripts/cargar-identidad.ps1 (en tu PC) o el pipeline (Lab 3).

provider "azurerm" {
  # Los proveedores de recursos ya los registraste en el Lab 1 (Paso 2.3).
  resource_provider_registrations = "none"

  # El storage del state no tiene claves: cualquier operación de datos va por Entra ID.
  storage_use_azuread = true

  features {
    key_vault {
      # Lab: al destruir, purga el Key Vault para poder recrearlo con el mismo nombre.
      # Producción: false, y purge_protection_enabled = true en el Key Vault.
      purge_soft_delete_on_destroy          = true
      recover_soft_deleted_key_vaults       = true
      purge_soft_deleted_secrets_on_destroy = false # el Key Vault entero se purga igual

    }
    resource_group {
      # Si alguien creó algo a mano dentro del grupo, el destroy se detiene en vez de borrarlo.
      prevent_deletion_if_contains_resources = true
    }
  }
}
