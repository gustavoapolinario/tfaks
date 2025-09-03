locals {
  cluster_name = "${var.project_name}-${var.environment}-aks"
}

resource "random_password" "windows_admin_password" {
  length  = 16
  special = true
}

resource "azurerm_kubernetes_cluster" "aks" {
  name                      = local.cluster_name
  location                  = var.location
  resource_group_name       = var.resource_group_name
  dns_prefix                = local.cluster_name
  kubernetes_version        = var.kubernetes_version
  node_resource_group       = "rg-node-${var.resource_group_name}"
  tags                      = var.tags
  private_cluster_enabled   = false # TODO: fix
  oidc_issuer_enabled       = true
  workload_identity_enabled = true

  identity {
    type = "SystemAssigned"
  }

  # -- Network Profile (Critical Integration with your VNet) --
  network_profile {
    network_plugin      = "azure"
    network_plugin_mode = "overlay"
    network_policy      = "azure"

    pod_cidr = var.aks_overlay_pod_cidr

    # service_cidr       = var.aks_service_cidr
    # dns_service_ip     = var.aks_dns_service_ip
    load_balancer_sku = "standard"
  }

  default_node_pool {
    name                        = "system" # TODO: default-np
    temporary_name_for_rotation = "systemupdtng"
    vm_size                     = var.default_node_pool_vm_size
    os_disk_size_gb             = var.default_node_pool_os_disk_size
    vnet_subnet_id              = var.vnet_subnet_id
    # pod_subnet_id        = azurerm_subnet.private_subnet.id
    type                   = "VirtualMachineScaleSets"
    auto_scaling_enabled   = true
    min_count              = var.default_node_pool_enable_auto_scaling ? var.default_node_pool_min_count : null
    max_count              = var.default_node_pool_enable_auto_scaling ? var.default_node_pool_max_count : null
    max_pods               = 250
    zones                  = [1, 2, 3]
    node_labels            = {}
    tags                   = merge(var.tags, { "pool" = "system" }) # TODO: default-np
    node_public_ip_enabled = true                                   # TODO: create var

    upgrade_settings {
      drain_timeout_in_minutes      = 0
      max_surge                     = "10%"
      node_soak_duration_in_minutes = 0
    }
  }

  # -- Cluster Features & Add-ons --
  azure_policy_enabled             = var.azure_policy_enabled
  http_application_routing_enabled = false # Disable this in production

  # Microsoft Defender for Cloud/Containers monitoring
  dynamic "oms_agent" {
    for_each = var.create_log_analytics_workspace ? [1] : []
    content {
      log_analytics_workspace_id = azurerm_log_analytics_workspace.logs[0].id
    }

  }

  role_based_access_control_enabled = true

  azure_active_directory_role_based_access_control {
    azure_rbac_enabled     = true
    admin_group_object_ids = var.aks_admin_group_ids
  }

  key_vault_secrets_provider {
    secret_rotation_enabled  = true  # TODO: create var
    secret_rotation_interval = "10m" # TODO: create var
  }

  ingress_application_gateway {
    gateway_id = azurerm_application_gateway.agw.id
  }

  # -- Local Admin Account (Keep disabled for production) --
  # local_account_disabled = true # Force use of AAD accounts

  # -- Windows Profile (Only if you need Windows containers) --
  # windows_profile {
  #   admin_username = "azureuser"
  #   admin_password = random_password.windows_admin_password.result
  # }

  # -- Linux Profile (SSH key config) --
  linux_profile {
    admin_username = "azureuser"

    ssh_key {
      key_data = var.ssh_public_key
    }
  }
}

resource "azurerm_log_analytics_workspace" "logs" {
  count               = var.create_log_analytics_workspace ? 1 : 0
  name                = "${var.project_name}-${var.environment}-log"
  location            = var.location
  resource_group_name = var.resource_group_name
  sku                 = "PerGB2018"
  retention_in_days   = var.log_retention_in_days
  tags                = var.tags
}

# Grant the AKS SystemAssigned Identity necessary permissions on the VNet/Subnet.
resource "azurerm_role_assignment" "network_contributor" {
  principal_id         = azurerm_kubernetes_cluster.aks.identity[0].principal_id
  role_definition_name = "Network Contributor"
  scope                = var.vnet_id

  depends_on = [azurerm_kubernetes_cluster.aks]
}
