resource "random_integer" "keyvault_suffix" {
  min = 10000
  max = 99999
}

resource "azurerm_key_vault" "ecconmercelab" {
  name                = "${local.project_name}-${var.environment}-eclab-kv-${random_integer.keyvault_suffix.result}"
  location            = azurerm_resource_group.aks_rg.location
  resource_group_name = azurerm_resource_group.aks_rg.name
  tenant_id           = data.azurerm_client_config.current.tenant_id
  sku_name            = "standard"

  # This is important: The default network ACL is often too restrictive for pods.
  network_acls {
    default_action = "Deny"
    bypass         = "AzureServices" # Allows AKS (an Azure Service) to bypass the firewall

    # Add your current public IP to the allowed list
    ip_rules                   = ["${local.my_public_ipv4}/32"]
    virtual_network_subnet_ids = [module.vpc.private_subnet_id, module.vpc.private_isolated_subnet_id]
  }
}
resource "azurerm_key_vault_access_policy" "terraform_user" {
  key_vault_id = azurerm_key_vault.ecconmercelab.id
  tenant_id    = data.azurerm_client_config.current.tenant_id
  object_id    = data.azurerm_client_config.current.object_id

  secret_permissions = [
    "Get", "List", "Set", "Delete", "Purge"
  ]

  key_permissions = [
    "Get", "List", "Update", "Create", "Delete",  "Purge"
  ]
}
resource "azurerm_key_vault_access_policy" "aks_system_identity" {
  key_vault_id = azurerm_key_vault.ecconmercelab.id
  tenant_id    = data.azurerm_client_config.current.tenant_id
  # object_id is the principal ID of the AKS cluster's system-assigned identity
  object_id = module.aks.principal_id

  secret_permissions = [
    "Get", "List"
  ]

  key_permissions = [
    "Get", "List"
  ]

  depends_on = [module.aks]
}
resource "azurerm_key_vault_secret" "example" {
  name         = "example-secret"
  value        = "HelloFromAKV!"
  key_vault_id = azurerm_key_vault.ecconmercelab.id

  depends_on = [azurerm_key_vault_access_policy.terraform_user]
}




resource "azurerm_key_vault" "ssl_cert" {
  name                        = "${local.project_name}-${var.environment}-eclabssl-${random_integer.keyvault_suffix.result}"
  location                    = azurerm_resource_group.aks_rg.location
  resource_group_name         = azurerm_resource_group.aks_rg.name
  enabled_for_disk_encryption = true
  tenant_id                   = data.azurerm_client_config.current.tenant_id
  soft_delete_retention_days  = 7
  purge_protection_enabled    = false

  sku_name = "standard"
}

resource "azurerm_key_vault_access_policy" "aks_system_identity_akv_ssl" {
  key_vault_id = azurerm_key_vault.ssl_cert.id
  tenant_id    = data.azurerm_client_config.current.tenant_id
  # object_id is the principal ID of the AKS cluster's system-assigned identity
  object_id = module.aks.principal_id

  secret_permissions = [
    "Get", "List"
  ]

  key_permissions = [
    "Get", "List"
  ]

  certificate_permissions = [
    "Create",
    "Delete",
    "DeleteIssuers",
    "Get",
    "GetIssuers",
    "Import",
    "List",
    "ListIssuers",
    "ManageContacts",
    "ManageIssuers",
    "SetIssuers",
    "Update"
  ]

  depends_on = [module.aks]
}

resource "azurerm_key_vault_access_policy" "terraform_user_akv_ssl" {
  key_vault_id = azurerm_key_vault.ssl_cert.id
  tenant_id    = data.azurerm_client_config.current.tenant_id
  object_id    = data.azurerm_client_config.current.object_id

  certificate_permissions = [
    "Create",
    "Delete",
    "DeleteIssuers",
    "Get",
    "GetIssuers",
    "Import",
    "List",
    "ListIssuers",
    "ManageContacts",
    "ManageIssuers",
    "SetIssuers",
    "Update"
  ]

  key_permissions = [
    "Get", "List", "Update", "Create", "Delete",  "Purge"
  ]
}

# Alternative: Create a self-signed certificate (for testing)
resource "azurerm_key_vault_certificate" "self_signed" {
  name         = "${var.certificate_name}-selfsigned"
  key_vault_id = azurerm_key_vault.ssl_cert.id

  certificate_policy {
    issuer_parameters {
      name = "Self"
    }

    key_properties {
      exportable = true
      key_size   = 2048
      key_type   = "RSA"
      reuse_key  = true
    }

    lifetime_action {
      action {
        action_type = "AutoRenew"
      }

      trigger {
        days_before_expiry = 30
      }
    }

    secret_properties {
      content_type = "application/x-pkcs12"
    }

    x509_certificate_properties {
      extended_key_usage = ["1.3.6.1.5.5.7.3.1"] # Server Authentication
      key_usage = [
        "cRLSign",
        "dataEncipherment",
        "digitalSignature",
        "keyAgreement",
        "keyCertSign",
        "keyEncipherment",
      ]

      subject_alternative_names {
        dns_names = [var.domain_name, "www.${var.domain_name}"]
      }

      subject            = "CN=${var.domain_name}"
      validity_in_months = 12
    }
  }

  depends_on = [
    azurerm_key_vault_access_policy.terraform_user_akv_ssl,
  ]
}
