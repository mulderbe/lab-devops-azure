# vm.tf — VM Linux sin IP pública, con identidad administrada y nginx.
# count = 1 si vm_enabled es true; 0 si es false (no se crea nada de este archivo).

resource "azurerm_network_interface" "vm" {
  count               = var.vm_enabled ? 1 : 0
  name                = "nic-vm-${local.nombre}-web"
  location            = azurerm_resource_group.dev.location
  resource_group_name = azurerm_resource_group.dev.name
  tags                = local.tags

  ip_configuration {
    name                          = "interna"
    subnet_id                     = azurerm_subnet.vm.id
    private_ip_address_allocation = "Dynamic"
    # Sin public_ip_address_id: la VM no tiene IP pública.
  }
}

resource "azurerm_linux_virtual_machine" "web" {
  count                           = var.vm_enabled ? 1 : 0
  name                            = "vm-${local.nombre}-web" # vm-lab-dev-web
  location                        = azurerm_resource_group.dev.location
  resource_group_name             = azurerm_resource_group.dev.name
  size                            = var.vm_size
  admin_username                  = var.admin_username
  disable_password_authentication = true
  network_interface_ids           = [azurerm_network_interface.vm[0].id]
  custom_data                     = base64encode(file("${path.module}/cloud-init.yaml"))
  tags                            = local.tags

  admin_ssh_key {
    username   = var.admin_username
    public_key = tls_private_key.vm.public_key_openssh
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS" # disco HDD estándar: el más barato
    disk_size_gb         = 30
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "ubuntu-24_04-lts"
    sku       = "server"
    version   = "latest"
  }

  # Identidad administrada: Azure crea y rota su credencial. No hay secreto que guardar.
  identity {
    type = "SystemAssigned"
  }

  # Diagnóstico de arranque con storage administrado: habilita la consola serie.
  boot_diagnostics {}
}

# La VM solo puede leer UN secreto (mensaje-lab), no todo el Key Vault: mínimo privilegio.
resource "azurerm_role_assignment" "vm_lee_mensaje" {
  count                = var.vm_enabled ? 1 : 0
  scope                = azurerm_key_vault_secret.mensaje.resource_versionless_id
  role_definition_name = "Key Vault Secrets User"
  principal_id         = azurerm_linux_virtual_machine.web[0].identity[0].principal_id
  principal_type       = "ServicePrincipal" # evita errores por retraso de replicación
}
