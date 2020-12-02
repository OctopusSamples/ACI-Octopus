provider "azurerm" {
  version = "<=2.36.0"

  features {}
}

resource "azurerm_storage_account" "aci-storage" {
  name                = var.storageAccountName
  resource_group_name = var.RG
  location            = var.location
  account_tier        = "Standard"

  account_replication_type = "LRS"
}

resource "azurerm_storage_share" "tasklog-share" {
  name                 = "tasklog-share"
  storage_account_name = azurerm_storage_account.aci-storage.name

  depends_on = [azurerm_storage_account.aci-storage]
}

resource "azurerm_storage_share" "artifact-share" {
  name                 = "artifact-share"
  storage_account_name = azurerm_storage_account.aci-storage.name

  depends_on = [azurerm_storage_account.aci-storage]
}

resource "azurerm_storage_share" "repository-share" {
  name                 = "repository-share"
  storage_account_name = azurerm_storage_account.aci-storage.name

  depends_on = [azurerm_storage_account.aci-storage]
}

resource "azurerm_mssql_server" "octopussqlserver" {
  name                         = "octopussqlprod"
  resource_group_name          = var.RG
  location                     = var.location
  version                      = "12.0"
  administrator_login          = var.sqlLogin
  administrator_login_password = var.dbpassword
  minimum_tls_version          = "1.2"
}

resource "azurerm_sql_firewall_rule" "acifirewallrule" {
  name                = "azurecontainerinstanceconnection"
  resource_group_name = var.RG
  server_name         = azurerm_mssql_server.octopussqlserver.name
  start_ip_address    = "0.0.0.0"
  end_ip_address      = "0.0.0.0"

  depends_on = [azurerm_mssql_server.octopussqlserver]
}

resource "azurerm_mssql_database" "octopussqldb" {
  name           = "octopusdb"
  server_id      = azurerm_mssql_server.octopussqlserver.id
  license_type   = "LicenseIncluded"
  max_size_gb    = 4
  read_scale     = true
  sku_name       = "BC_Gen5_2"
  zone_redundant = true
}

resource "azurerm_container_group" "octopusdeploy" {
  name                = "octopusdeploy"
  location            = var.location
  resource_group_name = var.RG
  ip_address_type     = "public"
  dns_name_label      = "octopusdeploydns"
  os_type             = "Linux"

  container {
    name   = "octopus"
    image  = "octopusdeploy/octopusdeploy:latest"
    cpu    = "0.5"
    memory = "1.5"

    ports {
      port     = 8080
      protocol = "TCP"
    }

    volume {
      name       = "tasklogs"
      mount_path = "/taskLogs"
      read_only  = false
      share_name = azurerm_storage_share.tasklog-share.name

      storage_account_name = azurerm_storage_account.aci-storage.name
      storage_account_key  = azurerm_storage_account.aci-storage.primary_access_key
    }

    volume {
      name       = "artifacts"
      mount_path = "/artifacts"
      read_only  = false
      share_name = azurerm_storage_share.artifact-share.name

      storage_account_name = azurerm_storage_account.aci-storage.name
      storage_account_key  = azurerm_storage_account.aci-storage.primary_access_key
    }

    volume {
      name       = "repository"
      mount_path = "/repository"
      read_only  = false
      share_name = azurerm_storage_share.repository-share.name

      storage_account_name = azurerm_storage_account.aci-storage.name
      storage_account_key  = azurerm_storage_account.aci-storage.primary_access_key
    }

    environment_variables = {
      "ACCEPT_EULA"          = "Y",
      "ADMIN_USERNAME"       = var.octopusUser,
      "ADMIN_PASSWORD"       = var.octopusPassword,
      "DB_CONNECTION_STRING" = "Server=tcp:${azurerm_mssql_server.octopussqlserver.name}.database.windows.net,1433;Initial Catalog=${azurerm_mssql_database.octopussqldb.name};Persist Security Info=False;User ID=mike;Password=${var.dbpassword};MultipleActiveResultSets=False;Encrypt=True;TrustServerCertificate=False;Connection Timeout=30;",
      "MASTER_KEY"           = var.databaseMasterKey
    }
  }

  depends_on = [azurerm_mssql_database.octopussqldb]
}
