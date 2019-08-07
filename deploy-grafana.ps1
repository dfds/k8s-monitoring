[CmdletBinding()]
Param (
    [Parameter(Mandatory=$true)][String]$NAMESPACE,
    [Parameter(Mandatory=$true)][String]$SLACK_CHANNEL,
    [Parameter(Mandatory=$true)][String]$SLACK_URL,
    [Parameter(Mandatory=$true)][String]$ADMIN_PASSWORD
)

# Generate variables from script input
$env:TILLER_NAMESPACE=$NAMESPACE
$ROOT_URL="https://%(domain)s/$NAMESPACE"

(Get-Content ./grafana/templates/template-helm-values.yaml -Raw) `
    -replace '\$NAMESPACE', $NAMESPACE `
    -replace '\$ROOT_URL', $ROOT_URL `
    -replace '\$SLACK_CHANNEL', $SLACK_CHANNEL `
    -replace '\$SLACK_URL', $SLACK_URL `
    | Out-File -FilePath values.yaml -Encoding utf8
   
Write-Output  "Applying configmaps"
kubectl --namespace $NAMESPACE apply -f grafana/configmaps/

Write-Output "Creating secret 'grafana-password'"
$secret="grafana-password"
kubectl --namespace $NAMESPACE create secret generic "$secret" --from-literal=admin-user=admin --from-literal=admin-password="$ADMIN_PASSWORD"

Write-Output "Deploying Grafana through Helm"
helm --namespace $NAMESPACE install stable/grafana --name grafana -f values.yaml --set admin.existingSecret="$secret"

Write-Output "Your can access your grafana the following information:"
Write-Output "URL: https://grafana.hellman.oxygen.dfds.cloud/$NAMESPACE"
Write-Output "Username: admin"
Write-Output "Password: Your Chosen Password from paramters"