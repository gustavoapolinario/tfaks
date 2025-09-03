#!/bin/bash

# Exits on any error (-e)
# Exits on undefined variables (-u)
# Exits on pipeline failures (-o pipefail)
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

# Function to get Terraform output
get_tf_output() {
    local result

    result=$(terraform -chdir="../" output -json | jq -r ".$1")
    if [[ "$result" == "null" || -z "$result" ]]; then
        echo "Error: Output '$result' is null or empty" >&2
        exit 1
    fi
    echo "$result"
}

# Get values from Terraform
echo "Getting Terraform outputs..."
# export USER_ASSIGNED_IDENTITY_ID=$(get_tf_output "aks_outputs.value.principal_id")
export KEY_VAULT_ECCOMERCELAB_NAME=$(get_tf_output "key_vault_ecconmercelab_name.value")
echo "KEY_VAULT_ECCOMERCELAB_NAME: $KEY_VAULT_ECCOMERCELAB_NAME"
export TENANT_ID=$(get_tf_output "tenant_id.value")
echo "TENANT_ID: $TENANT_ID"
export SECRET_EXAMPLE_NAME=$(get_tf_output "key_vault_secret_example_name.value")
echo "SECRET_EXAMPLE_NAME: $SECRET_EXAMPLE_NAME"

export USER_ASSIGNED_IDENTITY_ID=$( \
    az aks connection show \
    --resource-group tfaks-dev-rg \
    --name tfaks-dev-aks \
    --connection aksakvexample \
    --query configurations \
    --only-show-errors \
    | jq -r '.[] | select(.name == "AZURE_KEYVAULT_CLIENTID") | .value' \
)
echo "USER_ASSIGNED_IDENTITY_ID: $USER_ASSIGNED_IDENTITY_ID"

# Verify values
# 
if [[ -z "$USER_ASSIGNED_IDENTITY_ID" || -z "$KEY_VAULT_ECCOMERCELAB_NAME" || -z "$TENANT_ID" || -z "$SECRET_EXAMPLE_NAME" ]]; then
    echo "Error: Missing required Terraform outputs"
    exit 1
fi


# Process template with envsubst (install with: sudo apt-get install gettext-base)
if ! command -v envsubst &> /dev/null; then
    echo "Error: envsubst command not found. Install with: sudo apt-get install gettext-base"
    exit 1
fi


echo "Processing template with envsubst..."
echo "---"
envsubst < $SCRIPT_DIR/secret-provider-class-azure-kv-example.yml | cat
echo "---"
envsubst < $SCRIPT_DIR/secret-provider-class-azure-kv-example.yml | kubectl apply -f -

echo "SecretProviderClass applied successfully!"
kubectl get secretproviderclass -n dev
