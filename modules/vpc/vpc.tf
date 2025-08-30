resource "azurerm_virtual_network" "vnet" {
  name                = "${var.project_name}-${var.environment}-vnet"
  address_space       = [var.vnet_cidr]
  location            = var.location
  resource_group_name = var.resource_group_name
  tags                = var.tags
}

resource "azurerm_subnet" "lb_subnet" {
  count                = var.create_lb_subnet ? 1 : 0
  name                 = "${var.project_name}-${var.environment}-lb-subnet"
  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = [var.subnet_lb_cidr]

  # delegation {
  #   name = "aks-delegation-lb-subnet"

  #   service_delegation {
  #     name    = "Microsoft.ContainerService/managedClusters"
  #     actions = ["Microsoft.Network/virtualNetworks/subnets/join/action"]
  #   }
  # }

  service_endpoints = ["Microsoft.Storage"]
}

resource "azurerm_subnet" "private_subnet" {
  name                 = "${var.project_name}-${var.environment}-private-subnet"
  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = [var.subnet_private_cidr]

  service_endpoints = ["Microsoft.ContainerRegistry"]

  # delegation {
  #   name = "aks-delegation-private-subnet"

  #   service_delegation {
  #     name    = "Microsoft.ContainerService/managedClusters"
  #     actions = ["Microsoft.Network/virtualNetworks/subnets/join/action"]
  #   }
  # }

  private_endpoint_network_policies             = "Enabled"
  private_link_service_network_policies_enabled = false
}

resource "azurerm_public_ip" "nat_gateway_ip" {
  count               = var.create_nat_gateway ? 1 : 0
  name                = "${var.project_name}-${var.environment}-ip-nat"
  location            = var.location
  resource_group_name = var.resource_group_name
  allocation_method   = "Static"
  sku                 = "Standard"
  tags                = var.tags
}

resource "azurerm_nat_gateway" "nat" {
  count                   = var.create_nat_gateway ? 1 : 0
  name                    = "${var.project_name}-${var.environment}-nat"
  location                = var.location
  resource_group_name     = var.resource_group_name
  sku_name                = "Standard"
  idle_timeout_in_minutes = 10
  tags                    = var.tags
}

resource "azurerm_nat_gateway_public_ip_association" "nat_gateway_ip" {
  count                = var.create_nat_gateway ? 1 : 0
  nat_gateway_id       = azurerm_nat_gateway.nat[0].id
  public_ip_address_id = azurerm_public_ip.nat_gateway_ip[0].id
}

resource "azurerm_subnet_nat_gateway_association" "private_with_nat" {
  count          = var.create_nat_gateway ? 1 : 0
  subnet_id      = azurerm_subnet.private_subnet.id
  nat_gateway_id = azurerm_nat_gateway.nat[0].id
}

resource "azurerm_network_security_group" "private_subnet_nsg" {
  name                = "${var.project_name}-${var.environment}-nsg"
  location            = var.location
  resource_group_name = var.resource_group_name
  tags                = var.tags

  # Example rule: Allow all inbound traffic within the VNet
  security_rule {
    name                       = "AllowVnetInbound"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "*"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "VirtualNetwork"
    destination_address_prefix = "VirtualNetwork"
  }

  # Example rule: Deny all direct inbound from the internet
  security_rule {
    name                       = "DenyInternetInbound"
    priority                   = 400
    direction                  = "Inbound"
    access                     = "Deny"
    protocol                   = "*"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "Internet"
    destination_address_prefix = "*"
  }
}

resource "azurerm_subnet_network_security_group_association" "private_subnet" {
  subnet_id                 = azurerm_subnet.private_subnet.id
  network_security_group_id = azurerm_network_security_group.private_subnet_nsg.id
}

resource "azurerm_subnet" "private_isolated_subnet" {
  count = var.create_private_isolated_subnet ? 1 : 0
  name                 = "${var.project_name}-${var.environment}-private_isolated-subnet"
  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = [var.subnet_private_isolated_cidr]

  private_endpoint_network_policies = "Enabled"
  private_link_service_network_policies_enabled = false
}
resource "azurerm_network_security_group" "isolated_nsg" {
  name                = "${azurerm_subnet.private_isolated_subnet[0].name}-nsg"
  location            = var.location
  resource_group_name = var.resource_group_name

  # Example Rule: Allow ALL traffic within the VNet.
  # This is essential for internal communication (e.g., app tier to database).
  security_rule {
    name                       = "AllowVnetInbound"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "*"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "VirtualNetwork" # Traffic from within the VNet
    destination_address_prefix = "VirtualNetwork"
  }

  # Example Rule: Explicitly DENY all inbound traffic from the Internet.
  # This acts as a final, explicit block.
  security_rule {
    name                       = "DenyInternetInbound"
    priority                   = 400
    direction                  = "Inbound"
    access                     = "Deny"
    protocol                   = "*"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "Internet"
    destination_address_prefix = "*"
  }

  # Example Rule: Explicitly DENY all outbound traffic to the Internet.
  # This ensures nothing can call out, even if misconfigured.
  security_rule {
    name                       = "DenyInternetOutbound"
    priority                   = 400
    direction                  = "Outbound"
    access                     = "Deny"
    protocol                   = "*"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "*"
    destination_address_prefix = "Internet"
  }

  # You can add more rules to allow management traffic from a jumpbox subnet, etc.
}

# 3. Associate the NSG with the Isolated Subnet
resource "azurerm_subnet_network_security_group_association" "private_isolated" {
  subnet_id                 = azurerm_subnet.private_isolated_subnet[0].id
  network_security_group_id = azurerm_network_security_group.isolated_nsg.id
}

