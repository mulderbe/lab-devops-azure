# monitoring.tf — espacio de Log Analytics. El Lab 6 monta el monitoreo sobre este.

resource "azurerm_log_analytics_workspace" "dev" {
  name                = "law-${local.nombre}"
  location            = azurerm_resource_group.dev.location
  resource_group_name = azurerm_resource_group.dev.name
  sku                 = "PerGB2018"
  retention_in_days   = 30  # lo mínimo; los primeros 31 días no se cobran
  daily_quota_gb      = 0.5 # tope diario de ingesta: protege tu presupuesto
  tags                = local.tags
}
