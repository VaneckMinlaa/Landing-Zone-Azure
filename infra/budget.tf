# Budgets par resource group. Le budget d'abonnement est créé en premier dans bootstrap/.
module "budget_rg" {
  for_each = azurerm_resource_group.this
  source   = "../modules/budget"

  name              = "${local.prefix}-budget-${each.key}"
  scope             = "resource_group"
  subscription_id   = data.azurerm_subscription.current.id
  resource_group_id = each.value.id
  amount            = var.rg_budget_amount
  start_date        = var.budget_start_date
  contact_emails    = var.budget_alert_emails
}
