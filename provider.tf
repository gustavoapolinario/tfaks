provider "azurerm" {
  features {
    # Configured to purge everything on terraform destroy
    api_management {
      purge_soft_delete_on_destroy = true
      recover_soft_deleted         = true
    }
    app_configuration {
      purge_soft_delete_on_destroy = true
      recover_soft_deleted         = true
    }
    key_vault {
      purge_soft_delete_on_destroy                                = true
      purge_soft_deleted_certificates_on_destroy                  = true
      purge_soft_deleted_keys_on_destroy                          = true
      purge_soft_deleted_secrets_on_destroy                       = true
      purge_soft_deleted_hardware_security_modules_on_destroy     = true
      purge_soft_deleted_hardware_security_module_keys_on_destroy = true

      recover_soft_deleted_certificates                  = true
      recover_soft_deleted_key_vaults                    = true
      recover_soft_deleted_keys                          = true
      recover_soft_deleted_secrets                       = true
      recover_soft_deleted_hardware_security_module_keys = true
    }
    log_analytics_workspace {
      permanently_delete_on_destroy = true
    }
    recovery_service {
      vm_backup_stop_protection_and_retain_data_on_destroy = false
      purge_protected_items_from_vault_on_destroy          = true
    }
  }
}

provider "azapi" {
  # No special configuration needed if you're already logged in with az login
}
