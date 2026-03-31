output "instance" {
  description = "contains all managed redis configuration"
  value       = azurerm_managed_redis.this
}

output "access_policy_assignments" {
  description = "contains all access policy assignments"
  value       = azurerm_managed_redis_access_policy_assignment.assignments
}

output "geo_replication" {
  description = "contains geo replication configuration"
  value       = azurerm_managed_redis_geo_replication.geo_replication
}
