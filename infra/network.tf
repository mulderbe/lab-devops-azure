# network.tf — red virtual, subnet de la VM y su NSG.
# Rangos reservados para los próximos labs (no se crean aquí):
#   10.10.4.0/23  -> serverless (Lab 5)
#   10.10.16.0/20 -> AKS (Lab 4)

resource "azurerm_virtual_network" "dev" {
  name                = "vnet-${local.nombre}"
  location            = azurerm_resource_group.dev.location
  resource_group_name = azurerm_resource_group.dev.name
  address_space       = var.address_space
  tags                = local.tags
}

resource "azurerm_subnet" "vm" {
  name                 = "snet-vm"
  resource_group_name  = azurerm_resource_group.dev.name
  virtual_network_name = azurerm_virtual_network.dev.name
  address_prefixes     = [var.snet_vm_prefix]

  # Lab: salida a internet por defecto (gratis) para instalar nginx y llegar al Key Vault.
  # Desde el 31/03/2026 las redes nuevas son privadas por defecto.
  # Producción: false + NAT Gateway o Azure Firewall, y private endpoints.
  default_outbound_access_enabled = true
}

resource "azurerm_network_security_group" "vm" {
  name                = "nsg-snet-vm"
  location            = azurerm_resource_group.dev.location
  resource_group_name = azurerm_resource_group.dev.name
  tags                = local.tags

  # Las reglas por defecto ya bloquean internet; esta lo deja escrito y visible.
  security_rule {
    name                       = "Denegar-Internet-Entrada"
    priority                   = 4000
    direction                  = "Inbound"
    access                     = "Deny"
    protocol                   = "*"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "Internet"
    destination_address_prefix = "*"
  }
}

resource "azurerm_subnet_network_security_group_association" "vm" {
  subnet_id                 = azurerm_subnet.vm.id
  network_security_group_id = azurerm_network_security_group.vm.id
}
