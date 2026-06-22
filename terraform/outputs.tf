output "web_app_url" {
  description = "Public URL of the Web App (to open in a browser)"
  value       = "https://${azurerm_linux_web_app.web_app.default_hostname}"
}

output "acr_login_server" {
  description = "ACR address for docker push/pull in the CI/CD pipeline"
  value       = azurerm_container_registry.acr.login_server
}

output "sql_server_fqdn" {
  description = "Fully qualified domain name of the SQL Server for the connection string"
  value       = azurerm_mssql_server.sql_server.fully_qualified_domain_name
}

output "key_vault_uri" {
  description = "Key Vault URI for manually reading secrets via CLI"
  value       = azurerm_key_vault.kv.vault_uri
}

output "key_vault_id" {
  description = "Key Vault ID (for adding new access policies)"
  value       = azurerm_key_vault.kv.id
}