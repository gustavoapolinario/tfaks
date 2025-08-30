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
