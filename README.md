# Terraform AKS


## Usage

### Pre-requisits

- You need installed az cli and terrafom.
- Install jq, gettext-base
- Run sudo az aks install-cli command to install a compatible kubelogin
- Create the azure account if don't have yet.
- Create a group on Azure Entra-Id to have access to AKS.
- add alb extension az extension add --name alb

### Provider

Verify the configuration on provider.tf to make sure has the wanted configuration.
```bash
code provider.tf
```

### Prepare your project

This command will install the providers needed for the project

```bash
terraform init
```

### Verify the tfvars file

Verify the terraform.tfvars file to put your values.

```bash
code terraform.tfvars
```

### Sensitive tfvars
Create a terraform-sensitive.auto-tfvars to put sensitive variables. I make it be ignored by git

```bash
code terraform-sensitive.auto-tfvars
```

```yaml
ssh_public_key = "..."
```

### Login on Azure CLI

> Remember! Avoid using root access, create another user to make day-a-day work.

```bash
az login
```

Configure Subscription Id to avoid hard coded.

```bash
az account list --output table
export ARM_SUBSCRIPTION_ID="xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx"

or

export ARM_SUBSCRIPTION_ID=$(az account list --query "[?isDefault].id" -o tsv)
```

### Run the IaC

```bash
terraform apply
```

### Get AKS Credentials

To use kubectl commands, you need to get the credentials first.

```bash
az aks get-credentials --name tfaks-dev-aks --resource-group tfaks-dev-rg --overwrite-existing
```

### Verify the kubernetes

```bash
kubectl get nodes
kubectl get pods -A
```

### Run the Secret Provider Class

To run secrets with Azure Key Vault (akv), install the SecretProviderClass to integrate AKV created on app.tf with the AKS

```bash
kubectl create namespace dev
./scripts/secret-provider-class-azure-kv-example.sh
./scripts/create-ssl-certificate.sh
./scripts/app-gateway-for-containers.sh
```

### Run the sample

To verify if everything is working, run the sample

```bash
kubectl apply -f sample/front-end.yml
```
