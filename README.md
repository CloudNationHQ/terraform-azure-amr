# Azure Managed Redis

This terraform module simplifies the creation and management of azure managed redis instances, providing customizable options for geo-replication, access policy assignments, and customer-managed key encryption, all managed through code.

## Features

Supports multiple sku tiers across balanced, memory optimized, compute optimized, and flash optimized workload profiles.

Geo-replication support for cross-region redundancy with configurable group membership.

Access policy assignments for fine-grained authorization control over redis data plane access.

Customer managed key encryption via azure key vault with user assigned identity support.

Managed identity support for secure, credential-free authentication to dependent services.

Configurable redis modules including RediSearch, RedisJSON, RedisBloom, and RedisTimeSeries.

Utilization of terratest for robust validation.

<!-- BEGIN_TF_DOCS -->
## Requirements

The following requirements are needed by this module:

- <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) (~> 1.0)

- <a name="requirement_azurerm"></a> [azurerm](#requirement\_azurerm) (~> 4.0)

## Providers

The following providers are used by this module:

- <a name="provider_azurerm"></a> [azurerm](#provider\_azurerm) (~> 4.0)

## Resources

The following resources are used by this module:

- [azurerm_managed_redis.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/managed_redis) (resource)
- [azurerm_managed_redis_access_policy_assignment.assignments](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/managed_redis_access_policy_assignment) (resource)
- [azurerm_managed_redis_geo_replication.geo_replication](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/managed_redis_geo_replication) (resource)

## Required Inputs

The following input variables are required:

### <a name="input_instance"></a> [instance](#input\_instance)

Description: contains managed redis cache related configuration

Type:

```hcl
object({
    name                      = string
    resource_group_name       = optional(string)
    location                  = optional(string)
    sku_name                  = string
    high_availability_enabled = optional(bool, true)
    public_network_access     = optional(string, "Enabled")
    tags                      = optional(map(string))

    default_database = optional(object({
      access_keys_authentication_enabled            = optional(bool, false)
      client_protocol                               = optional(string, "Encrypted")
      clustering_policy                             = optional(string, "OSSCluster")
      eviction_policy                               = optional(string, "VolatileLRU")
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
      object_id          = string
    })), {})

    geo_replication = optional(object({
      linked_managed_redis_ids = set(string)
    }))
  })
```

## Optional Inputs

The following input variables are optional (have default values):

### <a name="input_location"></a> [location](#input\_location)

Description: default azure region to be used.

Type: `string`

Default: `null`

### <a name="input_naming"></a> [naming](#input\_naming)

Description: contains naming convention

Type: `map(string)`

Default: `{}`

### <a name="input_resource_group_name"></a> [resource\_group\_name](#input\_resource\_group\_name)

Description: default resource group to be used.

Type: `string`

Default: `null`

### <a name="input_tags"></a> [tags](#input\_tags)

Description: tags to be added to the resources

Type: `map(string)`

Default: `{}`

## Outputs

The following outputs are exported:

### <a name="output_access_policy_assignments"></a> [access\_policy\_assignments](#output\_access\_policy\_assignments)

Description: contains all access policy assignments

### <a name="output_geo_replication"></a> [geo\_replication](#output\_geo\_replication)

Description: contains geo replication configuration

### <a name="output_instance"></a> [instance](#output\_instance)

Description: contains all managed redis configuration
<!-- END_TF_DOCS -->

## Goals

For more information, please see our [goals and non-goals](./GOALS.md).

## Testing

For more information, please see our testing [guidelines](./TESTING.md)

## Notes

Using a dedicated module, we've developed a naming convention for resources that's based on specific regular expressions for each type, ensuring correct abbreviations and offering flexibility with multiple prefixes and suffixes.

Full examples detailing all usages, along with integrations with dependency modules, are located in the examples directory.

To update the module's documentation run `make doc`

## Authors

Module is maintained by [these awesome contributors](https://github.com/cloudnationhq/terraform-azure-amr/graphs/contributors).

## Contributors

We welcome contributions from the community! Whether it's reporting a bug, suggesting a new feature, or submitting a pull request, your input is highly valued.

For more information, please see our contribution [guidelines](./CONTRIBUTING.md). <br><br>

<a href="https://github.com/cloudnationhq/terraform-azure-amr/graphs/contributors">
  <img src="https://contrib.rocks/image?repo=cloudnationhq/terraform-azure-amr" />
</a>

## License

MIT Licensed. See [LICENSE](./LICENSE) for full details.

## References

- [Documentation](https://learn.microsoft.com/en-us/azure/azure-cache-for-redis/managed-redis/managed-redis-overview)
- [Rest Api](https://learn.microsoft.com/en-us/rest/api/redis/)
- [Rest Api Specs](https://github.com/Azure/azure-rest-api-specs/tree/main/specification/redis)
