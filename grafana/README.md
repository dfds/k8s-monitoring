# Manual Installation

If you wish to install Grafana manually without using the bootstrapping script in the root folder of this repository, this README file contains instructions.

## Pre-requisites

- Install the Helm client on your deployment machine
- Install Tiller into your Kubernetes namespace

## Installing Grafana

Installing Grafana is a two step process.

1. Modify the values.yaml file to reflect the namespace and capability it should be deployed in.
2. Deploying the actual helm chart

### Configuring deployment file

In the values.yaml file, the following variables must be changed to properly reflect the deployment:

```yaml
path: /$NAMESPACE
root_url: "https://%(domain)s/$NAMESPACE"
recipient: "#$SLACK_CHANNEL"
url: $SLACK_URL
```

### Deploying Grafana

Deploying Grafana with a known persistent password requires that you create a secret with a known password beforehand.
Then you point your Grafana installation to use the existing secret.

**Bash:**

*Create Grafana Password Secret:*

```bash
ADMIN_PASSWORD="MyPasswordToGrafana"
secret="grafana-password"
kubectl --namespace $NAMESPACE create secret generic "$secret" --from-literal=admin-user=admin --from-literal=admin-password="$ADMIN_PASSWORD"
```

*Deploy Grafana in namespace through Tiller in that namespace:*

```bash
# Install Grafana
helm --tiller-namespace $NAMESPACE --namespace $NAMESPACE install stable/grafana --name grafana -f values.yaml --set admin.existingSecret="$secret"
```

**PowerShell:**

*Create Grafana Password Secret:*

```PowerShell
$ADMIN_PASSWORD="MyPasswordToGrafana"
$secret="grafana-password"
kubectl --namespace $NAMESPACE create secret generic "$secret" --from-literal=admin-user=admin --from-literal=admin-password="$ADMIN_PASSWORD"
```

*Deploy Grafana in namespace through Tiller in that namespace:*

```PowerShell
# Install Grafana
helm --tiller-namespace $NAMESPACE --namespace $NAMESPACE install stable/grafana --name grafana -f values.yaml --set admin.existingSecret="$secret"
```

### Updating Password after a mismatch

In the case that the Admin password has been updated inside of the deployed Grafana instance and the user wish to reset it so it matches the secret, it is possible to use the Grafana CLI inside the Grafana pod.

The following code snippet will get the password from the secret, decode it and execute a reset from the Grafana CLI from within the Grafana container inside the Grafana Helm Pod.

```bash
kubectl get secret grafana-password -o jsonpath='{.data.admin-password}' \
| base64 --decode \
| xargs -I {} kubectl exec -it $(kubectl get pod -l "app=grafana" -o jsonpath='{.items[0].metadata.name}') --container grafana -- grafana-cli admin reset-admin-password --homepath /usr/share/grafana {}
```

### Manually generate dashboard configmaps

The deployment from the k8s-monitoring git repository comes with some out of the box sample dashboards.
When you modify your dashboards or create new ones inside of Grafana, you should save them as config maps to ensure persistance.
If you do not wish to use the steps outlined in the **Setting up a CI Dashboard Pipeline** part of the main Readme file, these steps instructs how you can do it manually:

1. Save the dashboard JSON from Grafana using the **Share dashboard** function.
   - Click the **Export** tab and make sure the **Export for sharing externally** setting is NOT checked.
2. Use the configmap template, replacing **DASHBOARD_JSON** with the contents for the exported JSON.
   - (the contents need to be indented 4 spaces to fit the yaml structure)
3. Apply the generated configmap using `kubectl`

**PowerShell:**

```powershell
# Define dashboard name - must be lowercase alphanum
$DASHBOARD_NAME = 'dashboard-sample-resourceusage'

# Generate configmap, indenting JSON 4 spaces
(Get-Content .\grafana\templates\template-dashboard-cm.yaml) -replace "DASHBOARD_NAME",$DASHBOARD_NAME | Out-File .\grafana\configmaps\$($DASHBOARD_NAME)-cm.yaml
'    ' + (Get-Content .\grafana\dashboards\$($DASHBOARD_NAME).json -Raw) -replace "`n","`n    " | Out-File .\grafana\configmaps\$($DASHBOARD_NAME)-cm.yaml -Append
```

**Bash:**

```bash
# Define dashboard name - must be lowercase alphanum
DASHBOARD_NAME=dashboard-sample-resourceusage

# Generate configmap, indenting JSON 4 spaces
cat ./grafana/templates/template-dashboard-cm.yaml | sed "s/DASHBOARD_NAME/${DASHBOARD_NAME}/g" > ./grafana/configmaps/${DASHBOARD_NAME}.yaml
cat ./grafana/dashboards/${DASHBOARD_NAME}.json | sed "s/^/    /g" >> ./grafana/configmaps/${DASHBOARD_NAME}.yaml
```
