resource "azurerm_resource_group" "this" {
  for_each = local.resource_groups

  name     = each.value.name
  location = local.location
  tags = merge(local.tags, {
    Environment = each.value.role
  })
}
