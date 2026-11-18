# network.tf — la subnet de los nodos, dentro de la VNet del stack base.

resource "azurerm_subnet" "aks" {
  #checkov:skip=CKV2_AZURE_31:AKS pone su propio NSG en las NIC de los nodos; uno en la subnet bloquearia el LoadBalancer
  name                 = "snet-aks"
  resource_group_name  = data.azurerm_resource_group.dev.name
  virtual_network_name = data.azurerm_virtual_network.dev.name
  address_prefixes     = [var.snet_aks_prefix]

  # Subnet privada: los nodos salen a internet por el balanceador que crea AKS
  # (outbound_type = "loadBalancer"), no por la salida por defecto de Azure.
  default_outbound_access_enabled = false
}
