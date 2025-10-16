# أساسيات
prefix              = "abdullah"
resource_group_name = "Abdullah-rg"
location            = "westus2"
environment         = "prod"

# Network Configuration
vnet_address_space = ["10.2.0.0/16"]
agw_subnet_cidr    = "10.2.1.0/24"
aca_subnet_cidr    = "10.2.2.0/23"
pe_subnet_cidr     = "10.2.4.0/24"

# Resource Names
aca_environment_name         = "aca-env-abdullah"
app_gateway_name             = "agw-abdullah-burgerbuilder"
log_analytics_workspace_name = "law-abdullah-burgerbuilder"

# SQL Configuration
sql_server_name   = "sql-abdullah-burgerbuilder"
sql_database_name = "sqldb-abdullah-burgerbuilder"
sql_admin_login   = "abdullah-admin"

# Docker Hub
dockerhub_org  = "youkim7"
dockerhub_user = "youkim7"

# Image Tags
fe_image_tag  = "dev-003"
api_image_tag = "dev-001"

# Tags
tags = {
  Environment = "Production"
  Project     = "AbdullahBurgerBuilder"
  Owner       = "Abdullah"
}
