variable "location" {
  description = "The Azure Region where the resources should be created."
  type        = string
  default     = "Canada Central"
}

variable "environment" {
  description = "The environment name (e.g., dev, staging, prod)."
  type        = string
  default     = "dev"
}

variable "project_name" {
  description = "Project Name"
  type        = string
}

variable "tags" {
  description = "A map of tags to assign to the resources."
  type        = map(string)
  default = {
    "Environment" = "dev"
    "Project"     = "aks-cluster"
    "Terraform"   = "true"
  }
}

variable "resource_group_name" {
  description = "The name of an existing resource group to deploy into."
  type        = string
}

variable "resource_group_id" {
  description = "The ID of an existing resource group to deploy into."
  type        = string
}

###########################################
############# AKS Management ##############
###########################################
variable "kubernetes_version" {
  description = "Kubernetes Version"
  type        = string
}

variable "cluster_endpoint_public_access" {
  description = "(Optional) Cluster Endpoint API with public access? Make public or use a VPN or something else"
  type        = bool
  default     = false
}

# Add-ons
variable "azure_policy_enabled" {
  description = "Whether to enable Azure Policy add-on for the cluster."
  type        = bool
  default     = true
}

# Authentication
variable "ssh_public_key" {
  description = "The SSH public key for accessing the cluster nodes."
  type        = string
  sensitive   = true
}

variable "aks_admin_group_ids" {
  description = "List of Object IDs of the Azure AD groups that will have admin access to the cluster."
  type        = list(string)
  default     = null
}


###########################################
############# AKS Network #################
###########################################
variable "vnet_id" {
  description = "The ID of the existing Virtual Network to deploy the AKS cluster into."
  type        = string
}

variable "vnet_subnet_id" {
  description = "The ID of the existing Subnet within the VNet for the AKS cluster nodes."
  type        = string
}

variable "aks_overlay_pod_cidr" {
  description = "The CIDR for Kubernetes services in the cluster."
  type        = string
  default     = "192.168.0.0/16"
}

# Network CIDRs (MUST not overlap with VNet/Subnet CIDRs!)
variable "aks_service_cidr" {
  description = "The CIDR for Kubernetes services in the cluster."
  type        = string
  default     = "192.168.1.0/24"
}

# variable "aks_dns_service_ip" {
#   description = "The IP address assigned to the Kubernetes DNS service. It must be within the Kubernetes service address range specified in service_cidr."
#   type        = string
#   default     = "192.168.1.10"
# }

###########################################
############# LB Network #################
###########################################

variable "lb_subnet_id" {
  description = "The ID of the existing Subnet within the VNet for the Load Balancers (ALB, AAG)."
  type        = string
}

###########################################
############# AKS Node Pool ###############
###########################################

variable "default_node_pool_vm_size" {
  description = "The VM size for nodes in the default node pool."
  type        = string
  default     = "Standard_B2ats_v2"
}

variable "default_node_pool_os_disk_size" {
  description = "The size of the OS disk for nodes in the default node pool (in GB)."
  type        = number
  default     = 128
}

variable "default_node_pool_enable_auto_scaling" {
  description = "Whether to enable auto-scaling for the default node pool."
  type        = bool
  default     = true
}

variable "default_node_pool_min_count" {
  description = "The minimum number of nodes for the default node pool auto-scaler."
  type        = number
  default     = 3
}

variable "default_node_pool_max_count" {
  description = "The maximum number of nodes for the default node pool auto-scaler."
  type        = number
  default     = 10
}

###########################################
############# AKS Monitoring ##############
###########################################

variable "create_log_analytics_workspace" {
  description = "Whether to create a new Log Analytics workspace for the cluster monitoring."
  type        = bool
  default     = true
}

variable "log_analytics_workspace_id" {
  description = "The ID of an existing Log Analytics workspace to use for monitoring. Used if create_log_analytics_workspace is false."
  type        = string
  default     = null
}

variable "log_retention_in_days" {
  description = "The retention period for logs in the Log Analytics workspace (in days)."
  type        = number
  default     = 30
}

###########################################
########## Service Connections#############
###########################################

variable "akv_connections" {
  description = "Map of Azure Key Vault names to their resource IDs for Service Connector connections."
  type        = map(string)
  default     = {}
}

