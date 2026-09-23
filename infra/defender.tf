resource "azurerm_security_center_contact" "this" {
  name  = "default"
  email = var.security_contact_email

  alert_notifications = true
  alerts_to_admins    = true
}

resource "azurerm_security_center_subscription_pricing" "cloud_posture" {
  tier          = "Free"
  resource_type = "CloudPosture"
}

resource "azurerm_security_center_subscription_pricing" "storage" {
  count = var.enable_defender_standard ? 1 : 0

  tier          = "Standard"
  resource_type = "StorageAccounts"
}

resource "azurerm_security_center_subscription_pricing" "servers" {
  count = var.enable_defender_standard ? 1 : 0

  tier          = "Standard"
  resource_type = "VirtualMachines"
}
