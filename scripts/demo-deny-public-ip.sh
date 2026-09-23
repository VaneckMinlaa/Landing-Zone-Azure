#!/usr/bin/env bash
set -euo pipefail
RG="${1:?resource group}"
LOC="${2:-westeurope}"
NAME="pip-policy-demo-should-fail"

echo "Tentative de création d'une IP publique (doit être refusée par Policy)..."
if az network public-ip create \
  --name "$NAME" \
  --resource-group "$RG" \
  --location "$LOC" \
  --sku Standard \
  --allocation-method Static \
  --tags Environment=sandbox Owner=demo CostCenter=demo; then
  echo "La Public IP a été créée : policy pas encore effective."
  exit 1
fi
echo "Attendu : RequestDisallowedByPolicy. OK."
