variable "name" {
  type        = string
  description = "Nom unique du budget Cost Management."
}

variable "scope" {
  type        = string
  description = "subscription ou resource_group."
  validation {
    condition     = contains(["subscription", "resource_group"], var.scope)
    error_message = "scope doit valoir subscription ou resource_group."
  }
}

variable "subscription_id" {
  type        = string
  description = "ID de l'abonnement (format /subscriptions/guid)."
}

variable "resource_group_id" {
  type        = string
  default     = null
  description = "ID du groupe de ressources si scope = resource_group."
}

variable "amount" {
  type        = number
  description = "Plafond mensuel en devise de facturation (EUR ou USD selon le compte)."
}

variable "start_date" {
  type        = string
  description = "Premier jour du mois au format RFC3339, ex. 2026-09-01T00:00:00Z."
}

variable "contact_emails" {
  type        = list(string)
  description = "Destinataires des alertes 50 / 80 / 100 %."
}

variable "thresholds" {
  type        = list(number)
  default     = [50, 80, 100]
  description = "Seuils d'alerte en pourcentage du budget."
}
