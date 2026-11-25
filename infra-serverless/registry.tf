# registry.tf — Azure Container Registry: el "Docker Hub privado" donde el pipeline deja las imágenes.

resource "azurerm_container_registry" "dev" {
  #checkov:skip=CKV_AZURE_139:Lab - los runners de GitHub estan en internet. Produccion: Premium + private endpoint
  #checkov:skip=CKV_AZURE_163:Lab - el escaneo de vulnerabilidades es de Defender for Containers (con costo)
  #checkov:skip=CKV_AZURE_164:Lab - firma de imagenes solo en Premium. Produccion: imagenes firmadas (Notation)
  #checkov:skip=CKV_AZURE_165:Lab - geo-replicacion solo en Premium
  #checkov:skip=CKV_AZURE_166:Lab - cuarentena de imagenes solo en Premium
  #checkov:skip=CKV_AZURE_167:Lab - politica de retencion solo en Premium
  #checkov:skip=CKV_AZURE_233:Lab - redundancia de zona solo en Premium
  #checkov:skip=CKV_AZURE_237:Lab - endpoints de datos dedicados solo en Premium
  name                = "acr${replace(local.nombre, "-", "")}${random_string.sufijo.result}" # p. ej. acrlabdeva1b2
  location            = data.azurerm_resource_group.dev.location
  resource_group_name = data.azurerm_resource_group.dev.name
  sku                 = "Basic" # el más barato; Premium trae red privada, firma y réplicas
  admin_enabled       = false   # sin usuario y contraseña: solo Entra ID
  tags                = local.tags
}

# sp-lab-iac sube las imágenes desde el pipeline.
# Permitido por la condición del rol B (la amplías con AcrPush en el Paso 0).
resource "azurerm_role_assignment" "acr_push_pipeline" {
  scope                = azurerm_container_registry.dev.id
  role_definition_name = "AcrPush"
  principal_id         = data.azurerm_client_config.actual.object_id
}
