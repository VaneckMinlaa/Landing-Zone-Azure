# Démo soutenance — une policy qui bloque

Objectif : montrer qu’un déploiement non conforme est **refusé par Azure Policy**, pas par une revue humaine.

Prérequis : `terraform apply` du dossier `infra/` terminé, policy `deny-public-ip` en **Default** (enforcement). La réplication Policy peut prendre 5–15 minutes.

## Scénario A — IP publique (le plus parlant)

```powershell
cd socle-azure\scripts
.\demo-deny-public-ip.ps1 -ResourceGroup "rg-acme-sandbox-weu" -Location "westeurope"
```

Résultat attendu : erreur ARM du type `RequestDisallowedByPolicy` / assignment `deny-public-ip`.

Capture : message d’erreur + écran **Policy → Assignments → deny-public-ip**.

## Scénario B — mauvaise région

```powershell
az group create --name rg-demo-eastus --location eastus
```

Attendu : deny `deny-rg-regions` (locations autorisées : `westeurope`, `francecentral`).

## Scénario C — Storage sans HTTPS

```powershell
az storage account create `
  --name stnonhttpsdemo0123 `
  --resource-group rg-acme-sandbox-weu `
  --location westeurope `
  --https-only false `
  --tags Environment=sandbox Owner=demo CostCenter=demo
```

Attendu : deny `deny-http-storage`.

## Scénario D — ressource sans tag

```powershell
az network nsg create `
  --name nsg-notags `
  --resource-group rg-acme-sandbox-weu `
  --location westeurope
```

Attendu : deny `req-tag-environment` (et les autres tags).

## Script de commentaire oral (90 s)

« Le socle pose un hub partagé et deux spokes. Les équipes n’ont des droits que via des groupes Entra, jamais nominatifs. Les policies deny bloquent IP publique, régions hors UE et stockage en HTTP. Les logs partent vers un Log Analytics unique. Un budget à 50/80/100 % a été créé **avant** le réseau. Le pipeline GitHub s’authentifie en OIDC, sans secret dans le dépôt. »

## Checklist livrables

- [ ] Schéma (README + `docs/architecture.md`, export PNG depuis mermaid.live si besoin)
- [ ] Dépôt GitHub avec Actions verte sur une PR
- [ ] Démo Policy (scénario A)
- [ ] Tableau des coûts (`docs/couts.md` + capture Cost Management)
