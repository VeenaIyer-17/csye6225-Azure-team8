resource "azurerm_public_ip" "publicIp" {
    location = var.location2
    name = "publicIp"
    resource_group_name = var.resource_group2
    allocation_method       = "Dynamic"
    idle_timeout_in_minutes = 10

    tags = {
        environment = "prod"
    }
}

resource "azurerm_network_interface" "windows_nic" {
    name = "NIC"
    location = var.location2
    resource_group_name = var.resource_group2
    ip_configuration {
        name = "ipconfig"
        subnet_id = var.subnet_id
        private_ip_address_allocation = "Dynamic"
        public_ip_address_id = azurerm_public_ip.publicIp.id
    }
}

resource "azurerm_virtual_machine" "windows_vm" { 
    name = var.computer_name
    location = var.location2
    resource_group_name = var.resource_group2
    network_interface_ids = [azurerm_network_interface.windows_nic.id]
    vm_size = var.vmsize["small"]
    delete_os_disk_on_termination = true
    delete_data_disks_on_termination = true
    
    storage_image_reference {
        publisher = var.os_ms["publisher"]
        offer = var.os_ms["offer"]
        sku = var.os_ms["sku"]
        version = var.os_ms["version"]
    }
 
    storage_os_disk {
        name = "OS"
        caching = "ReadWrite"
        create_option = "FromImage"
        managed_disk_type = "Standard_LRS"
    }

    os_profile {
        computer_name = var.computer_name
        admin_username = var.admin_username
        admin_password = var.admin_password
    }
 
    os_profile_windows_config {
        provision_vm_agent = "true"
        timezone = "Romance Standard Time"
    }
 
}

resource "azurerm_mariadb_server" "mdbserver" {
    name    = "mariadbserver"
    location = var.location2
    resource_group_name = var.resource_group2

    sku {
        name = "B_Gen5_2"
        capacity = 2
        tier = "Basic"
        family = "Gen5"
    } 

    storage_profile {
        storage_mb  = 51200
        backup_retention_days = 7
        geo_redundant_backup  = "Disabled"
    }

    administrator_login          = "csye6225azure"
    administrator_login_password = "csye6225@Azure!"
    version                      = "10.2"
    ssl_enforcement              = "Enabled"
}

resource "azurerm_mariadb_database" "mdb" {
    name                = "mariadb"
    resource_group_name = var.resource_group2
    server_name         = "${azurerm_mariadb_server.mdbserver.name}"
    charset             = "utf8"
    collation           = "utf8_general_ci"
}

resource "random_integer" "ri" {
  min = 10000
  max = 99999
}

resource "azurerm_cosmosdb_account" "dynamodb" {
    name    = "cosmosdb-${random_integer.ri.result}"
    location = var.location2
    resource_group_name = var.resource_group2

    offer_type          = "Standard"
    kind                = "GlobalDocumentDB"

    enable_automatic_failover = true

    consistency_policy {
        consistency_level       = "BoundedStaleness"
        max_interval_in_seconds = 10
        max_staleness_prefix    = 200
    }

    geo_location {
        location          = var.location2
        failover_priority = 0
    }
}

resource "azurerm_storage_account" "storage" {
    name                     = "csye6225storageazure"
    resource_group_name      = var.resource_group2
    location                 = var.location2
    account_tier             = "Standard"
    account_replication_type = "LRS"
}

resource "azurerm_storage_container" "storagecontainer" {
    name                    = "csye6225content"
    storage_account_name    = "${azurerm_storage_account.storage.name}"
    container_access_type   = "private" 
}

resource "azurerm_storage_blob" "blobstorage" {
    name                    = "index.zip"
    storage_account_name    = "${azurerm_storage_account.storage.name}"
    storage_container_name  = "${azurerm_storage_container.storagecontainer.name}"
    type                    = "Block"
}

resource "azurerm_app_service_plan" "serviceplan" {
    name                    = "azure-functions-test-service-plan"
    location                =  var.location2
    resource_group_name     = var.resource_group2

    sku {
        tier = "Standard"
        size = "S1"
    }
}

resource "azurerm_function_app" "lambdafunction" {
    name                        = "azurefunction-${random_integer.ri.result}"
    location                    =  var.location2
    resource_group_name         =  var.resource_group2
    app_service_plan_id         = "${azurerm_app_service_plan.serviceplan.id}"
    storage_connection_string   = "${azurerm_storage_account.storage.primary_connection_string}"
}