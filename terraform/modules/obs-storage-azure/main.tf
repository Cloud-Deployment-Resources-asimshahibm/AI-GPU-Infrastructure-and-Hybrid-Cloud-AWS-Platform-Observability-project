resource "azurerm_storage_account" "obs" {
  name                            = "${var.prefix}obs${var.env}"
  resource_group_name             = var.resource_group_name
  location                        = var.location
  account_tier                    = "Standard"
  account_replication_type        = "ZRS"
  min_tls_version                 = "TLS1_2"
  allow_nested_items_to_be_public = false
  public_network_access_enabled   = false
  tags                            = var.tags
}

resource "azurerm_storage_container" "signal" {
  for_each              = toset(["metrics", "logs", "traces", "profiles"])
  name                  = each.key
  storage_account_id    = azurerm_storage_account.obs.id
  container_access_type = "private"
}

resource "azurerm_storage_management_policy" "tiering" {
  storage_account_id = azurerm_storage_account.obs.id
  rule {
    name    = "cool-after-30d"
    enabled = true
    filters {
      blob_types = ["blockBlob"]
    }
    actions {
      base_blob {
        tier_to_cool_after_days_since_modification_greater_than = 30
        delete_after_days_since_modification_greater_than       = 402
      }
    }
  }
}

# Workload identity: one user-assigned identity per writer, federated to its Kubernetes service account
resource "azurerm_user_assigned_identity" "writer" {
  for_each            = var.service_accounts
  name                = "${var.prefix}-obs-${each.key}"
  resource_group_name = var.resource_group_name
  location            = var.location
}

resource "azurerm_federated_identity_credential" "writer" {
  for_each            = var.service_accounts
  name                = "${each.key}-fic"
  resource_group_name = var.resource_group_name
  parent_id           = azurerm_user_assigned_identity.writer[each.key].id
  audience            = ["api://AzureADTokenExchange"]
  issuer              = var.oidc_issuer_url
  subject             = "system:serviceaccount:${each.value}"
}

resource "azurerm_role_assignment" "writer" {
  for_each             = var.service_accounts
  scope                = azurerm_storage_account.obs.id
  role_definition_name = "Storage Blob Data Contributor"
  principal_id         = azurerm_user_assigned_identity.writer[each.key].principal_id
}
