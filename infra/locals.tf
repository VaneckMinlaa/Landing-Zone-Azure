data "azurerm_subscription" "current" {}

locals {
  prefix   = var.org_name
  location = var.location

  tags = merge(var.required_tags, {
    ManagedBy = "terraform"
    Project   = "socle-azure"
  })

  resource_groups = {
    identity = {
      name = "rg-${local.prefix}-identity-weu"
      role = "platform"
    }
    connectivity = {
      name = "rg-${local.prefix}-connectivity-weu"
      role = "platform"
    }
    management = {
      name = "rg-${local.prefix}-management-weu"
      role = "platform"
    }
    lz_dev = {
      name = "rg-${local.prefix}-lz-dev-weu"
      role = "landing-zone-dev"
    }
    lz_prod = {
      name = "rg-${local.prefix}-lz-prod-weu"
      role = "landing-zone-prod"
    }
    sandbox = {
      name = "rg-${local.prefix}-sandbox-weu"
      role = "sandbox"
    }
  }

  entra_groups = {
    platform_admins = {
      display_name = "${local.prefix}-platform-admins"
      description  = "Admins du socle (jamais d'assignation RBAC nominative)."
    }
    network_ops = {
      display_name = "${local.prefix}-network-ops"
      description  = "Exploitation réseau hub-and-spoke."
    }
    app_devs = {
      display_name = "${local.prefix}-app-devs"
      description  = "Équipes applicatives — landing zone dev."
    }
    app_prod = {
      display_name = "${local.prefix}-app-prod"
      description  = "Équipes applicatives — landing zone prod (droits restreints)."
    }
    readers = {
      display_name = "${local.prefix}-readers"
      description  = "Lecture seule sur l'abonnement."
    }
    sandbox_users = {
      display_name = "${local.prefix}-sandbox-users"
      description  = "Expérimentations isolées."
    }
  }
}
