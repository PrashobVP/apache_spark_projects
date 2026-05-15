resource "azurerm_storage_container" "study" {
  name                  = "study-data"
  storage_account_id    = "/subscriptions/${var.subscription_id}/resourceGroups/rg_vi_dev/providers/Microsoft.Storage/storageAccounts/adls01visouthind"
  container_access_type = "private"
}

resource "azurerm_databricks_workspace" "study" {
  name                        = "dbw-vi-study-southindia"
  resource_group_name         = "rg_vi_dev"
  location                    = "southindia"
  sku                         = "premium"
  managed_resource_group_name = "rg-managed-dbw-vi-study"
}

resource "azurerm_databricks_access_connector" "study" {
  name                = "dbac-vi-study-southindia"
  resource_group_name = "rg_vi_dev"
  location            = "southindia"

  identity {
    type = "SystemAssigned"
  }
}

# resource "azurerm_role_assignment" "access_connector_blob" {
#   scope                = "/subscriptions/${var.subscription_id}/resourceGroups/rg_vi_dev/providers/Microsoft.Storage/storageAccounts/adls01visouthind"
#   role_definition_name = "Storage Blob Data Contributor"
#   principal_id         = azurerm_databricks_access_connector.study.identity[0].principal_id
# }