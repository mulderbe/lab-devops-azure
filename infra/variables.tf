# variables.tf — los datos que cambian entre entornos. Sus valores van en dev.tfvars.

variable "location" {
  description = "Región de Azure (Lab 1, Hoja de datos fila 3)"
  type        = string
  default     = "eastus"
}

variable "prefijo" {
  description = "Prefijo de todos los nombres"
  type        = string
  default     = "lab"
}

variable "entorno" {
  description = "Nombre del entorno: dev, qa, prod..."
  type        = string
  default     = "dev"
}

variable "admin_object_id" {
  description = "Tu Id. de objeto en Entra ID (Lab 1, fila 11). Recibe permiso de lectura de secretos para verlos en el portal"
  type        = string
}

variable "address_space" {
  description = "Rango de la red virtual. Alcanza para las subnets de los Labs 2, 4 y 5"
  type        = list(string)
  default     = ["10.10.0.0/16"]
}

variable "snet_vm_prefix" {
  description = "Rango de la subnet de la VM"
  type        = string
  default     = "10.10.1.0/24"
}

variable "vm_enabled" {
  description = "Interruptor: true crea la VM (cuesta por hora); false la omite"
  type        = bool
  default     = true
}

variable "vm_size" {
  description = "Tamaño de la VM (Lab 1, fila 4)"
  type        = string
  default     = "Standard_B2ats_v2"
}

variable "admin_username" {
  description = "Usuario administrador de la VM"
  type        = string
  default     = "azureuser"
}
