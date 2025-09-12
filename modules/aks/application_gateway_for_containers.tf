resource "azurerm_user_assigned_identity" "agforcontainers_identity" {
  name                = "${var.project_name}-${var.environment}-albc-identity"
  resource_group_name = var.resource_group_name
  location            = var.location
  tags                = var.tags
}

# Role Assignment to AGIC access the Resource Group
resource "azurerm_role_assignment" "agforcontainers_identity_reader" {
  scope                = var.resource_group_id
  role_definition_name = "Reader"
  principal_type = "ServicePrincipal"
  principal_id         = azurerm_user_assigned_identity.agforcontainers_identity.principal_id
}

resource "azurerm_federated_identity_credential" "agforcontainers_identity" {
  name                = "azure-alb-identity"
  resource_group_name = var.resource_group_name
  audience            = ["api://AzureADTokenExchange"] # Optional, defaults to this
  issuer              = azurerm_kubernetes_cluster.aks.oidc_issuer_url
  parent_id           = azurerm_user_assigned_identity.agforcontainers_identity.id
  subject             = "system:serviceaccount:azure-alb-system:alb-controller-sa"
}

resource "azurerm_role_assignment" "agforcontainers_reader" {
  scope                = data.azurerm_resource_group.mc_rg.id
  role_definition_name = "Reader"
  principal_id         = azurerm_user_assigned_identity.agforcontainers_identity.principal_id
}
resource "azurerm_role_assignment" "agforcontainers_config_manager" {
  scope                = data.azurerm_resource_group.mc_rg.id # MC (managed cluster) resource group
  role_definition_name = "AppGw for Containers Configuration Manager"
  principal_id         = azurerm_user_assigned_identity.agforcontainers_identity.principal_id
}

resource "azurerm_role_assignment" "agforcontainers_network_contributor" {
  scope                = var.lb_subnet_id
  role_definition_name = "Network Contributor"
  principal_id         = azurerm_user_assigned_identity.agforcontainers_identity.principal_id
}
