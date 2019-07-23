# Kubernetes Monitoring for Capabilities

- [Kubernetes Monitoring for Capabilities](#kubernetes-monitoring-for-capabilities)
  - [To do](#to-do)
  - [Installation](#installation)
    - [Pre-requisites](#pre-requisites)
    - [Installing Grafana](#installing-grafana)
      - [Preparing variables](#preparing-variables)
    - [Using Grafana (rephrase)](#using-grafana-rephrase)
      - [Generate dashboard configmaps](#generate-dashboard-configmaps)

## To do

- [x] Description on how to export dashboards, and import as configmaps
- [ ] How to enable scraping of capability apps metrics
- [ ] Review sample dashboards
- [ ] Update deployment script to use token replacement
- [x] Make PowerShell deployment script
- [ ] Revise /README.md
- [ ] Revise /grafana/README.md
- [ ] Create "How to get Slack Webhook URL" guide

## Installation

### Pre-requisites

Before you can install Grafana into your Kubernetes namespace through Helm, you must first:

- Install the Helm client on your deployment machine
- Install Tiller into your Kubernetes namespace
- Git installed on your deployment machine
- PowerShell or Bash installed on your deployment machine

For Helm and Tiller, guide can be found in the [DFDS Helm Playbook.](https://playbooks.dfds.cloud/kubernetes/helm.html)

### Installing Grafana

First, you must clone repository onto your deployment machine:

1. `git clone https://github.com/dfds/k8s-monitoring.git`
2. `cd k8s-monitoring`

#### Preparing variables

The deployment scripts requires that you supply 4 parameters:
NAMESPACE: The Kubernetes namespace of you will be deploying Grafana into.

SLACK_CHANNEL: The handle of the slack channel you wish to receive alerting into. By default we suggest your capability slack channel.

SLACK_URL: The token URL used for creating webhooks into your slack channel, used for alerting. A guide on how to get the URL for your slack channel can be found here:

ADMIN_PASSWORD: The administrator password you want for your Grafana deployment, this will be saved as a secret in your kubernetes namespace.

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
(Get-Content .\grafana\template-dashboard-cm.yaml) -replace "DASHBOARD_NAME",$DASHBOARD_NAME | Out-File .\grafana\configmaps\$($DASHBOARD_NAME)-cm.yaml
'    ' + (Get-Content .\grafana\configmaps\$($DASHBOARD_NAME).json -Raw) -replace "`n","`n    " | Out-File .\grafana\configmaps\$($DASHBOARD_NAME)-cm.yaml -Append
```

Bash:

```bash
# Define dashboard name - must be lowercase alphanum
DASHBOARD_NAME=grafana-dashboard-resourceusage

# Generate configmap, indenting JSON 4 spaces
cat ./grafana/template-dashboard-cm.yaml | sed "s/DASHBOARD_NAME/${DASHBOARD_NAME}/g" > ./grafana/configmaps/${DASHBOARD_NAME}.yaml
cat ./grafana/configmaps/${DASHBOARD_NAME}.json | sed "s/^/    /g" >> ./grafana/configmaps/${DASHBOARD_NAME}.yaml
```