variable "cache" {
  description = "contains managed redis cache related configuration"
  type = object({
    name                      = string
    resource_group_name       = optional(string)
    location                  = optional(string)
    sku_name                  = string
    high_availability_enabled = optional(bool)
    public_network_access     = optional(string)
    tags                      = optional(map(string))

    default_database = optional(object({
      access_keys_authentication_enabled            = optional(bool)
      client_protocol                               = optional(string)
      clustering_policy                             = optional(string)
      eviction_policy                               = optional(string)
      geo_replication_group_name                    = optional(string)
      persistence_append_only_file_backup_frequency = optional(string)
      persistence_redis_database_backup_frequency   = optional(string)
      modules = optional(map(object({
        name = string
        args = optional(string)
      })), {})
    }))

    customer_managed_key = optional(object({
      key_vault_key_id          = string
      user_assigned_identity_id = string
    }))

    identity = optional(object({
      type         = string
      identity_ids = optional(list(string))
    }))

    access_policy_assignments = optional(map(object({
      object_id = string
    })), {})

    geo_replication = optional(object({
      linked_managed_redis_ids = set(string)
    }))
  })

  validation {
    condition     = lookup(var.cache, "location", null) != null || var.location != null
    error_message = "location must be set on var.cache.location or on the module-level var.location."
  }

  validation {
    condition     = lookup(var.cache, "resource_group_name", null) != null || var.resource_group_name != null
    error_message = "resource_group_name must be set on var.cache.resource_group_name or on the module-level var.resource_group_name."
  }
}

variable "location" {
  description = "default azure region to be used."
  type        = string
  default     = null
}

variable "resource_group_name" {
  description = "default resource group to be used."
  type        = string
  default     = null
}

variable "tags" {
  description = "tags to be added to the resources"
  type        = map(string)
  default     = {}
}
