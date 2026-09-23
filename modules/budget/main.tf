resource "azurerm_consumption_budget_subscription" "this" {
  count = var.scope == "subscription" ? 1 : 0

  name            = var.name
  subscription_id = var.subscription_id
  amount          = var.amount
  time_grain      = "Monthly"

  time_period {
    start_date = var.start_date
  }

  dynamic "notification" {
    for_each = var.thresholds
    content {
      enabled        = true
      threshold      = notification.value
      operator       = "GreaterThan"
      threshold_type = "Actual"
      contact_emails = var.contact_emails
    }
  }
}

resource "azurerm_consumption_budget_resource_group" "this" {
  count = var.scope == "resource_group" ? 1 : 0

  name              = var.name
  resource_group_id = var.resource_group_id
  amount            = var.amount
  time_grain        = "Monthly"

  time_period {
    start_date = var.start_date
  }

  dynamic "notification" {
    for_each = var.thresholds
    content {
      enabled        = true
      threshold      = notification.value
      operator       = "GreaterThan"
      threshold_type = "Actual"
      contact_emails = var.contact_emails
    }
  }
}
