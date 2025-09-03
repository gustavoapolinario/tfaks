output "tenant_id" {
  value = data.azurerm_client_config.current.tenant_id
}

output "resource_group_name" {
  value = azurerm_resource_group.aks_rg.name
}

output "resource_group_id" {
  value = azurerm_resource_group.aks_rg.id
}

output "vpc_outputs" {
  value = module.vpc
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

# output "eks_loadbalancer_outputs" {
#   value = var.all_outputs ? module.eks_loadbalancer : null
# }

# output "configure_kubectl" {
#   description = "Configure kubectl: make sure you're logged in with the correct AWS profile and run the following command to update your kubeconfig"
#   value       = "aws eks --region ${local.region} update-kubeconfig --name ${module.eks.cluster_name}"
# }

output "key_vault_ssl_name" {
  value = azurerm_key_vault.ssl_cert.name
}

output "key_vault_ssl_certificate_name" {
  value = azurerm_key_vault_certificate.self_signed.name
}
