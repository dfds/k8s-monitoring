#!/bin/bash
set -e

echo 'Checking for required environment variables...'
if [[ -z $NAMESPACE || -z $SLACK_CHANNEL || -z $SLACK_URL || -z $ADMIN_PASSWORD ]]; then
    echo 'required environment variables missing'
    exit 1
fi

# Generate variables from script input
KUBE_ROLE="$NAMESPACE-fullaccess"
ROOT_URL="https://%(domain)s/$NAMESPACE"

# Define function to render values.yaml template
function render_template() {
  eval "echo \"$(cat $1)\""
}

# Generate values.yaml file from template
function generate_values_yaml {
  echo "Creating values.yaml file"
  render_template grafana/templates/template-helm-values.yaml > values.yaml
}

generate_values_yaml

echo "Applying configmaps"
kubectl --namespace $NAMESPACE apply -f grafana/configmaps/

echo "Creating secret 'grafana-password'"
secret="grafana-password"
kubectl --namespace $NAMESPACE create secret generic "$secret" --from-literal=admin-user=admin --from-literal=admin-password="$ADMIN_PASSWORD"

echo "Deploying Grafana through Helm"
helm --namespace $NAMESPACE upgrade --install grafana stable/grafana -f values.yaml --set admin.existingSecret="$secret"

echo "Your can access your grafana the following information:"
echo "URL: https://grafana.hellman.oxygen.dfds.cloud/$NAMESPACE"
echo "Username: admin"
echo "Password: Your Chosen Password from paramters"