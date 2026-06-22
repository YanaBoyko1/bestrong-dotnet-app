resource "azurerm_service_plan" "app_plan" {
  name                = "asp-${var.project_name}-001"
  resource_group_name = azurerm_resource_group.rg.name
  location            = var.location

  os_type  = "Linux"
  sku_name = var.app_service_sku
}

resource "azurerm_linux_web_app" "web_app" {
  name                = "app-${var.project_name}-001"
  resource_group_name = azurerm_resource_group.rg.name
  location            = var.location
  service_plan_id     = azurerm_service_plan.app_plan.id

  # Enables System-Assigned Managed Identity for secure passwordless authentication
  identity {
    type = "SystemAssigned"
  }

  site_config {
    # Keeps the container warm and running constantly to prevent cold starts
    always_on = true

    app_command_line = "cd /tmp && dotnet /usr/app/DotNetCrudWebApi.dll"

    application_stack {
      docker_image_name        = var.docker_image_name
      docker_registry_url      = "https://${azurerm_container_registry.acr.login_server}"
      docker_registry_username = azurerm_container_registry.acr.admin_username
      docker_registry_password = azurerm_container_registry.acr.admin_password
    }
  }

  app_settings = {
    # Converts the numerical target container application port into a valid Azure string value
    "WEBSITES_PORT"                        = tostring(var.app_port)
    "ASPNETCORE_ENVIRONMENT"              = "Development"
    "WEBSITES_ENABLE_APP_SERVICE_STORAGE" = "true"
    "ConnectionStrings__MovieContext"     = "Server=tcp:${azurerm_mssql_server.sql_server.fully_qualified_domain_name},1433;Initial Catalog=${azurerm_mssql_database.sql_db.name};Persist Security Info=False;User ID=${var.sql_admin_login};Password=@Microsoft.KeyVault(SecretUri=${azurerm_key_vault_secret.sql_pass_secret.id});MultipleActiveResultSets=True;Encrypt=True;TrustServerCertificate=False;Connection Timeout=30;"
    # Application performance monitoring credentials (Log Analytics & Application Insights telemetry)
    "APPINSIGHTS_INSTRUMENTATIONKEY"        = azurerm_application_insights.app_insights.instrumentation_key
    "APPLICATIONINSIGHTS_CONNECTION_STRING" = azurerm_application_insights.app_insights.connection_string
  }
}

resource "azurerm_app_service_virtual_network_swift_connection" "vnet_integration" {
  app_service_id = azurerm_linux_web_app.web_app.id
  subnet_id      = module.avm-res-network-virtualnetwork.subnets["subnet1"].resource_id
}