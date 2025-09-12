output "vnet_id" {
  description = "The ID of the Virtual Network."
  value       = azurerm_virtual_network.vnet.id
}

output "lb_subnet_id" {
  description = "The ID of the lb subnet."
  value       = var.create_lb_subnet ? azurerm_subnet.lb_subnet[0].id : null
}

output "private_subnet_id" {
  description = "The ID of the private subnet."
  value       = azurerm_subnet.private_subnet.id
}

output "private_isolated_subnet_id" {
  description = "The ID of the private isolated subnet."
  value       = var.create_private_isolated_subnet ? azurerm_subnet.private_isolated_subnet[0].id : null
}
