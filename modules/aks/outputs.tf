output "principal_id" {
  description = "The Principal ID of the AKS cluster's SystemAssigned identity."
  value       = azurerm_kubernetes_cluster.aks.identity[0].principal_id
}
output "name" {
  description = "The name of the AKS cluster."
  value       = azurerm_kubernetes_cluster.aks.name
}

output "aks_keyvault_connection" {
  description = "The connection string to the Key Vault from the AKS cluster."
  value       = azurerm_kubernetes_cluster.aks.identity[0].principal_id
}
