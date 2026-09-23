# Tableau des coûts (compte gratuit / démo)

Devise : USD (crédit Azure 200 $ / 30 jours). Les montants sont des **ordres de grandeur** West Europe, septembre 2026. Vérifier le [calculateur Azure](https://azure.microsoft.com/pricing/calculator/) avant la soutenance.

Mettre le **budget à 40 $ / mois** (bootstrap) **avant** le reste du socle.

## Inclus dans le socle par défaut (Firewall et Defender Standard OFF)

| Ressource | SKU / volumétrie | Estimation mensuelle | Commentaire |
| --- | --- | --- | --- |
| Management groups, Policy, RBAC, groupes Entra | — | 0 $ | Plan de contrôle |
| 3 VNets + 6 subnets + 4 peerings | — | 0 $ | Peerings VNet sont gratuits dans la même région |
| 3 NSG | — | ~0 $ | Règles NSG sans flow logs |
| Route table | — | 0 $ | |
| Log Analytics | 30 j, quota 1 Go/j | ~2–5 $ si < 1 Go ingéré | **Principal poste variable** |
| Diagnostic settings | — | inclus dans l’ingestion LAW | |
| Defender CSPM Free | CloudPosture Free | 0 $ | Recommandations, pas de plans payants |
| Storage tfstate | LRS, quelques Mo | < 0,10 $ | Versioning blob |
| Budgets / alertes e-mail | — | 0 $ | |
| **Total typique au repos** | | **~3–8 $ / mois** | Laisser tourner pour la démo est raisonnable |

## Ne pas laisser allumé

| Ressource | Variable | Ordre de grandeur | Conduite |
| --- | --- | --- | --- |
| Azure Firewall Standard | `enable_expensive_network = true` | ~1,25–1,60 $/heure **plus** 0,016 $/Go | Démo 15 min puis `terraform apply` avec `false` ou `destroy` ciblé |
| Public IP Standard (Firewall) | liée au Firewall | ~3–4 $/mois si 24/7 | Interdite par Policy si Firewall OFF |
| Azure Bastion | non déployé | ~0,19 $/heure | Remplacé par NSG |
| VPN Gateway VpnGw1 | non déployé | ~140 $/mois | Hors périmètre |
| Defender for Servers | `enable_defender_standard` | plusieurs $ / vCPU | Rester en Free |
| Defender for Storage | idem | selon transactions | Off par défaut |

## Budgets Terraform

| Périmètre | Montant par défaut | Alertes |
| --- | --- | --- |
| Subscription | 40 | 50 / 80 / 100 % |
| Chaque resource group | 15 | 50 / 80 / 100 % |

Ajuster `budget_amount` / `subscription_budget_amount` selon le crédit restant (`az consumption usage list` ou Cost Management dans le portail).

## Comment présenter le tableau en soutenance

1. Portail → **Cost Management** → **Cost analysis** filtré sur les RG `rg-{org}-*`.
2. Capture d’écran **Budgets** avec les trois seuils.
3. Ce tableau : prévu vs réel, et la phrase « Firewall non déployé car 1 $/h, NSG + UDR à la place ».
