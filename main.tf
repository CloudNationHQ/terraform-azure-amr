# managed redis
resource "azurerm_managed_redis" "this" {
  name = var.cache.name

  resource_group_name = coalesce(
    var.cache.resource_group_name, var.resource_group_name
  )

  location = coalesce(
    var.cache.location, var.location
  )

  sku_name                  = var.cache.sku_name
  high_availability_enabled = var.cache.high_availability_enabled
  public_network_access     = var.cache.public_network_access
  tags                      = coalesce(var.cache.tags, var.tags)

  dynamic "default_database" {
    for_each = var.cache.default_database != null ? { "this" = var.cache.default_database } : {}

    content {
      access_keys_authentication_enabled            = default_database.value.access_keys_authentication_enabled
      client_protocol                               = default_database.value.client_protocol
      clustering_policy                             = default_database.value.clustering_policy
      eviction_policy                               = default_database.value.eviction_policy
      geo_replication_group_name                    = default_database.value.geo_replication_group_name
      persistence_append_only_file_backup_frequency = default_database.value.persistence_append_only_file_backup_frequency
      persistence_redis_database_backup_frequency   = default_database.value.persistence_redis_database_backup_frequency

      dynamic "module" {
        for_each = default_database.value.modules
        iterator = redis_module

        content {
          name = redis_module.value.name
          args = redis_module.value.args
        }
      }
    }
  }

  dynamic "customer_managed_key" {
    for_each = var.cache.customer_managed_key != null ? { "this" = var.cache.customer_managed_key } : {}

    content {
      key_vault_key_id          = customer_managed_key.value.key_vault_key_id
      user_assigned_identity_id = customer_managed_key.value.user_assigned_identity_id
    }
  }

  dynamic "identity" {
    for_each = var.cache.identity != null ? { "this" = var.cache.identity } : {}

    content {
      type         = identity.value.type
      identity_ids = identity.value.identity_ids
    }
  }
}

resource "azurerm_managed_redis_access_policy_assignment" "this" {
  for_each = var.cache.access_policy_assignments

  managed_redis_id = azurerm_managed_redis.this.id
  object_id        = each.value.object_id
}

resource "azurerm_managed_redis_geo_replication" "this" {
  for_each = var.cache.geo_replication != null ? { "default" = var.cache.geo_replication } : {}

  managed_redis_id         = azurerm_managed_redis.this.id
  linked_managed_redis_ids = each.value.linked_managed_redis_ids
}
