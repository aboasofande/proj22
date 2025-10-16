output "id" {
  description = "ID of the Container App"
  value       = azurerm_container_app.main.id
}

output "name" {
  description = "Name of the Container App"
  value       = azurerm_container_app.main.name
}

output "fqdn" {
  description = "FQDN of the Container App"
  value       = azurerm_container_app.main.ingress[0].fqdn
}

output "latest_revision_fqdn" {
  description = "FQDN of the latest revision"
  value       = azurerm_container_app.main.latest_revision_fqdn
}

output "revision_name" {
  description = "Name of the latest revision"
  value       = azurerm_container_app.main.latest_revision_name
}