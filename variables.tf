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

variable "tags" {
  description = "A map of tags to assign to the resources."
  type        = map(string)
  default = {
    "Environment" = "dev"
    "Project"     = "aks-cluster"
    "Terraform"   = "true"
  }
}

###########################################
############# VPC Variables ###############
###########################################
variable "vnet_cidr" {
  description = "The address space for the entire VNet. Make sure this is large enough."
  type        = string
  default     = "10.10.0.0/16"
}

variable "create_lb_subnet" {
  description = "Create the lb subnet?"
  type        = bool
  default     = true
}
variable "subnet_lb_cidr" {
  description = "The CIDR for the lb subnet."
  type        = string
  default     = "10.10.0.0/24"
}

variable "subnet_private_cidr" {
  description = "The CIDR for the private subnet."
  type        = string
  default     = "10.10.10.0/24" # Supports up to 250 nodes
}
variable "create_nat_gateway" {
  description = "Create the Nat gateway?"
  type        = bool
  default     = false
}

variable "create_private_isolated_subnet" {
  description = "Create the private isolated subnet?"
  type        = bool
  default     = true
}
variable "subnet_private_isolated_cidr" {
  description = "The CIDR for the data subnet."
  type        = string
  default     = "10.10.20.0/24"
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

variable "aks_admin_group_name" {
  description = "The name of the Azure AD group that will have admin access to the cluster."
  type        = string
  default     = null
}


###########################################
############# AKS Network #################
###########################################
variable "aks_overlay_pod_cidr" {
  description = "The CIDR for Kubernetes services in the cluster."
  type        = string
  default     = "192.168.0.0/16"
}

# Network CIDRs (MUST not overlap with VNet/Subnet CIDRs!)
# variable "aks_service_cidr" {
#   description = "The CIDR for Kubernetes services in the cluster."
#   type        = string
#   default     = "192.168.1.0/24"
# }

# variable "aks_dns_service_ip" {
#   description = "The IP address assigned to the Kubernetes DNS service. It must be within the Kubernetes service address range specified in service_cidr."
#   type        = string
#   default     = "192.168.1.10"
# }

###########################################
############# AKS Node Pool ###############
###########################################

variable "default_node_pool_vm_size" {
  description = "The VM size for nodes in the default node pool."
  type        = string
}

variable "default_node_pool_os_disk_size" {
  description = "The size of the OS disk for nodes in the default node pool (in GB)."
  type        = number
  default     = 128
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
################# Apps ####################
###########################################
variable "certificate_name" {
  description = "Name of the SSL certificate"
  default     = "frontend-ssl-cert"
}

variable "domain_name" {
  description = "Domain name for the certificate"
  default     = "your-domain.com"
}
