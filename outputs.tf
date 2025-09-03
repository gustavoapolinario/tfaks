output "tenant_id" {
  value = data.azurerm_client_config.current.tenant_id
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
