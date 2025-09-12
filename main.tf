locals {
  project_name = basename(path.cwd)
  tags = merge(var.tags, {
    "Rep" = local.project_name
  })
}

resource "azurerm_resource_group" "aks_rg" {
  name     = "${local.project_name}-${var.environment}-rg"
  location = var.location
  tags     = var.tags
}

data "azuread_group" "aks_admin_group" {
  display_name = var.aks_admin_group_name
}

module "vnet" {
  source              = "./modules/vnet"
  location            = var.location
  project_name        = local.project_name
  environment         = var.environment
  tags                = local.tags
  resource_group_name = azurerm_resource_group.aks_rg.name

  vnet_cidr                      = var.vnet_cidr
  create_lb_subnet               = var.create_lb_subnet
  subnet_lb_cidr                 = var.subnet_lb_cidr
  subnet_private_cidr            = var.subnet_private_cidr
  create_nat_gateway             = var.create_nat_gateway
  create_private_isolated_subnet = var.create_private_isolated_subnet
  subnet_private_isolated_cidr   = var.subnet_private_isolated_cidr
}

module "aks" {
  source              = "./modules/aks"
  location            = var.location
  project_name        = local.project_name
  environment         = var.environment
  tags                = local.tags
  resource_group_name = azurerm_resource_group.aks_rg.name
  resource_group_id   = azurerm_resource_group.aks_rg.id

  kubernetes_version             = var.kubernetes_version
  cluster_endpoint_public_access = var.cluster_endpoint_public_access
  azure_policy_enabled           = var.azure_policy_enabled
  ssh_public_key                 = var.ssh_public_key
  aks_admin_group_ids            = [data.azuread_group.aks_admin_group.object_id]

  aks_overlay_pod_cidr = var.aks_overlay_pod_cidr
  # aks_service_cidr               = var.aks_service_cidr

  vnet_id                        = module.vnet.vnet_id
  vnet_subnet_id                 = module.vnet.private_subnet_id
  lb_subnet_id                   = module.vnet.lb_subnet_id

  default_node_pool_vm_size      = var.default_node_pool_vm_size
  default_node_pool_os_disk_size = var.default_node_pool_os_disk_size
  default_node_pool_min_count    = var.default_node_pool_min_count
  default_node_pool_max_count    = var.default_node_pool_max_count
  create_log_analytics_workspace = var.create_log_analytics_workspace
  log_analytics_workspace_id     = var.log_analytics_workspace_id
  log_retention_in_days          = var.log_retention_in_days

  akv_connections = {
    "aks_ecconmercelab" = azurerm_key_vault.ecconmercelab.id
  }

  depends_on = [
    azurerm_key_vault.ecconmercelab,
  ]
}

