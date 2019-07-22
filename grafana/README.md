# Manual Installation

## Pre-requisites

Before installing two things needs to be in place:

* Edit the capability role to allow creation of roles and rolebindings within the capability namespace.
* Installation of Helm and Tiller for helm chart based deployments.

### Capability role permissions

Edit capability role to allow rolebindings:

```bash
k edit roles <NameOfRole> -n <NAMESPACE>  
```

```yaml
- apiGroups:
  - rbac.authorization.k8s.io
  resources:
  - rolebindings
  - roles
  verbs:
  - '*'
```

### Helm & Tiller

Before you can install Grafana into your Kubernetes namespace through Helm, you must first:
* Install Helm locally on your deployment machine
* Install Tiller into your Kubernetes namespace

#### Installing Helm

Download helm and install it on your local machine:  
https://github.com/helm/helm/releases


#### Installing Tiller

One Tiller per namespace is required for the teams to deploy helm charts into their own namespaces.

**Bash:**

*Define variables*

```bash
export NAMESPACE=[CapabilityRootId]
export KUBE_ROLE="$NAMESPACE-fullaccess"
```

*Install Tiller*

```bash
# Create Kubernetes Service Account
kubectl create serviceaccount --namespace $NAMESPACE tiller

# Create Kubernetes Secret
kubectl create rolebinding tiller --role=$KUBE_ROLE --serviceaccount=$NAMESPACE:"tiller" -n $NAMESPACE

# Install Tiller
helm init --service-account tiller --tiller-namespace $NAMESPACE
```

**PowerShell:**

*Define variables*

```powershell
$NAMESPACE=[CapabilityRootId]
$KUBE_ROLE="$NAMESPACE-fullaccess"
```
*Install Tiller*

```powershell
# Create Kubernetes Service Account
kubectl create serviceaccount --namespace $NAMESPACE tiller

# Create Kubernetes Secret
kubectl create rolebinding tiller --role=$KUBE_ROLE --serviceaccount=$($NAMESPACE):$(tiller) -n $NAMESPACE

# Install Tiller
helm init --service-account tiller --tiller-namespace $NAMESPACE
```

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

*Create Grafana Password Secret*

```bash
ADMIN_PASSWORD="MyPasswordToGrafana"
secret="grafana-password"
kubectl --namespace $NAMESPACE create secret generic "$secret" --from-literal=admin-user=admin --from-literal=admin-password="$ADMIN_PASSWORD"
```
**Deploy Grafana in namespace through Tiller in that namespace**

```bash
# Install Grafana
helm --tiller-namespace $NAMESPACE --namespace $NAMESPACE install stable/grafana --name grafana -f values.yaml --set admin.existingSecret="$secret"
```

**PowerShell:**

*Create Grafana Password Secret*

```PowerShell
$ADMIN_PASSWORD="MyPasswordToGrafana"
$secret="grafana-password"
kubectl --namespace $NAMESPACE create secret generic "$secret" --from-literal=admin-user=admin --from-literal=admin-password="$ADMIN_PASSWORD"
```
*Deploy Grafana in namespace through Tiller in that namespace*

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