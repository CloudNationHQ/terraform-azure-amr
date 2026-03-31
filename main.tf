# managed redis
resource "azurerm_managed_redis" "this" {
  name = var.instance.name

  resource_group_name = coalesce(
    lookup(var.instance, "resource_group_name", null),
    var.resource_group_name
  )

  location = coalesce(
    lookup(var.instance, "location", null),
    var.location
  )

  sku_name                  = var.instance.sku_name
  high_availability_enabled = var.instance.high_availability_enabled
  public_network_access     = var.instance.public_network_access
  tags                      = coalesce(var.instance.tags, var.tags)

  dynamic "default_database" {
    for_each = var.instance.default_database != null ? { "default" = var.instance.default_database } : {}

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
    for_each = var.instance.customer_managed_key != null ? { "default" = var.instance.customer_managed_key } : {}

    content {
      key_vault_key_id          = customer_managed_key.value.key_vault_key_id
      user_assigned_identity_id = customer_managed_key.value.user_assigned_identity_id
    }
  }

  dynamic "identity" {
    for_each = var.instance.identity != null ? [var.instance.identity] : []

    content {
      type         = identity.value.type
      identity_ids = identity.value.identity_ids
    }
  }
}

# access policy assignments
resource "azurerm_managed_redis_access_policy_assignment" "assignments" {
  for_each = var.instance.access_policy_assignments

  managed_redis_id   = azurerm_managed_redis.this.id
  object_id          = each.value.object_id
}

# geo replication
resource "azurerm_managed_redis_geo_replication" "geo_replication" {
  for_each = var.instance.geo_replication != null ? { "default" = var.instance.geo_replication } : {}

  managed_redis_id         = azurerm_managed_redis.this.id
  linked_managed_redis_ids = each.value.linked_managed_redis_ids
}
