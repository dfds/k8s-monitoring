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
kubectl --namespace $NAMESPACE create secret generic "$secret" --from-literal=admin-user=admin --from-literal=admin-password="$ADMIN_PASSWORD" --dry-run=client -o yaml | kubectl apply -f -

echo "Register Grafana Helm repo"
helm repo add grafana https://grafana.github.io/helm-charts
helm repo update

echo "Deploying Grafana through Helm"
helm --namespace $NAMESPACE upgrade --install grafana grafana/grafana -f values.yaml --set admin.existingSecret="$secret"

# Generate ingressroute.yaml file from template
function generate_ingressroute_yaml {
  echo "Creating ingressroute.yaml file"
  render_template grafana/templates/template-traefik-ingressroute.yaml > ingressroute.yaml
}

generate_ingressroute_yaml

echo "Set the correct quote sympbols in ingressroute.yaml"
sed -i "s/'/\`/g" ingressroute.yaml

echo "Deploying Traefik V2 IngressRoute and Middleware"
kubectl --namespace $NAMESPACE apply -f ingressroute.yaml

echo "Your can access your grafana the following information:"
echo "URL: https://grafana.hellman.oxygen.dfds.cloud/$NAMESPACE"
echo "Username: admin"
echo "Password: Your Chosen Password from parameters"
