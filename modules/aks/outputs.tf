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
  value       = azurerm_kubernetes_cluster.aks.identity
}

output "agforcontainers_identity_client_id" {
  value = azurerm_user_assigned_identity.agforcontainers_identity.client_id
}

output "managed_cluster_resource_group_id" {
  value = data.azurerm_resource_group.mc_rg.id
}

output "agforcontainers_identity_principal_id" {
  value = azurerm_user_assigned_identity.agforcontainers_identity.principal_id
}
