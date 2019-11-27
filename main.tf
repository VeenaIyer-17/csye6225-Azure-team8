#Create resource group
resource "azurerm_resource_group" "resgroup" {
    name = var.resourcegroup_name
    location = var.resourcegroup_location
}

#Create Network
module "network" {
    source = "./modules/network"
    location1 = azurerm_resource_group.resgroup.location
    resource_group1 = azurerm_resource_group.resgroup.name
}

#Create VM
module "virtualmachine" {
    source = "./modules/virtualmachine"
    location2 = azurerm_resource_group.resgroup.location
    resource_group2 = azurerm_resource_group.resgroup.name
    
    subnet_id = module.network.subnet_id
    vmsize = var.vmsize
    os_ms = var.os_ms
    admin_username = var.admin_username
    admin_password = var.admin_password
    computer_name = var.computer_name_Windows
}


// resource "azurerm_route_table" "routeazure" {
//     name = "projRouteTable"
//     location = "${azurerm_resource_group.resgroup.location}"
//     resource_group_name = "${azurerm_resource_group.resgroup.name}"

//     route {
//         name = "routeTable"
//         address_prefix = "10.0.0.0/16"
//         next_hop_type = "vnetlocal"
//     }

//     tags = {
//         environment = "test"
//     }
// }

// resource "azurerm_route" "routetest" {
//     name = "acceptanceTestRoute1"
//     resource_group_name = "${azurerm_resource_group.resgroup.name}"
//     route_table_name = "${azurerm_route_table.routeazure.name}"
//     address_prefix = "10.0.1.0/16"
//     next_hop_type = "vnetLocal"
// }

// resource "azurerm_subnet_route_table_association" "association1" {
//     subnet_id = "${azurerm_subnet.subnet1.id}"
//     route_table_id = "${azurerm_route_table.routeazure.id}"
// }

// resource "azurerm_public_ip" "pubip" {
//     name = "publicip"
//     resource_group_name = "${azurerm_resource_group.resgroup.name}"
//     location = "${azurerm_resource_group.resgroup.location}"
//     allocation_method = "Dynamic"
// }

// resource "azurerm_virtual_network_gateway" "vng" {
//     name = "virtualnetworkgateway"
//     resource_group_name = "${azurerm_resource_group.resgroup.name}"
//     location = "${azurerm_resource_group.resgroup.location}"
//     type = "Vpn"
//     sku = "Basic"
//     ip_configuration {
//         name = "vnetgateway1"
//         public_ip_address_id = "${azurerm_public_ip.pubip.id}"
//         subnet_id = "${azurerm_subnet.subnet1.id}"
//     }
// }

// resource "azurerm_local_network_gateway" "lng" {
//     name = "localnetworkgateway"
//     resource_group_name = "${azurerm_resource_group.resgroup.name}"
//     location = "${azurerm_resource_group.resgroup.location}"
//     gateway_address = "12.13.14.15"
//     address_space = ["10.0.0.0/16"]
// }

// resource "azurerm_virtual_network_gateway_connection" "vgnconn" {
//     name = "onpremises"
//     resource_group_name = "${azurerm_resource_group.resgroup.name}"
//     location = "${azurerm_resource_group.resgroup.location}"

//     type = "IPsec"
//     virtual_network_gateway_id = "${azurerm_virtual_network_gateway.vng.id}"
//     local_network_gateway_id = "${azurerm_local_network_gateway.lng.id}"
// }
    