# variables.tf — los valores van en dev.tfvars.

variable "prefijo" {
  description = "Prefijo de todos los nombres"
  type        = string
  default     = "lab"
}

variable "entorno" {
  description = "Nombre del entorno"
  type        = string
  default     = "dev"
}

variable "key_vault_nombre" {
  description = "Nombre del Key Vault que creó el stack base (output key_vault_nombre de infra/)"
  type        = string
}
