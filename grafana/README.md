# Manual Installation

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