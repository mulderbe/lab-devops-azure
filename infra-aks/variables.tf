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

variable "admin_object_id" {
  description = "Tu Id. de objeto en Entra ID (Lab 1, fila 11). Recibe el rol de administrador del clúster"
  type        = string
}

variable "key_vault_nombre" {
  description = "Nombre del Key Vault que creó el stack base (output key_vault_nombre de infra/)"
  type        = string
}

variable "snet_aks_prefix" {
  description = "Rango de la subnet de los nodos. Reservado en infra/network.tf"
  type        = string
  default     = "10.10.16.0/20"
}

variable "node_size" {
  description = "Tamaño del nodo. Debe tener cuota en tu suscripción (Paso 0)"
  type        = string
  default     = "Standard_D2as_v4"
}
