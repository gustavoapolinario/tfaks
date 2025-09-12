resource "null_resource" "register_providers" {
  provisioner "local-exec" {
    command = <<EOT
      # Mandatory to AKS Key Vault integration
      if ! az provider show --namespace Microsoft.ServiceLinker --query registrationState -o tsv | grep -q "Registered"; then
        az provider register --namespace Microsoft.ServiceLinker
        az provider wait --namespace Microsoft.ServiceLinker --registered
      fi

      # Mandatory to AKS Key Vault integration 
      if ! az provider show --namespace Microsoft.KubernetesConfiguration --query registrationState -o tsv | grep -q "Registered"; then
        az provider register --namespace Microsoft.KubernetesConfiguration
        az provider wait --namespace Microsoft.KubernetesConfiguration --registered
      fi

      # Mandatory to Application Gateway for Containers ALB Controller
      if ! az provider show --namespace Microsoft.ContainerService --query registrationState -o tsv | grep -q "Registered"; then
        az provider register --namespace Microsoft.ContainerService
        az provider wait --namespace Microsoft.ContainerService --registered
      fi

      # Mandatory to Application Gateway for Containers ALB Controller
      if ! az provider show --namespace Microsoft.Network --query registrationState -o tsv | grep -q "Registered"; then
        az provider register --namespace Microsoft.Network
        az provider wait --namespace Microsoft.Network --registered
      fi

      # Mandatory to Application Gateway for Containers ALB Controller
      if ! az provider show --namespace Microsoft.NetworkFunction --query registrationState -o tsv | grep -q "Registered"; then
        az provider register --namespace Microsoft.NetworkFunction
        az provider wait --namespace Microsoft.NetworkFunction --registered
      fi

      # Mandatory to Application Gateway for Containers ALB Controller
      if ! az provider show --namespace Microsoft.ServiceNetworking --query registrationState -o tsv | grep -q "Registered"; then
        az provider register --namespace Microsoft.ServiceNetworking
        az provider wait --namespace Microsoft.ServiceNetworking --registered
      fi
    EOT
  }
}

resource "azapi_resource" "aks_keyvault_connection" {
  for_each  = var.akv_connections
  type      = "Microsoft.ServiceLinker/linkers@2024-07-01-preview"
  name      = "${replace(local.cluster_name, "-", "_")}_${replace(each.key, "-", "_")}"
  parent_id = azurerm_kubernetes_cluster.aks.id

  body = {
    properties = {
      authInfo = {
        authType = "userAssignedIdentity"
      }
      clientType = "none"

      targetService = {
        type = "AzureResource"
        id   = each.value
        resourceProperties = {
          connectAsKubernetesCsiDriver = true
          type                         = "KeyVault"
        }
      }
    }
  }

  depends_on = [
    null_resource.register_providers,
    azurerm_kubernetes_cluster.aks,
  ]
}
