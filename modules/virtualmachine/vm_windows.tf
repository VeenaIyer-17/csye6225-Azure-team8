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

resource "azurerm_public_ip" "instancePublicIp" {
  location = var.location2
  name = "publicIp"
  resource_group_name = var.resource_group2
  allocation_method       = "Dynamic"
  idle_timeout_in_minutes = 10

  tags = {
    environment = "prod"
  }
}

resource "azurerm_lb" "lb" {
  resource_group_name = var.resource_group2
  name = "${var.resource_group2}_lb"
  location = var.location2

  frontend_ip_configuration {
    name = "LoadBalancerFrontEnd"
    public_ip_address_id = azurerm_public_ip.publicIp.id
  }
}

resource "azurerm_lb_backend_address_pool" "backend_pool" {
  resource_group_name = var.resource_group2
  loadbalancer_id     = "${azurerm_lb.lb.id}"
  name                = "BackendPool1"
}

resource "azurerm_lb_nat_pool" "nat_pool" {
  resource_group_name            = var.resource_group2
  loadbalancer_id                = "${azurerm_lb.lb.id}"
  name                           = "SampleApplicationPool"
  protocol                       = "Tcp"
  frontend_port_start            = 442
  frontend_port_end              = 448
  backend_port                   = 8080
  frontend_ip_configuration_name = "LoadBalancerFrontEnd"
}

resource "azurerm_lb_rule" "lb_rule" {
  resource_group_name            = var.resource_group2
  loadbalancer_id                = "${azurerm_lb.lb.id}"
  name                           = "LBRule"
  protocol                       = "tcp"
  frontend_port                  = 80
  backend_port                   = 80
  frontend_ip_configuration_name = "LoadBalancerFrontEnd"
  enable_floating_ip             = false
  backend_address_pool_id        = "${azurerm_lb_backend_address_pool.backend_pool.id}"
  idle_timeout_in_minutes        = 5
  //  probe_id                       = "${azurerm_lb_probe.lb_probe.id}"
  //  depends_on                     = ["azurerm_lb_probe.lb_probe"]
}


resource "azurerm_virtual_machine_scale_set" "example" {
  name                = "mytestscaleset-1"
  location            = var.location2
  resource_group_name = var.resource_group2

  upgrade_policy_mode  = "Manual"


  sku {
    name     = "Standard_F2"
    tier     = "Standard"
    capacity = 2
  }

  storage_profile_image_reference {
        publisher = "Canonical"
        offer     = "UbuntuServer"
        sku       = "16.04-LTS"
        version   = "latest"
  }

  storage_profile_os_disk {
    name              = ""
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Standard_LRS"
  }

  storage_profile_data_disk {
    lun           = 0
    caching       = "ReadWrite"
    create_option = "Empty"
    disk_size_gb  = 10
  }

  os_profile {
    computer_name_prefix = "testvm"
    admin_username       = "myadmin"
  }

  os_profile_linux_config {
    disable_password_authentication = true

    ssh_keys {
      path     = "/home/myadmin/.ssh/authorized_keys"
      key_data = "${file("~/.ssh/id_rsa.pub")}"
    }
  }

  network_profile {
    name    = "terraformnetworkprofile"
    primary = true

    ip_configuration {
      name                                   = "TestIPConfiguration"
      primary                                = true
      subnet_id                              = var.subnet_id
      load_balancer_backend_address_pool_ids = ["${azurerm_lb_backend_address_pool.backend_pool.id}"]
      load_balancer_inbound_nat_rules_ids    = ["${azurerm_lb_nat_pool.nat_pool.id}"]
    }
  }

  tags = {
    environment = "staging"
  }
}

resource "azurerm_autoscale_setting" "myAutoscaleSetting" {
  location = var.location2
  name = "myAutoscaleSetting"
  resource_group_name = var.resource_group2
  target_resource_id = "${azurerm_virtual_machine_scale_set.example.id}"
  profile {
    name = "defaultProfile"
    capacity {
      default = 2
      maximum = 5
      minimum = 2
    }
    rule {
      metric_trigger {
        metric_name        = "Percentage CPU"
        metric_resource_id = "${azurerm_virtual_machine_scale_set.example.id}"
        time_grain         = "PT1M"
        statistic          = "Average"
        time_window        = "PT5M"
        time_aggregation   = "Average"
        operator           = "GreaterThan"
        threshold          = 5
      }
      scale_action {
        direction = "Increase"
        type      = "ChangeCount"
        value     = "1"
        cooldown  = "PT1M"
      }
    }
    rule {
      metric_trigger {
        metric_name        = "Percentage CPU"
        metric_resource_id = "${azurerm_virtual_machine_scale_set.example.id}"
        time_grain         = "PT1M"
        statistic          = "Average"
        time_window        = "PT5M"
        time_aggregation   = "Average"
        operator           = "LessThan"
        threshold          = 3
      }

      scale_action {
        direction = "Decrease"
        type      = "ChangeCount"
        value     = "1"
        cooldown  = "PT1M"
      }
    }
  }
}


//resource "azurerm_network_interface" "windows_nic" {
//    name = "NIC"
//    location = var.location2
//    resource_group_name = var.resource_group2
//    ip_configuration {
//        name = "ipconfig"
//        subnet_id = var.subnet_id
//        private_ip_address_allocation = "Dynamic"
//        public_ip_address_id = azurerm_public_ip.publicIp.id
//    }
//}

//resource "azurerm_virtual_machine" "windows_vm" {
//    name = var.computer_name
//    location = var.location2
//    resource_group_name = var.resource_group2
//    network_interface_ids = [azurerm_network_interface.windows_nic.id]
//    vm_size = var.vmsize["small"]
//    delete_os_disk_on_termination = true
//    delete_data_disks_on_termination = true
//
//    storage_image_reference {
//        publisher = var.os_ms["publisher"]
//        offer = var.os_ms["offer"]
//        sku = var.os_ms["sku"]
//        version = var.os_ms["version"]
//    }
//
//    storage_os_disk {
//        name = "OS"
//        caching = "ReadWrite"
//        create_option = "FromImage"
//        managed_disk_type = "Standard_LRS"
//    }
//
//    os_profile {
//        computer_name = var.computer_name
//        admin_username = var.admin_username
//        admin_password = var.admin_password
//    }
//
//    os_profile_windows_config {
//        provision_vm_agent = "true"
//        timezone = "Romance Standard Time"
//    }
//
//}

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
    name                = "cosmosdb-${random_integer.ri.result}"
    location            = var.location2
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

// resource "azurerm_monitor_metric_alertrule" "cloudwatch" {
//     name                        = "${azurerm_virtual_machine.windows_vm.name}-cpu"
//     location                    =  var.location2
//     resource_group_name         =  var.resource_group2
//     description                 = "An alert rule to watch the metric Percentage CPU"
//     enabled                     = true

//     resource_id                 = "${azurerm_virtual_machine.windows_vm.id}"
//     metric_name                 = "Percentage CPU"
//     operator                    = "GreaterThan"
//     threshold                   = 75
//     aggregation                 = "Average"
//     period                      = "PT5M"
// }

resource "azurerm_monitor_action_group" "main" {
  name                          = "example-actiongroup"
  resource_group_name           = var.resource_group2
  short_name                    = "exampleact"

//   webhook_receiver {
//     name                        = "callmyapi"
//     service_uri                 = "http://example.com/alert"
//   }
}

resource "azurerm_monitor_metric_alert" "example" {
  name                = "example-metricalert"
  resource_group_name = var.resource_group2
  scopes              = ["${azurerm_storage_account.storage.id}"]
  description         = "Action will be triggered when Transactions count is greater than 50."

  criteria {
    metric_namespace = "Microsoft.Storage/storageAccounts"
    metric_name      = "Transactions"
    aggregation      = "Total"
    operator         = "GreaterThan"
    threshold        = 50

    dimension {
      name     = "ApiName"
      operator = "Include"
      values   = ["*"]
    }
  }

  action {
    action_group_id = "${azurerm_monitor_action_group.main.id}"
  }
}