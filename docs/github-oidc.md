# GitHub Actions + OIDC (aucun secret Azure)

Le tenant UTT **interdit** `az ad app create`. La fédération se fait donc avec une **User Assigned Managed Identity** (`id-gha-socle` dans `rg-acme-identity-weu`), pas une App Registration.

Dépôt : [VaneckMinlaa/socle-azure](https://github.com/VaneckMinlaa/socle-azure)

## Pousser le workflow (une fois)

Si le token `gh` n’a pas le scope `workflow` :

```powershell
gh auth refresh --hostname github.com -s workflow
cd socle-azure
git push -u origin main
```

## Environnement `production`

**Settings → Environments → production → Required reviewers** → ton compte.

C’est la validation manuelle avant `terraform apply` (`workflow_dispatch` avec la case apply).

## Identité Azure

| Élément | Valeur |
| --- | --- |
| Managed Identity | `id-gha-socle` |
| Client ID | `8cdac87a-b51c-4b70-9e49-5d84ea231bd0` |
| Fédérations | subjects GitHub (format avec IDs `owner@id/repo@id` + format classique) |
| Rôles | Contributor, User Access Administrator, Storage Blob Data Contributor (tfstate) |

Variables GitHub (pas de secrets) : `ARM_CLIENT_ID`, `ARM_TENANT_ID`, `ARM_SUBSCRIPTION_ID`, `ORG_NAME`, `ALERT_EMAIL`, `BUDGET_START_DATE`, `TFSTATE_*`.

## Flux

```
PR  → fmt + tflint + Checkov + terraform plan → commentaire sur la PR
main → plan seulement
workflow_dispatch (apply=true) → apply après approbation de l’environnement production
```
