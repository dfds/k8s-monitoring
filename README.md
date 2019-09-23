# Kubernetes Monitoring for Capabilities

This repository is designed to be forked by your team, and contains scripts to bootstrap your Grafana deployment, and templates to setup a CI pipeline for easy deployment of your dashboards to Grafana in Kubernetes.

- [Kubernetes Monitoring for Capabilities](#kubernetes-monitoring-for-capabilities)
  - [Installation](#installation)
    - [Pre-requisites](#pre-requisites)
    - [Preparing variables](#preparing-variables)
    - [Deploying Grafana](#deploying-grafana)
  - [Setting up a CI Dashboard Pipeline](#setting-up-a-ci-dashboard-pipeline)

## Installation

Going through the full installation guide, you will manually deploy the Grafana helm chart to your kubernetes namespace.
Just doing the deployment does not give you the sample dashboards, for sample dashboards and a nice way to keep dashboards updated, make sure to also setup the CI pipeline described in the laster part.

### Pre-requisites

1. You must setup your own clone of the repository in Azure DevOps [(Import Git Repository).](https://docs.microsoft.com/en-us/azure/devops/repos/git/import-git-repository?view=azure-devops)
   - Your clone of this repository allows for easy version control of the deployment / dashboards.
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

- Generate a custom values.yaml file for your helm deployment and save it in the grafana folder as `values.yaml`.
- Create a kubernetes secret called `grafana-password` containing the password you provide in the script.
- Apply all configmaps inside of the `grafana/configmaps` folder (dashboards and datasources).
- Deploy Grafana into your kubernetes namespace as a Helm deployment.

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

## Setting up a CI Dashboard Pipeline

Setting up your Continuous Integration Dashboard pipeline requires:

1. [Creating a Kubernetes Service Connection](https://playbooks.dfds.cloud/deployment/k8s-service-connection.html) in your Azure DevOps project.
   - A recommended name would be Kubernetes-YourNameSpaceName
2. Changing **<YourKubernetesServiceConnection>** inside of the **azure-pipelines.yml** file so it matches your Kubernetes Service Connection.
3. Create a new Azure DevOps pipeline based on the **azure-pipelines.yml** file:
   1. Go to Pipelines -> Builds
   2. Click New -> New build pipeline
   3. Select Azure Repos Git (YAML)
   4. Select the repository you have forked this project into
   5. Choose Existing Azure Pipelines YAML file
   6. In **Path** select **/azure-pipelines.yml**
   7. Choose **RUN** and validate that the pipeline executes.

Now, whenever you add a JSON file with a dashboard inside of the grafana/dashboards folder, it will automatically trigger the pipeline and deploy your dashboard.
