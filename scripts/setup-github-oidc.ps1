param(
  [Parameter(Mandatory = $true)]
  [string] $GitHubRepo,
  [string] $AppName = "gha-socle-azure"
)

$ErrorActionPreference = "Stop"

$app = az ad app create --display-name $AppName | ConvertFrom-Json
az ad sp create --id $app.appId | Out-Null

function Add-Fed([string] $Name, [string] $Subject) {
  $payload = @{
    name      = $Name
    issuer    = "https://token.actions.githubusercontent.com"
    subject   = $Subject
    audiences = @("api://AzureADTokenExchange")
  } | ConvertTo-Json
  $tmp = New-TemporaryFile
  Set-Content -Path $tmp -Value $payload -Encoding utf8
  az ad app federated-credential create --id $app.appId --parameters "@$tmp"
  Remove-Item $tmp
}

Add-Fed "gha-main" "repo:${GitHubRepo}:ref:refs/heads/main"
Add-Fed "gha-pr" "repo:${GitHubRepo}:pull_request"
Add-Fed "gha-production" "repo:${GitHubRepo}:environment:production"

$sub = az account show --query id -o tsv
az role assignment create --assignee $app.appId --role "Contributor" --scope "/subscriptions/$sub"
az role assignment create --assignee $app.appId --role "User Access Administrator" --scope "/subscriptions/$sub"

$tenant = az account show --query tenantId -o tsv
Write-Host @"

Configurer les VARIABLES GitHub (pas de secrets) :
  ARM_CLIENT_ID         = $($app.appId)
  ARM_TENANT_ID         = $tenant
  ARM_SUBSCRIPTION_ID   = $sub

Créer l'environnement GitHub 'production' avec Required reviewers.
"@
