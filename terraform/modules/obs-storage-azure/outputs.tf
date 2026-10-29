output "storage_account_name" {
  value = azurerm_storage_account.obs.name
}
output "identity_client_ids" {
  value = { for k, i in azurerm_user_assigned_identity.writer : k => i.client_id }
}
