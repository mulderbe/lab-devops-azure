# versions.tf — mismas versiones que infra/, solo los providers que este stack usa.
terraform {
  required_version = ">= 1.16.5"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.40"
    }
    time = {
      source  = "hashicorp/time"
      version = "~> 0.12"
    }
  }
}
