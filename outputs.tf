output "tenant_id" {
  value = data.azurerm_client_config.current.tenant_id
}

output "resource_group_name" {
  value = azurerm_resource_group.aks_rg.name
}

output "resource_group_id" {
  value = azurerm_resource_group.aks_rg.id
}

output "vnet_outputs" {
  value = module.vnet
}

output "aks_outputs" {
  value = module.aks
}

output "key_vault_ecconmercelab_name" {
  value = azurerm_key_vault.ecconmercelab.name
}

output "key_vault_secret_example_name" {
  value = azurerm_key_vault_secret.example.name
}

output "configure_kubectl" {
  description = "Configure kubectl"
  value       = "az aks get-credentials --name ${local.project_name} --resource-group ${azurerm_resource_group.aks_rg.name} --overwrite-existing"
}
