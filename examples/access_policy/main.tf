data "azurerm_client_config" "current" {}

module "naming" {
  source  = "cloudnationhq/naming/azure"
  version = "~> 0.26"

  suffix = ["demo", "dev"]
}

module "rg" {
  source  = "cloudnationhq/rg/azure"
  version = "~> 3.0"

  groups = {
    demo = {
      name     = module.naming.resource_group.name_unique
      location = "swedencentral"
    }
  }
}

module "cache" {
  source = "../../"

  cache = {
    name                = module.naming.managed_redis.name_unique
    location            = module.rg.groups.demo.location
    resource_group_name = module.rg.groups.demo.name
    sku_name            = "Balanced_B1"

    default_database = {}

    access_policy_assignments = {
      owner = {
        object_id = data.azurerm_client_config.current.object_id
      }
    }
  }
}
