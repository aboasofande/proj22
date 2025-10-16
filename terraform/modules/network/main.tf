# Virtual Network
resource "azurerm_virtual_network" "main" {
  name                = "vnet-${var.environment}"
  address_space       = var.vnet_address_space
  location            = var.location
  resource_group_name = var.resource_group_name
  tags                = var.tags
}

# Application Gateway Subnet
resource "azurerm_subnet" "agw" {
  name                 = "subnet-agw"
  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.main.name
  address_prefixes     = [var.agw_subnet_cidr]
}

# Container Apps Subnet (قديمة/AKS — نتركها كما هي)
resource "azurerm_subnet" "aca" {
  name                 = "subnet-aca"
  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.main.name
  address_prefixes     = [var.aca_subnet_cidr]

  # Temporarily disabled to allow recreation with new naming
  # lifecycle {
  #   prevent_destroy = true
  #   ignore_changes = [
  #     address_prefixes,
  #     delegation,
  #     service_endpoints,
  #     private_endpoint_network_policies_enabled,
  #     private_link_service_network_policies_enabled,
  #   ]
  # }
}

# ✅ Subnet جديدة لبيئة ACA بدون تفويض - سيتم إضافته تلقائياً من Container Apps Environment
resource "azurerm_subnet" "aca_ca" {
  name                 = "subnet-aca-ca"
  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.main.name
  address_prefixes     = [var.aca_ca_subnet_cidr]

  # Delegation will be added automatically by Container Apps Environment
}

# Private Endpoints Subnet
resource "azurerm_subnet" "pe" {
  name                 = "subnet-pe"
  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.main.name
  address_prefixes     = [var.pe_subnet_cidr]
}

# Network Security Group for Application Gateway
resource "azurerm_network_security_group" "agw" {
  name                = "nsg-agw-${var.environment}"
  location            = var.location
  resource_group_name = var.resource_group_name
  tags                = var.tags

  security_rule {
    name                       = "AllowHTTPSInbound"
    priority                   = 1000
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "443"
    source_address_prefix      = "Internet"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "AllowHTTPInbound"
    priority                   = 1010
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "80"
    source_address_prefix      = "Internet"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "AllowAGWManagement"
    priority                   = 1020
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "65200-65535"
    source_address_prefix      = "GatewayManager"
    destination_address_prefix = "*"
  }

  security_rule {
    name                    = "AllowToContainerApps"
    priority                = 1000
    direction               = "Outbound"
    access                  = "Allow"
    protocol                = "Tcp"
    source_port_range       = "*"
    destination_port_ranges = ["80", "8080", "443"]
    source_address_prefix   = "*"
    # نخليها على السابنت القديمة لأن الـ AGW يوجّه داخليًا عبر FQDNs،
    # ولو ودّك تضم الجديدة برضه، خليه VirtualNetwork أحسن:
    destination_address_prefix = "VirtualNetwork"
  }
}

# Associate NSG with Application Gateway subnet
resource "azurerm_subnet_network_security_group_association" "agw" {
  subnet_id                 = azurerm_subnet.agw.id
  network_security_group_id = azurerm_network_security_group.agw.id
}

# Network Security Group for Container Apps
resource "azurerm_network_security_group" "aca" {
  name                = "nsg-aca-${var.environment}"
  location            = var.location
  resource_group_name = var.resource_group_name
  tags                = var.tags

  security_rule {
    name                       = "AllowAGWToContainerApps"
    priority                   = 1000
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_ranges    = ["80", "8080", "443"]
    source_address_prefix      = var.agw_subnet_cidr
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "AllowVnetInbound"
    priority                   = 1010
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "*"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "VirtualNetwork"
    destination_address_prefix = "VirtualNetwork"
  }

  # Allow Azure Load Balancer health checks
  security_rule {
    name                       = "AllowAzureLoadBalancer"
    priority                   = 1020
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "*"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "AzureLoadBalancer"
    destination_address_prefix = "*"
  }
}

# Associate NSG with Container Apps subnet (القديمة)
resource "azurerm_subnet_network_security_group_association" "aca" {
  subnet_id                 = azurerm_subnet.aca.id
  network_security_group_id = azurerm_network_security_group.aca.id
}

# ✅ Associate NSG with the new ACA Environment subnet
resource "azurerm_subnet_network_security_group_association" "aca_ca" {
  subnet_id                 = azurerm_subnet.aca_ca.id
  network_security_group_id = azurerm_network_security_group.aca.id
}
