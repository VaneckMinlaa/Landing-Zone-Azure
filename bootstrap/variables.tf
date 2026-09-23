variable "subscription_id" {
  type        = string
  description = "GUID de l'abonnement Azure (compte gratuit : un seul)."
}

variable "location" {
  type        = string
  default     = "westeurope"
  description = "Région du Storage Account de state (West Europe ou France Central)."
}

variable "org_prefix" {
  type        = string
  default     = "acme"
  description = "Préfixe court, lettres minuscules uniquement (nom du storage account)."
}

variable "budget_amount" {
  type        = number
  default     = 40
  description = "Budget mensuel de garde-fou AVANT le reste du socle (crédits gratuits ~200 USD / 30 j)."
}

variable "budget_start_date" {
  type        = string
  description = "Premier jour du mois courant, UTC. Exemple : 2026-09-01T00:00:00Z"
}

variable "budget_alert_emails" {
  type        = list(string)
  description = "Emails qui reçoivent 50 %, 80 % et 100 % du budget."
}

variable "required_tags" {
  type = map(string)
  default = {
    Environment = "platform"
    Owner       = "platform-team"
    CostCenter  = "cloud-foundation"
  }
}
