#Create virtual network
resource "azurerm_virtual_network" "vnet" {
    name = "vnetvpc"
    address_space = ["10.0.0.0/8"]
    location = var.location1
    resource_group_name = var.resource_group1
}

#Create subnet
resource "azurerm_subnet" "subnet" {
    name = "LAN"
    resource_group_name = var.resource_group1
    virtual_network_name = azurerm_virtual_network.vnet.name
    address_prefix = "10.0.0.0/24"
}