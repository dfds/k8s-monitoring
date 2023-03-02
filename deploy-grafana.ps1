[CmdletBinding()]
Param (
    [Parameter(Mandatory=$true)][String]$NAMESPACE,
    [Parameter(Mandatory=$true)][String]$SLACK_CHANNEL,
    [Parameter(Mandatory=$true)][String]$SLACK_URL,
    [Parameter(Mandatory=$true)][String]$ADMIN_PASSWORD,
    [Parameter(Mandatory=$true)][String]$TEAMS_URL
)

# Generate variables from script input
$ROOT_URL="https://%(domain)s/$NAMESPACE"

(Get-Content ./grafana/templates/template-helm-values.yaml -Raw) `
    -replace '\$NAMESPACE', $NAMESPACE `
    -replace '\$ROOT_URL', $ROOT_URL `
    -replace '\$SLACK_CHANNEL', $SLACK_CHANNEL `
    -replace '\$SLACK_URL', $SLACK_URL `
    -replace '\$TEAMS_URL', $TEAMS_URL `
    | Out-File -FilePath values.yaml -Encoding utf8

# Write-Output  "Applying configmaps"
# kubectl --namespace $NAMESPACE apply -f grafana/configmaps/

Write-Output "Creating secret 'grafana-password'"
$secret="grafana-password"
kubectl --namespace $NAMESPACE create secret generic "$secret" --from-literal=admin-user=admin --from-literal=admin-password="$ADMIN_PASSWORD" --dry-run=client -o yaml | Out-File secret.yaml
kubectl --namespace $NAMESPACE apply -f secret.yaml

Write-Output "Register Grafana Helm repo"
helm repo add grafana https://grafana.github.io/helm-charts
helm repo update

Write-Output "Deploying Grafana through Helm"
helm --namespace $NAMESPACE upgrade --install grafana grafana/grafana -f values.yaml --set admin.existingSecret="$secret"

# Generate ingressroute.yaml file from template
(Get-Content ./grafana/templates/template-traefik-ingressroute.yaml -Raw) `
    -replace '\$NAMESPACE', $NAMESPACE `
    -replace "'", '`' `
    | Out-File -FilePath ingressroute.yaml -Encoding utf8

Write-Output "Deploying Traefik V2 IngressRoute and Middleware"
kubectl --namespace $NAMESPACE apply -f ingressroute.yaml

# Write-Output "Your can access your grafana the following information:"
# Write-Output "URL: https://grafana.hellman.oxygen.dfds.cloud/$NAMESPACE"
# Write-Output "Username: admin"
# Write-Output "Password: Your Chosen Password from parameters"
