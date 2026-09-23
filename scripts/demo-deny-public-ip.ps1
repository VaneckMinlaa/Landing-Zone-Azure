param(
  [Parameter(Mandatory = $true)]
  [string] $ResourceGroup,
  [string] $Location = "westeurope",
  [string] $Name = "pip-policy-demo-should-fail"
)

Write-Host "Tentative de création d'une IP publique (doit être refusée par Azure Policy deny-public-ip)..."
az network public-ip create `
  --name $Name `
  --resource-group $ResourceGroup `
  --location $Location `
  --sku Standard `
  --allocation-method Static `
  --tags Environment=sandbox Owner=demo CostCenter=demo

if ($LASTEXITCODE -ne 0) {
  Write-Host "`nAttendu : RequestDisallowedByPolicy. La gouvernance fonctionne."
  exit 0
}

Write-Host "La Public IP a été créée : la policy n'est pas encore effective (attendre 15 min) ou l'assignment est Disabled."
exit 1
