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
    
    resource_group_name=var.resource_group_name
    packer_image = var.packer_image
    subnet_id = module.network.subnet_id
    vmsize = var.vmsize
    os_ms = var.os_ms
    admin_username = var.admin_username
    admin_password = var.admin_password
    computer_name = var.computer_name_Windows
}

#Lambda module
module "lambda" {
    source = "./modules/Lambda"

    filepath = var.lambda_filepath
}