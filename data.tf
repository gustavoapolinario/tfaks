data "azurerm_client_config" "current" {}

data "http" "my_public_ip" {
  url = "https://checkip.amazonaws.com"
}
locals {
  my_public_ipv4 = chomp(data.http.my_public_ip.response_body)
}
