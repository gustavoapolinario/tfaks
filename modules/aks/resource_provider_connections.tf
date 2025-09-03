resource "null_resource" "register_providers" {
  provisioner "local-exec" {
    command = <<EOT
      # Register Microsoft.ServiceLinker if not registered
      if ! az provider show --namespace Microsoft.ServiceLinker --query registrationState -o tsv | grep -q "Registered"; then
        az provider register --namespace Microsoft.ServiceLinker
        az provider wait --namespace Microsoft.ServiceLinker --registered
      fi

      # Register Microsoft.KubernetesConfiguration if not registered  
      if ! az provider show --namespace Microsoft.KubernetesConfiguration --query registrationState -o tsv | grep -q "Registered"; then
        az provider register --namespace Microsoft.KubernetesConfiguration
        az provider wait --namespace Microsoft.KubernetesConfiguration --registered
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
