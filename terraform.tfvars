location    = "Canada Central"
environment = "dev"
tags = {
  "Environment" = "dev"
  "Project"     = "aks-cluster"
  "Terraform"   = "true"
}

vnet_cidr                      = "10.10.0.0/16"
create_lb_subnet               = true
subnet_lb_cidr                 = "10.10.0.0/24"
subnet_private_cidr            = "10.10.10.0/24" # Supports up to 250 nodes
create_nat_gateway             = false
create_private_isolated_subnet = true
subnet_private_isolated_cidr   = "10.10.20.0/24"

kubernetes_version             = 1.33
cluster_endpoint_public_access = true
aks_overlay_pod_cidr           = "192.168.0.0/16"
default_node_pool_vm_size      = "Standard_B4als_v2"
default_node_pool_os_disk_size = 128
default_node_pool_min_count    = 1
default_node_pool_max_count    = 3
azure_policy_enabled           = true
create_log_analytics_workspace = false
aks_admin_group_name           = "admin"
log_retention_in_days          = 30
