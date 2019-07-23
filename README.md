# Kubernetes Monitoring for Capabilities

- [Kubernetes Monitoring for Capabilities](#kubernetes-monitoring-for-capabilities)
  - [To do](#to-do)
  - [Installation](#installation)
    - [Pre-requisites](#pre-requisites)
    - [Preparing variables](#preparing-variables)
    - [Deploying Grafana](#deploying-grafana)

## To do

- [x] Description on how to export dashboards, and import as configmaps
- [ ] How to enable scraping of capability apps metrics
- [ ] Review sample dashboards (Rasmus)
- [x] Update deployment script to use token replacement
- [x] Make PowerShell deployment script
- [x] Revise /README.md
- [x] Revise /grafana/README.md
- [x] Create "How to get Slack Webhook URL" guide (Stanley)

## Installation

### Pre-requisites

1. You must setup your own fork of the repository in Azure DevOps [(Import Git Repository).](https://docs.microsoft.com/en-us/azure/devops/repos/git/import-git-repository?view=azure-devops)
   - You should use your own forked version of the repository to save your own dashboard config maps down the road.
2. Before you can install Grafana into your Kubernetes namespace through Helm, you must first:
   - Install the Helm client on your deployment machine
   - Install Tiller into your Kubernetes namespace
   - Git installed on your deployment machine
   - PowerShell or Bash installed on your deployment machine

For Helm and Tiller, a guide can be found in the [DFDS Helm Playbook.](https://playbooks.dfds.cloud/kubernetes/helm.html)

### Preparing variables

The deployment scripts requires that you supply 4 parameters:

`NAMESPACE`: The Kubernetes namespace of you will be deploying Grafana into.

`SLACK_CHANNEL`: The handle of the slack channel you wish to receive alerting into. By default we suggest your capability slack channel.

`SLACK_URL`: The URL for your slack apps incoming webhook. If your channel doesn't already have a webhook integrated app, you can [simply create one.](https://get.slack.help/hc/en-us/articles/115005265063-Incoming-WebHooks-for-Slack) 

`ADMIN_PASSWORD`: The administrator password you want for your Grafana deployment, this will be saved as a secret in your kubernetes namespace.

### Deploying Grafana

Using the deployment script with the supplied parameters, it will do the following for you:

* Generate a custom values.yaml file for your helm deployment and save it in the grafana folder as `values.yaml`.
* Create a kubernetes secret called `grafana-password` containing the password you provide in the script.
* Apply all configmaps inside of the `grafana/configmaps` folder (dashboards and datasources).
* Deploy Grafana into your kubernetes namespace as a Helm deployment.

**PowerShell:**

Execute the script, giving it parameters like the example below:

```powershell
./deploy-grafana.ps1 -NAMESPACE 'capabilitynamespace-xyzvw' `
-SLACK_CHANNEL 'channelname' `
-SLACK_URL 'https://hooks.slack.com/services/XXXXXXXXX/YYYYYYYYY/ZZZZZZZZZZZZZZZZZZZZZZZZ' `
-ADMIN_PASSWORD 'GrafanaAdminPassword'
```

**Bash:**

Before running the script file, make sure it has been given execution rights `chmod +x ./deploy-grafana.sh`

Then execute the script giving it parameters like the example below:

```bash
NAMESPACE="capabilitynamespace-xyzvw" \
SLACK_CHANNEL="channelname" \
SLACK_URL="https://hooks.slack.com/services/XXXXXXXXX/YYYYYYYYY/ZZZZZZZZZZZZZZZZZZZZZZZZ" \
ADMIN_PASSWORD="GrafanaAdminPassword" \
./deploy-grafana.sh
```
