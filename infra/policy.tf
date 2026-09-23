locals {
  builtin_policy = {
    allowed_locations    = "/providers/Microsoft.Authorization/policyDefinitions/e56962a6-4747-49cd-b67b-bf8b01975c4c"
    allowed_locations_rg = "/providers/Microsoft.Authorization/policyDefinitions/e765b5de-1225-4ba3-bd56-1ac6695af988"
    require_tag          = "/providers/Microsoft.Authorization/policyDefinitions/871b6d14-10aa-478d-b590-94f262ecfa99"
    not_allowed_types    = "/providers/Microsoft.Authorization/policyDefinitions/6c112d4e-5bc7-47ae-a041-ea2d9dccd749"
    secure_transfer      = "/providers/Microsoft.Authorization/policyDefinitions/404c3081-a854-4457-ae30-26a93ef643f9"
    activity_to_law      = "/providers/Microsoft.Authorization/policyDefinitions/2465583e-4e78-4c15-b6be-a36cbc7c8b0f"
  }

  required_tag_names = ["Environment", "Owner", "CostCenter"]
}

resource "azurerm_subscription_policy_assignment" "allowed_locations" {
  name                 = "deny-bad-regions"
  display_name         = "Régions autorisées : West Europe, France Central"
  policy_definition_id = local.builtin_policy.allowed_locations
  subscription_id      = data.azurerm_subscription.current.id

  parameters = jsonencode({
    listOfAllowedLocations = {
      value = var.allowed_locations
    }
  })
}

resource "azurerm_subscription_policy_assignment" "allowed_locations_rg" {
  name                 = "deny-rg-regions"
  display_name         = "Régions des resource groups autorisées"
  policy_definition_id = local.builtin_policy.allowed_locations_rg
  subscription_id      = data.azurerm_subscription.current.id

  parameters = jsonencode({
    listOfAllowedLocations = {
      value = var.allowed_locations
    }
  })
}

resource "azurerm_subscription_policy_assignment" "require_tag" {
  for_each = toset(local.required_tag_names)

  name                 = "req-tag-${substr(lower(each.value), 0, 12)}"
  display_name         = "Tag obligatoire : ${each.value}"
  policy_definition_id = local.builtin_policy.require_tag
  subscription_id      = data.azurerm_subscription.current.id

  parameters = jsonencode({
    tagName = {
      value = each.value
    }
  })
}

resource "azurerm_subscription_policy_assignment" "deny_public_ip" {
  count = var.enable_expensive_network ? 0 : 1

  name                 = "deny-public-ip"
  display_name         = "Interdiction des adresses IP publiques"
  policy_definition_id = local.builtin_policy.not_allowed_types
  subscription_id      = data.azurerm_subscription.current.id

  parameters = jsonencode({
    listOfResourceTypesNotAllowed = {
      value = ["Microsoft.Network/publicIPAddresses"]
    }
    effect = {
      value = "Deny"
    }
  })
}

resource "azurerm_subscription_policy_assignment" "secure_transfer" {
  name                 = "deny-http-storage"
  display_name         = "Chiffrement en transit : HTTPS obligatoire (Storage)"
  policy_definition_id = local.builtin_policy.secure_transfer
  subscription_id      = data.azurerm_subscription.current.id

  parameters = jsonencode({
    effect = {
      value = "Deny"
    }
  })
}

resource "azurerm_policy_definition" "nsg_diagnostics" {
  name         = "deploy-nsg-diagnostics"
  policy_type  = "Custom"
  mode         = "Indexed"
  display_name = "Déployer les diagnostic settings NSG vers Log Analytics"
  description  = "DeployIfNotExists : tout nouveau NSG envoie ses logs vers le workspace central."

  # Règle externalisée : la clé ARM "$schema" fait planter le parseur HCL de Checkov.
  policy_rule = file("${path.module}/policies/nsg-diagnostics.json")

  parameters = jsonencode({
    logAnalyticsId = {
      type = "String"
      metadata = {
        displayName = "Log Analytics workspace ID"
      }
    }
  })
}

resource "azurerm_subscription_policy_assignment" "nsg_diagnostics" {
  name                 = "dine-nsg-diag"
  display_name         = "Diagnostic settings NSG automatiques"
  policy_definition_id = azurerm_policy_definition.nsg_diagnostics.id
  subscription_id      = data.azurerm_subscription.current.id
  location             = local.location

  identity {
    type = "SystemAssigned"
  }

  parameters = jsonencode({
    logAnalyticsId = {
      value = azurerm_log_analytics_workspace.central.id
    }
  })
}

resource "azurerm_role_assignment" "policy_monitoring" {
  scope                = data.azurerm_subscription.current.id
  role_definition_name = "Monitoring Contributor"
  principal_id         = azurerm_subscription_policy_assignment.nsg_diagnostics.identity[0].principal_id
  principal_type       = "ServicePrincipal"
}

resource "azurerm_role_assignment" "policy_log_analytics" {
  scope                = azurerm_log_analytics_workspace.central.id
  role_definition_name = "Log Analytics Contributor"
  principal_id         = azurerm_subscription_policy_assignment.nsg_diagnostics.identity[0].principal_id
  principal_type       = "ServicePrincipal"
}

resource "azurerm_subscription_policy_assignment" "activity_to_law" {
  name                 = "dine-activity-log"
  display_name         = "Activity logs vers Log Analytics"
  policy_definition_id = local.builtin_policy.activity_to_law
  subscription_id      = data.azurerm_subscription.current.id
  location             = local.location

  identity {
    type = "SystemAssigned"
  }

  parameters = jsonencode({
    logAnalytics = {
      value = azurerm_log_analytics_workspace.central.id
    }
  })
}

resource "azurerm_role_assignment" "activity_policy" {
  scope                = data.azurerm_subscription.current.id
  role_definition_name = "Monitoring Contributor"
  principal_id         = azurerm_subscription_policy_assignment.activity_to_law.identity[0].principal_id
  principal_type       = "ServicePrincipal"
}
