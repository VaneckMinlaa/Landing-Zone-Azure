variable "subscription_id" {
  type        = string
  description = "GUID de l'abonnement Azure."
}

variable "tenant_id" {
  type        = string
  description = "GUID du tenant Entra ID."
}

variable "use_oidc" {
  type        = bool
  default     = false
  description = "true dans GitHub Actions (OIDC) ; false en local après az login."
}

variable "org_name" {
  type        = string
  default     = "acme"
  description = "Nom d'organisation (management group racine métier)."
}

variable "location" {
  type        = string
  default     = "westeurope"
  description = "Région principale du socle."
}

variable "allowed_locations" {
  type        = list(string)
  default     = ["westeurope", "francecentral"]
  description = "Régions autorisées par Azure Policy."
}

variable "budget_alert_emails" {
  type        = list(string)
  description = "Emails d'alerte Cost Management."
}

variable "budget_start_date" {
  type        = string
  description = "Premier jour du mois UTC, ex. 2026-09-01T00:00:00Z."
}

variable "security_contact_email" {
  type        = string
  description = "Contact Defender for Cloud / alertes sécurité."
}

variable "enable_management_groups" {
  type        = bool
  default     = true
  description = "Nécessite l'élévation d'accès Global Administrator (User Access Administrator au tenant)."
}

variable "enable_entra_groups" {
  type        = bool
  default     = true
  description = "Créer les groupes Entra ID (droits Group Administrator)."
}

variable "enable_defender_standard" {
  type        = bool
  default     = false
  description = "Plans Defender payants. Laisser false sur un compte gratuit."
}

variable "enable_expensive_network" {
  type        = bool
  default     = false
  description = "Azure Firewall (coût horaire élevé). Démo uniquement, puis terraform destroy."
}

variable "rg_budget_amount" {
  type    = number
  default = 15
}

variable "required_tags" {
  type = map(string)
  default = {
    Environment = "platform"
    Owner       = "platform-team"
    CostCenter  = "cloud-foundation"
  }
}

variable "address_space" {
  type = object({
    hub        = string
    spoke_dev  = string
    spoke_prod = string
  })
  default = {
    hub        = "10.0.0.0/16"
    spoke_dev  = "10.1.0.0/16"
    spoke_prod = "10.2.0.0/16"
  }
}
