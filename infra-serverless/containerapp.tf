# containerapp.tf — la Container App: identidad, permisos, entorno y la app.

# Identidad asignada por el usuario: existe ANTES que la app, así sus permisos
# (leer el registry y el Key Vault) ya están listos cuando la app arranca.
resource "azurerm_user_assigned_identity" "web" {
  name                = "id-ca-${local.nombre}"
  location            = data.azurerm_resource_group.dev.location
  resource_group_name = data.azurerm_resource_group.dev.name
  tags                = local.tags
}

# Descargar imágenes del registry. Permitido por la condición del rol B (Paso 0).
resource "azurerm_role_assignment" "web_acr_pull" {
  scope                = azurerm_container_registry.dev.id
  role_definition_name = "AcrPull"
  principal_id         = azurerm_user_assigned_identity.web.principal_id
}

# Leer secretos del Key Vault del stack base. Ya estaba en la condición del rol B (Lab 2).
resource "azurerm_role_assignment" "web_kv" {
  scope                = data.azurerm_key_vault.dev.id
  role_definition_name = "Key Vault Secrets User"
  principal_id         = azurerm_user_assigned_identity.web.principal_id
}

# Los roles tardan en propagarse. Si la app se crea antes, falla al leer el secreto.
resource "time_sleep" "espera_rbac_web" {
  create_duration = "90s"
  depends_on = [
    azurerm_role_assignment.web_acr_pull,
    azurerm_role_assignment.web_kv,
  ]
}

# El entorno: la "frontera" que comparten las apps (red y logs). Sin VNet propia en el lab.
resource "azurerm_container_app_environment" "dev" {
  name                       = "cae-${local.nombre}"
  location                   = data.azurerm_resource_group.dev.location
  resource_group_name        = data.azurerm_resource_group.dev.name
  logs_destination           = "log-analytics"
  log_analytics_workspace_id = data.azurerm_log_analytics_workspace.dev.id
  tags                       = local.tags
}

resource "azurerm_container_app" "web" {
  name                         = "ca-web-${local.nombre}"
  container_app_environment_id = azurerm_container_app_environment.dev.id
  resource_group_name          = data.azurerm_resource_group.dev.name
  revision_mode                = "Multiple" # varias revisiones activas a la vez: permite repartir tráfico
  max_inactive_revisions       = 5
  tags                         = local.tags

  identity {
    type         = "UserAssigned"
    identity_ids = [azurerm_user_assigned_identity.web.id]
  }

  # De dónde descarga las imágenes y con qué identidad (sin usuario ni contraseña).
  registry {
    server   = azurerm_container_registry.dev.login_server
    identity = azurerm_user_assigned_identity.web.id
  }

  # Referencia al Key Vault: la app guarda la DIRECCIÓN del secreto, no su valor.
  # Sin versión al final: siempre toma la versión vigente.
  secret {
    name                = "mensaje-lab"
    identity            = azurerm_user_assigned_identity.web.id
    key_vault_secret_id = "${data.azurerm_key_vault.dev.vault_uri}secrets/mensaje-lab"
  }

  ingress {
    external_enabled = true # URL pública con HTTPS
    target_port      = 8080 # el puerto en el que escucha el contenedor

    traffic_weight {
      latest_revision = true # 100 % a la revisión más nueva
      percentage      = 100
    }
  }

  template {
    min_replicas = 0 # sin tráfico, baja a cero réplicas: no se paga cómputo
    max_replicas = 2

    # KEDA agrega una réplica por cada 10 peticiones simultáneas.
    http_scale_rule {
      name                = "http"
      concurrent_requests = "10"
    }

    container {
      name   = "web"
      image  = "mcr.microsoft.com/dotnet/samples:aspnetapp" # imagen temporal: el pipeline pone la nuestra
      cpu    = 0.25
      memory = "0.5Gi"

      env {
        name        = "MENSAJE"
        secret_name = "mensaje-lab" # el valor llega del Key Vault
      }
    }
  }

  lifecycle {
    ignore_changes = [
      template[0].container[0].image, # la versión de la app la cambia el pipeline, no Terraform
      template[0].revision_suffix,    # el pipeline nombra cada revisión
      ingress[0].traffic_weight,      # el reparto de tráfico se cambia a mano en el Paso 9
    ]
  }

  depends_on = [time_sleep.espera_rbac_web]
}
