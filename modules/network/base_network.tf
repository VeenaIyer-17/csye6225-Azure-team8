#Create virtual network
resource "azurerm_virtual_network" "vnet" {
    name                = "vnetvpc"
    address_space       = ["10.0.0.0/8"]
    location            = var.location1
    resource_group_name = var.resource_group1
}

#Create subnet
resource "azurerm_subnet" "subnet" {
    name                    = "sub"
    resource_group_name     = var.resource_group1
    virtual_network_name    = azurerm_virtual_network.vnet.name
    address_prefix          = "10.0.1.0/24"
}

resource "azurerm_public_ip" "pubIp" {
    location = var.location1
    name = "pubIp"
    resource_group_name = var.resource_group1
    allocation_method       = "Dynamic"
    idle_timeout_in_minutes = 10

    tags = {
        environment = "prod"
    }
}

resource "azurerm_public_ip" "publicStdIp" {
    location = var.location1
    name = "pubStdIp"
    resource_group_name = var.resource_group1
    allocation_method       = "Static"
    sku                     = "Standard"
    idle_timeout_in_minutes = 10

    tags = {
        environment = "prod"
    }
}

resource "azurerm_subnet" "subnet1" {
    name                    = "GatewaySubnet"
    resource_group_name     = var.resource_group1
    virtual_network_name    = azurerm_virtual_network.vnet.name
    address_prefix          = "10.0.0.0/24"
}


resource "azurerm_subnet" "subnetfirewall" {
  name                 = "AzureFirewallSubnet"
  resource_group_name  = var.resource_group1
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefix       = "10.0.2.0/24"
}

resource "azurerm_route_table" "routeazure" {
    name                = "projRouteTable"
    location            = var.location1
    resource_group_name = var.resource_group1

    route {
        name            = "routeTable"
        address_prefix  = "10.0.0.0/16"
        next_hop_type   = "vnetlocal"
    }

    tags = {
        environment     = "test"
    }
}

resource "azurerm_route" "routetest" {
    name                = "acceptanceTestRoute1"
    resource_group_name = var.resource_group1
    route_table_name    = "${azurerm_route_table.routeazure.name}"
    address_prefix      = "10.0.0.0/24"
    next_hop_type       = "vnetLocal"
}

resource "azurerm_subnet_route_table_association" "association1" {
    subnet_id       = "${azurerm_subnet.subnet.id}"
    route_table_id  = "${azurerm_route_table.routeazure.id}"
}

resource "azurerm_network_security_group" "networksecuritygroup" {
  name                = "acceptanceTestSecurityGroup1"
  location            = var.location1
  resource_group_name = var.resource_group1
}

resource "azurerm_network_security_rule" "example" {
  name                        = "testingsecuritygrouprule"
  priority                    = 100
  direction                   = "Outbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "*"
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
  resource_group_name         = var.resource_group1
  network_security_group_name = "${azurerm_network_security_group.networksecuritygroup.name}"
}

resource "azurerm_virtual_network_gateway" "ig" {
    name                      = "igTest"
    location                  = var.location1
    resource_group_name       = var.resource_group1
    type                      = "Vpn"
    sku                       = "Basic"

    ip_configuration {
        name                          = "vnetGatewayConfig"
        subnet_id                     = "${azurerm_subnet.subnet1.id}"
        private_ip_address_allocation = "Dynamic"
        public_ip_address_id          = "${azurerm_public_ip.pubIp.id}"
    }
}

resource "azurerm_firewall" "waf" {
   name                = "waffirewall"
   location            = var.location1
   resource_group_name = var.resource_group1

   ip_configuration {
     name                 = "configuration"
     subnet_id            = "${azurerm_subnet.subnetfirewall.id}"
     public_ip_address_id = "${azurerm_public_ip.publicStdIp.id}"
   }
}