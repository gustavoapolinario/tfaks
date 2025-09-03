terraform {
  required_version = ">= 1.0"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.42"
    }
    azuread = {
      source  = "hashicorp/azuread"
      version = "~> 3.5"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.7"
    }
    http = {
      source  = "hashicorp/http"
      version = "~> 3.5"
    }
    azapi = {
      source  = "Azure/azapi"
      version = "~> 2.6"
    }
  }
}
