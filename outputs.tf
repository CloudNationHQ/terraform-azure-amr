output "cache" {
  description = "contains all managed redis configuration"
  value       = azurerm_managed_redis.this
}

output "access_policy_assignments" {
  description = "contains all access policy assignments"
  value       = azurerm_managed_redis_access_policy_assignment.this
}

output "geo_replication" {
  description = "contains geo replication configuration"
  value       = azurerm_managed_redis_geo_replication.this
}
