#!/bin/bash

# Exits on any error (-e)
# Exits on undefined variables (-u)
# Exits on pipeline failures (-o pipefail)
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd $SCRIPT_DIR

source get-terraform-outputs.sh

# Get values from Terraform
echo "Getting Terraform outputs..."
export RESOURCE_GROUP_NAME=$(get_tf_output "resource_group_name.value")
echo "RESOURCE_GROUP_NAME: $RESOURCE_GROUP_NAME"
export AKS_NAME=$(get_tf_output "aks_outputs.value.name")
echo "AKS_NAME: $AKS_NAME"
export AG4CONTAINERS_IDENTITY_CLIENT_ID=$(get_tf_output "aks_outputs.value.agforcontainers_identity_client_id")
echo "AG4CONTAINERS_IDENTITY_CLIENT_ID: $AG4CONTAINERS_IDENTITY_CLIENT_ID"
export ALB_SUBNET_ID=$(get_tf_output "vnet_outputs.value.lb_subnet_id")
echo "ALB_SUBNET_ID: $ALB_SUBNET_ID"

# Verify values
# 
if [[ -z "$RESOURCE_GROUP_NAME" || -z "$AKS_NAME" || -z "$AG4CONTAINERS_IDENTITY_CLIENT_ID" ]]; then
    echo "Error: Missing required Terraform outputs"
    exit 1
fi


HELM_NAMESPACE='dev'
CONTROLLER_NAMESPACE='azure-alb-system'
ALB_CONTROLLER_VERSION='1.7.9'


is_helm_release_installed() {
  helm status alb-controller --namespace "$HELM_NAMESPACE" >/dev/null 2>&1
}

install_alb_controller_if_not_exists() {
  if is_helm_release_installed; then
    echo "ALB Controller is already installed in namespace $HELM_NAMESPACE."
    echo "Skipping installation."
  else
    echo "ALB Controller is not installed."
    echo "Installing ALB Controller..."
    helm install alb-controller oci://mcr.microsoft.com/application-lb/charts/alb-controller \
      --namespace $HELM_NAMESPACE --create-namespace \
      --version $ALB_CONTROLLER_VERSION \
      --set albController.namespace=$CONTROLLER_NAMESPACE \
      --set albController.podIdentity.clientID=$AG4CONTAINERS_IDENTITY_CLIENT_ID \
      --skip-schema-validation # fix bug on helm https://github.com/azure/aks/issues/5236
  fi
}

install_alb_controller_if_not_exists


echo "Processing template with envsubst..."
echo "---"
envsubst < $SCRIPT_DIR/app-gateway-for-containers-ALBExample.yml | cat
echo "---"
envsubst < $SCRIPT_DIR/app-gateway-for-containers-ALBExample.yml | kubectl apply -f -

echo "ApplicationLoadBalancer applied successfully!"
kubectl get ApplicationLoadBalancer -n alb-example-infra
