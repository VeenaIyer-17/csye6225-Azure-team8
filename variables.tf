variable "resourcegroup_name" {
    description = "Name for resource group"
    type = string 
}

variable "resourcegroup_location" {
    description = "Location for resource group"
    type = string
    default = "westus2"
}

variable "admin_username" {
    default = "testadmin"
}

variable "admin_password" {
    default = "Password1234!"
}

variable "computer_name_Windows" {
    default = "WS01"
}

variable "vmsize" {
    description = "VM Size for the Production Environment"
    type = "map"
    default = {
        small = "Standard_DS1_v2"
        medium = "Standard_D2s_v3"
        large = "Standard_D4s_v3"
        extralarge = "Standard_D8s_v3"
    }
}

variable "os_ms" {
    description = "Operating System for Database (MSSQL) on the Production Environment"
    type = "map"
    default = {
        publisher = "MicrosoftWindowsServer"
        offer = "WindowsServer"
        sku = "2019-Datacenter"
        version = "latest"
    }
}