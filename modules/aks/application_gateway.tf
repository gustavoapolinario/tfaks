resource "azurerm_public_ip" "agw_ip" {
  name                = "${var.project_name}-${var.environment}-agw-ip"
  resource_group_name = var.resource_group_name
  location            = var.location
  allocation_method   = "Static"
  sku                 = "Standard"
  tags                = var.tags
}

resource "azurerm_application_gateway" "agw" {
  name                = "${var.project_name}-${var.environment}-agw"
  resource_group_name = var.resource_group_name
  location            = var.location

  sku {
    name     = "WAF_v2"
    tier     = "WAF_v2"
    capacity = 2
  }

  identity {
    type         = "UserAssigned"
    identity_ids = [azurerm_user_assigned_identity.agw_identity.id]
  }

  gateway_ip_configuration {
    name      = "appGatewayIpConfig"
    subnet_id = var.lb_subnet_id
  }

  frontend_port {
    name = "http-port"
    port = 80
  }

  frontend_port {
    name = "https-port"
    port = 443
  }

  frontend_ip_configuration {
    name                 = "frontend-ip"
    public_ip_address_id = azurerm_public_ip.agw_ip.id
  }

  backend_address_pool {
    name = "backend-pool"
  }

  backend_http_settings {
    name                  = "http-settings"
    cookie_based_affinity = "Disabled"
    path                  = "/"
    port                  = 80
    protocol              = "Http"
    request_timeout       = 60
  }

  http_listener {
    name                           = "http-listener"
    frontend_ip_configuration_name = "frontend-ip"
    frontend_port_name             = "http-port"
    protocol                       = "Http"
  }

  request_routing_rule {
    name                       = "http-rule"
    rule_type                  = "Basic"
    priority                   = 100
    http_listener_name         = "http-listener"
    backend_address_pool_name  = "backend-pool"
    backend_http_settings_name = "http-settings"
  }

  # http_listener {
  #   name                           = "https-listener"
  #   frontend_ip_configuration_name = "frontend-ip"
  #   frontend_port_name             = "https-port"
  #   protocol                       = "Https"
  #   host_name = "your-domain.com"
  #   ssl_certificate_name = "ssl-certificate"
  # }

  # ssl_certificate {
  #   name = "ssl-certificate"
  #   key_vault_secret_id = var.akv_certificate_secret_id
  # }

  # request_routing_rule {
  #   name                       = "https-rule"
  #   rule_type                  = "Basic"
  #   priority                   = 90
  #   http_listener_name         = "https-listener"
  #   backend_address_pool_name  = "backend-pool"
  #   backend_http_settings_name = "http-settings" 
  # }

  waf_configuration {
    enabled          = true
    firewall_mode    = "Detection"
    rule_set_type    = "OWASP"
    rule_set_version = "3.0"
  }

  tags = var.tags
}

resource "azurerm_user_assigned_identity" "agw_identity" {
  name                = "${var.project_name}-${var.environment}-agw-identity"
  resource_group_name = var.resource_group_name
  location            = var.location
  tags                = var.tags
}
resource "azurerm_key_vault_access_policy" "agw_identity_policy" {
  key_vault_id = var.akv_certificate_id
  tenant_id    = data.azurerm_client_config.current.tenant_id
  object_id    = azurerm_user_assigned_identity.agw_identity.principal_id

  secret_permissions = [
    "Get", "List"
  ]

  certificate_permissions = [
    "Get", "List"
  ]
}


# Role Assignment to AGIC access the Resource Group
resource "azurerm_role_assignment" "agic_reader" {
  scope                = var.resource_group_id
  role_definition_name = "Reader"
  principal_type = "ServicePrincipal"
  principal_id         = azurerm_kubernetes_cluster.aks.ingress_application_gateway[0].ingress_application_gateway_identity[0].object_id
}


# TODO: verificar entre os 2 abaixo qual é o correto
# Role Assignment to AGIC access the Application Gateway
resource "azurerm_role_assignment" "agic_contributor" {
  scope                = azurerm_application_gateway.agw.id
  role_definition_name = "Contributor"
  principal_type = "ServicePrincipal"
  principal_id         =  azurerm_kubernetes_cluster.aks.ingress_application_gateway[0].ingress_application_gateway_identity[0].object_id
}

# Permissão para o AGIC gerenciar a User-Assigned Identity
resource "azurerm_role_assignment" "agic_identity_operator" {
  scope                = azurerm_user_assigned_identity.agw_identity.id
  role_definition_name = "Managed Identity Operator"
  principal_id         = azurerm_kubernetes_cluster.aks.ingress_application_gateway[0].ingress_application_gateway_identity[0].object_id
}

# TODO: verificar entre os 2 abaixo qual é o correto
resource "azurerm_role_assignment" "agic_network_contributor" {
  scope                = var.lb_subnet_id
  role_definition_name = "Network Contributor"
  principal_id         = azurerm_kubernetes_cluster.aks.ingress_application_gateway[0].ingress_application_gateway_identity[0].object_id
}
resource "azurerm_role_assignment" "agic_network_contributor2" {
  scope                = var.lb_subnet_id
  role_definition_name = "Network Contributor"
  principal_id         = azurerm_kubernetes_cluster.aks.identity[0].principal_id
}
