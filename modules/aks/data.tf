data "azurerm_client_config" "current" {}

# Get the MC (managed cluster) resource group
data "azurerm_resource_group" "mc_rg" {
  name = azurerm_kubernetes_cluster.aks.node_resource_group
}
