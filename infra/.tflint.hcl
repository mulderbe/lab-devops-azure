plugin "terraform" {
  enabled = true
  preset  = "recommended"
}

plugin "azurerm" {
  enabled = true
  version = "0.33.0"
  source  = "github.com/terraform-linters/tflint-ruleset-azurerm"
}
# Lab: el workflow de destroy debe poder borrar el Key Vault y sus secretos.
# Produccion: lifecycle { prevent_destroy = true } en el Key Vault y en los secretos.
rule "azurerm_resources_missing_prevent_destroy" {
  enabled = false
}
