# aks.tf — el clúster: 1 nodo, tier Free, acceso solo con Entra ID.

resource "azurerm_kubernetes_cluster" "dev" {
  #checkov:skip=CKV_AZURE_115:Lab - cluster publico; los runners de GitHub estan en internet. Produccion: cluster privado + runner privado
  #checkov:skip=CKV_AZURE_6:Lab - las IP de los runners cambian. Produccion: cluster privado o authorized IP ranges
  #checkov:skip=CKV_AZURE_170:Lab - tier Free sin SLA para no pagar el plano de control. Produccion: Standard
  #checkov:skip=CKV_AZURE_4:Lab - el monitoreo del cluster es el Lab 6
  #checkov:skip=CKV_AZURE_116:Lab - Azure Policy agrega pods que no caben en 1 nodo pequeno. Produccion: activado
  #checkov:skip=CKV_AZURE_117:Lab - discos con clave de Microsoft. Produccion: disk encryption set con clave propia
  #checkov:skip=CKV_AZURE_226:Lab - el tamano del nodo no tiene disco temporal para un disco efimero
  #checkov:skip=CKV_AZURE_227:Lab - host encryption exige registrar una feature en la suscripcion
  #checkov:skip=CKV_AZURE_232:Lab - con 1 solo node pool, las apps corren en el de sistema. Produccion: pool de usuario aparte
  name                = "aks-${local.nombre}"
  location            = data.azurerm_resource_group.dev.location
  resource_group_name = data.azurerm_resource_group.dev.name
  dns_prefix          = "aks-${local.nombre}"
  node_resource_group = "rg-${local.nombre}-aks-nodos" # el grupo que administra AKS (si no, MC_...)
  sku_tier            = "Free"                         # el plano de control no se cobra

  # Parches de Kubernetes e imagen del nodo, automáticos.
  automatic_upgrade_channel = "patch"
  node_os_upgrade_channel   = "NodeImage"

  # Acceso: solo con Entra ID y roles de Azure. Sin usuario admin local.
  local_account_disabled = true
  azure_active_directory_role_based_access_control {
    azure_rbac_enabled = true
    tenant_id          = data.azurerm_client_config.actual.tenant_id
  }

  # Base de Workload Identity (Paso 7).
  oidc_issuer_enabled       = true
  workload_identity_enabled = true

  # Driver que monta secretos del Key Vault como archivos (Paso 7).
  key_vault_secrets_provider {
    secret_rotation_enabled = true
  }

  default_node_pool {
    name                        = "sistema"
    vm_size                     = var.node_size
    node_count                  = 1
    vnet_subnet_id              = azurerm_subnet.aks.id
    os_disk_size_gb             = 30 # 128 por defecto: más caro y no hace falta
    max_pods                    = 110
    temporary_name_for_rotation = "temporal" # para cambiar el tamaño sin recrear el clúster

    upgrade_settings {
      max_surge = "1" # en cada actualización se agrega 1 nodo temporal (necesita cuota)
    }
  }

  identity {
    type         = "UserAssigned"
    identity_ids = [azurerm_user_assigned_identity.aks.id]
  }

  network_profile {
    network_plugin      = "azure"
    network_plugin_mode = "overlay"        # los pods NO gastan IPs de la VNet
    network_data_plane  = "cilium"         # Azure CNI con Cilium (eBPF)
    network_policy      = "cilium"         # permite NetworkPolicy entre pods
    pod_cidr            = "192.168.0.0/16" # rango interno de los pods
    service_cidr        = "172.16.0.0/16"  # rango interno de los Services
    dns_service_ip      = "172.16.0.10"
    load_balancer_sku   = "standard"
    outbound_type       = "loadBalancer"
  }

  tags = local.tags

  depends_on = [time_sleep.espera_rbac_red]
}
