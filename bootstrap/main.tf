data "azurerm_subscription" "current" {}

resource "random_string" "sa" {
  length  = 6
  upper   = false
  special = false
}

# Garde-fou n°1 : alerte budget AVANT toute autre ressource coûteuse.
module "subscription_budget" {
  source = "../modules/budget"

  name            = "${var.org_prefix}-budget-subscription"
  scope           = "subscription"
  subscription_id = data.azurerm_subscription.current.id
  amount          = var.budget_amount
  start_date      = var.budget_start_date
  contact_emails  = var.budget_alert_emails
}

resource "azurerm_resource_group" "tfstate" {
  name     = "rg-${var.org_prefix}-tfstate-weu"
  location = var.location
  tags     = var.required_tags
}

resource "azurerm_storage_account" "tfstate" {
  name                            = "${var.org_prefix}tfstate${random_string.sa.result}"
  resource_group_name             = azurerm_resource_group.tfstate.name
  location                        = azurerm_resource_group.tfstate.location
  account_tier                    = "Standard"
  account_replication_type        = "LRS"
  min_tls_version                 = "TLS1_2"
  https_traffic_only_enabled      = true
  allow_nested_items_to_be_public = false
  shared_access_key_enabled       = true
  local_user_enabled              = false

  blob_properties {
    versioning_enabled = true
    delete_retention_policy {
      days = 7
    }
  }

  tags = var.required_tags
}

resource "azurerm_storage_container" "tfstate" {
  name                  = "tfstate"
  storage_account_id    = azurerm_storage_account.tfstate.id
  container_access_type = "private"
}

resource "local_file" "backend_hcl" {
  filename = "${path.module}/../infra/backend.hcl"
  content  = <<-HCL
    resource_group_name  = "${azurerm_resource_group.tfstate.name}"
    storage_account_name = "${azurerm_storage_account.tfstate.name}"
    container_name       = "${azurerm_storage_container.tfstate.name}"
    key                  = "socle-azure.tfstate"
  HCL
}
