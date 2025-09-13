resource "random_integer" "keyvault_suffix" {
  min = 10000
  max = 99999
}

resource "azurerm_key_vault" "ecconmercelab" {
  name                       = "${local.project_name}-${var.environment}-eclab-kv-${random_integer.keyvault_suffix.result}"
  location                   = azurerm_resource_group.aks_rg.location
  resource_group_name        = azurerm_resource_group.aks_rg.name
  tenant_id                  = data.azurerm_client_config.current.tenant_id
  sku_name                   = "standard"
  purge_protection_enabled   = true
  soft_delete_retention_days = 7

  # This is important: The default network ACL is often too restrictive for pods.
  network_acls {
    default_action = "Deny"
    bypass         = "AzureServices" # Allows AKS (an Azure Service) to bypass the firewall

    # Add your current public IP to the allowed list
    ip_rules = [
      "${local.my_public_ipv4}/32",
    ]
    virtual_network_subnet_ids = [module.vnet.private_subnet_id, module.vnet.private_isolated_subnet_id]
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
    "Get", "List", "Update", "Create", "Delete", "Purge"
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
  content_type = "text/plain"
  key_vault_id = azurerm_key_vault.ecconmercelab.id

  depends_on = [azurerm_key_vault_access_policy.terraform_user]
}
