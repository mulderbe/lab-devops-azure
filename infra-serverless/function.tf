# function.tf — la Azure Function en el plan Flex Consumption.

# Storage propio de la Function: guarda su paquete de código y su estado interno.
resource "azurerm_storage_account" "func" {
  #checkov:skip=CKV2_AZURE_40:Lab - clave compartida por un bug de azurerm con identidad en Flex. Produccion: identidad administrada (via azapi)
  #checkov:skip=CKV2_AZURE_41:Lab - no se generan SAS
  #checkov:skip=CKV2_AZURE_1:Lab - cifrado con clave de Microsoft. Produccion: CMK en Key Vault
  #checkov:skip=CKV2_AZURE_33:Lab - sin private endpoint para no pagar DNS privado. Produccion: obligatorio
  #checkov:skip=CKV_AZURE_59:Lab - la Function sin VNet entra por la red publica. Produccion: VNet + private endpoint
  #checkov:skip=CKV_AZURE_33:Lab - logs de colas: el Lab 6 trata el monitoreo
  #checkov:skip=CKV_AZURE_206:Lab - LRS es suficiente para datos que se recrean
  #checkov:skip=CKV2_AZURE_38:Lab - el paquete se vuelve a subir desde el pipeline; sin soft delete
  #checkov:skip=CKV_AZURE_244:Lab - no se crean usuarios locales
  name                            = "stfunc${replace(local.nombre, "-", "")}${random_string.sufijo.result}" # p. ej. stfunclabdeva1b2
  location                        = data.azurerm_resource_group.dev.location
  resource_group_name             = data.azurerm_resource_group.dev.name
  account_tier                    = "Standard"
  account_replication_type        = "LRS"
  min_tls_version                 = "TLS1_2"
  allow_nested_items_to_be_public = false # nadie lee blobs sin autenticarse
  tags                            = local.tags
}

# Contenedor donde el pipeline deja el .zip con el código.
resource "azurerm_storage_container" "func_codigo" {
  #checkov:skip=CKV2_AZURE_21:Lab - el registro de lecturas del blob es parte del Lab 6
  name                  = "codigo"
  storage_account_id    = azurerm_storage_account.func.id # por el plano de control: no necesita roles de datos
  container_access_type = "private"
}

# FC1 = Flex Consumption. Se paga por ejecución y por memoria-segundo; sin uso, casi cero.
resource "azurerm_service_plan" "func" {
  #checkov:skip=CKV_AZURE_211:Lab - Flex Consumption no tiene tamaños de instancia como un plan dedicado
  #checkov:skip=CKV_AZURE_212:Lab - Flex reparte instancias solo; el minimo de instancias no aplica
  #checkov:skip=CKV_AZURE_225:Lab - redundancia de zona no aplica a este plan en el lab
  name                = "asp-func-${local.nombre}"
  location            = data.azurerm_resource_group.dev.location
  resource_group_name = data.azurerm_resource_group.dev.name
  os_type             = "Linux"
  sku_name            = "FC1"
  tags                = local.tags
}

resource "azurerm_function_app_flex_consumption" "dev" {
  #checkov:skip=CKV_AZURE_221:Lab - acceso publico para probar con curl. Produccion: private endpoint o APIM delante
  name                = "func-${local.nombre}-${random_string.sufijo.result}" # p. ej. func-lab-dev-a1b2
  location            = data.azurerm_resource_group.dev.location
  resource_group_name = data.azurerm_resource_group.dev.name
  service_plan_id     = azurerm_service_plan.func.id
  https_only          = true
  tags                = local.tags

  # Dónde vive el paquete de código y cómo entra la Function a ese storage.
  storage_container_type      = "blobContainer"
  storage_container_endpoint  = "${azurerm_storage_account.func.primary_blob_endpoint}${azurerm_storage_container.func_codigo.name}"
  storage_authentication_type = "StorageAccountConnectionString"
  storage_access_key          = azurerm_storage_account.func.primary_access_key

  runtime_name           = "powershell"
  runtime_version        = "7.6"
  instance_memory_in_mb  = 512 # la instancia más pequeña (0.25 vCPU)
  maximum_instance_count = 2   # tope de escalado: protege el presupuesto

  # Identidad administrada por el sistema: nace y muere con la Function.
  identity {
    type = "SystemAssigned"
  }

  # Configuración que lee el código (variables de entorno). Sin secretos aquí.
  app_settings = {
    KV_NAME = data.azurerm_key_vault.dev.name
  }

  site_config {}
}

# La identidad de la Function lee secretos del Key Vault. Ya estaba en la condición del rol B.
resource "azurerm_role_assignment" "func_kv" {
  scope                = data.azurerm_key_vault.dev.id
  role_definition_name = "Key Vault Secrets User"
  principal_id         = azurerm_function_app_flex_consumption.dev.identity[0].principal_id
}
