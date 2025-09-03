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

output "application_gateway_public_ip" {
  value = azurerm_public_ip.agw_ip.ip_address
}

output "agic_identity_id" {
  value = azurerm_kubernetes_cluster.aks.ingress_application_gateway[0].ingress_application_gateway_identity[0].client_id
}
output "agic_identity_object_id" {
  value = azurerm_kubernetes_cluster.aks.ingress_application_gateway[0].ingress_application_gateway_identity[0].object_id
}

output "app_gateway_id" {
  value = azurerm_application_gateway.agw.id
}
output "app_gateway_agw_identity_principal_id" {
  value = azurerm_user_assigned_identity.agw_identity.principal_id
}
