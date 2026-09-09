moved {
  from = azurerm_managed_redis_access_policy_assignment.assignments
  to   = azurerm_managed_redis_access_policy_assignment.this
}

moved {
  from = azurerm_managed_redis_geo_replication.geo_replication
  to   = azurerm_managed_redis_geo_replication.this
}
