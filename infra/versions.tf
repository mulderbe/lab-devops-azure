# versions.tf — qué versión de Terraform y qué providers usa el proyecto.
# Se declaran aquí los 4 providers de todo el Lab 2 para hacer "terraform init" una sola vez.

terraform {
  required_version = ">= 1.16.5"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.40" # cualquier 4.x desde la 4.40; nunca salta a la 5.0 sola
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.6"
    }
    tls = {
      version = "~> 4.0"
    }
    time = {
      source  = "hashicorp/time"
      version = "~> 0.12"
    }
  }
}
