#Create virtual network
resource "azurerm_virtual_network" "vnet" {
    name                = "vnetvpc"
    address_space       = ["10.0.0.0/8"]
    location            = var.location1
    resource_group_name = var.resource_group1
}

#Create subnet
resource "azurerm_subnet" "subnet" {
    name = "LAN"
    resource_group_name     = var.resource_group1
    virtual_network_name    = azurerm_virtual_network.vnet.name
    address_prefix          = "10.0.0.0/24"
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