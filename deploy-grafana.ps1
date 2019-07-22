[CmdletBinding()]
Param (
    [Parameter(Mandatory=$true)][String]$NAMESPACE,
    [Parameter(Mandatory=$true)][String]$SLACK_CHANNEL,
    [Parameter(Mandatory=$true)][String]$SLACK_URL,
    [Parameter(Mandatory=$true)][String]$ADMIN_PASSWORD
)

# Generate variables from script input
$KUBE_ROLE="$NAMESPACE-fullaccess"
$env:TILLER_NAMESPACE=$NAMESPACE
$ROOT_URL="https://%(domain)s/$NAMESPACE"
$TillerServiceAccount = "$NAMESPACE" + ':tiller'

(Get-Content ./grafana/template-helm-values.yaml -Raw) `
    -replace '\$NAMESPACE', $NAMESPACE `
    -replace '\$ROOT_URL', $ROOT_URL `
    -replace '\$SLACK_CHANNEL', $SLACK_CHANNEL `
    -replace '\$SLACK_URL', $SLACK_URL `
    | Out-File -FilePath values.yaml -Encoding utf8
   
Write-Output "Creating tiller service account"
kubectl create serviceaccount --namespace $NAMESPACE tiller

Write-Output  "Creating tiller rolebinding for service account"
kubectl create rolebinding tiller --role=$KUBE_ROLE --serviceaccount=$TillerServiceAccount --namespace $NAMESPACE

Write-Output  "Initializing tiller into namespace"
helm init --service-account tiller

Write-Output  "Applying configmaps"
kubectl --namespace $NAMESPACE apply -f grafana/configmaps/

Write-Output  "Waiting for tiller to finish deploying"

sleep 20

Write-Output "Creating secret 'grafana-password'"
$secret="grafana-password"
kubectl --namespace $NAMESPACE create secret generic "$secret" --from-literal=admin-user=admin --from-literal=admin-password="$ADMIN_PASSWORD"

Write-Output "Deploying Grafana through Helm"
helm --namespace $NAMESPACE install stable/grafana --name grafana -f values.yaml --set admin.existingSecret="$secret"