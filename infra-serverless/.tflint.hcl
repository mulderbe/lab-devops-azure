plugin "terraform" {
  enabled = true
  preset  = "recommended"
}

plugin "azurerm" {
  enabled = true
  version = "0.33.0"
  source  = "github.com/terraform-linters/tflint-ruleset-azurerm"
}
# Lab: el workflow de destroy debe poder borrar todo el stack serverless.
# Produccion: lifecycle { prevent_destroy = true } en el registry y en los datos que no se pueden perder.
rule "azurerm_resources_missing_prevent_destroy" {
  enabled = false
}
