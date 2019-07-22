# Kubernetes Monitoring for Capabilities

## To do

- Description on how to export dashboards, and import as configmaps
- How to enable scraping of capability apps metrics
- Review sample dashboards
- Update deployment script to use token replacement
- Make PowerShell deployment script
- Revise /README.md
- Revise /grafana/README.md
- Create "How to get Slack Webhook URL" guide

## Introduction

For a service to be successful, stability and reliability are key components.
In order to achieve this, monitoring and alerting are required to ensure that you know about your services stability and reliability, and further more, allowing you to investigate when things don't behave as expected.

## Getting started with monitoring and alerting

For monitoring and alerting we recommend using Grafana. By deploying via helm as described in this playbook, you will end with the following "Out of the box":

- Automatic datasource from a managed Prometheus
- A set of default dashboards to get you started
- Alerting to slack channel(s) of your choosing

Your team will be responsible for running your own deployment of Grafana, the Prometheus datasource is provided by the platform.

## Installation

### Pre-requisites

Before you can install Grafana into your Kubernetes namespace through Helm, you must first:

- Install Helm locally on your deployment machine
- Install Tiller into your Kubernetes namespace

#### Installing Helm

https://github.com/helm/helm/releases


#### Installing Tiller

**Bash**:

```bash
export NAMESPACE=[CapabilityRootId]
export TILLER_NAMESPACE=$NAMESPACE
export KUBE_ROLE="$NAMESPACE-fullaccess"
```

**PowerShell**:

```powershell
$NAMESPACE = "[CapabilityRootId]"
$env:TILLER_NAMESPACE = $NAMESPACE
$KUBE_ROLE = "$NAMESPACE-fullaccess"
```

**Bash**:

```bash
# Create Kubernetes Service Account
kubectl create serviceaccount --namespace $NAMESPACE tiller

# Create Kubernetes Secret
kubectl create rolebinding tiller --role=$KUBE_ROLE --serviceaccount=$NAMESPACE:tiller -n $NAMESPACE

# Install Tiller
helm init --service-account tiller
```

**PowerShell**:

```powershell
# Create Kubernetes Service Account
kubectl create serviceaccount --namespace $NAMESPACE tiller

# Create Kubernetes Secret
kubectl create rolebinding tiller --role=$KUBE_ROLE --serviceaccount=$($NAMESPACE):$(tiller) -n $NAMESPACE

# Install Tiller
helm init --service-account tiller
```

### Installing Grafana

#### Configuring deployment file

Create a file and edit the following parameters

#### Deploying Grafana

```bash
# Install Grafana
helm --namespace $NAMESPACE install stable/grafana --name grafana -f values.yaml
```

### Using Grafana (rephrase)

#### Generate dashboard configmaps

1. Save the dashboard JSON from Grafana using the "Share dashboard" function. Click the "Export" tab and tick "Export for sharing externally" on
2. Use the configmap template, replacing "DASHBOARD_JSON" with the contents for the exported JSON (the contents need to be indented 4 spaces to fit the yaml structure)
3. Apply the generated configmap using `kubectl`

PowerShell:

```powershell
# Define dashboard name - must be lowercase alphanum
$DASHBOARD_NAME = 'grafana-dashboard-resourceusage'

# Generate configmap, indenting JSON 4 spaces
(Get-Content .\grafana\template-dashboard-cm.yaml) -replace "DASHBOARD_NAME",$DASHBOARD_NAME | Out-File .\grafana\$($DASHBOARD_NAME)-cm.yaml
'    ' + (Get-Content .\grafana\$($DASHBOARD_NAME).json -Raw) -replace "`n","`n    " | Out-File .\grafana\$($DASHBOARD_NAME)-cm.yaml -Append
```

Bash:

```bash
# Define dashboard name - must be lowercase alphanum
DASHBOARD_NAME=grafana-dashboard-resourceusage

# Generate configmap, indenting JSON 4 spaces
cat ./grafana/template-dashboard-cm.yaml | sed "s/DASHBOARD_NAME/${DASHBOARD_NAME}/g" > ./grafana/${DASHBOARD_NAME}-cm.yaml
cat ./grafana/${DASHBOARD_NAME}.json | sed "s/^/    /g" >> ./grafana/${DASHBOARD_NAME}-cm.yaml
```
