output "budget_id" {
  value       = module.subscription_budget.id
  description = "Budget d'abonnement créé en premier."
}

output "tfstate_resource_group" {
  value = azurerm_resource_group.tfstate.name
}

output "tfstate_storage_account" {
  value = azurerm_storage_account.tfstate.name
}

output "tfstate_container" {
  value = azurerm_storage_container.tfstate.name
}

output "next_step" {
  value = "cd ../infra && terraform init -backend-config=backend.hcl"
}
