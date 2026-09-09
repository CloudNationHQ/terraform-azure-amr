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

    default_database = {
      # redis modules require the enterprise clustering policy
      clustering_policy = "EnterpriseCluster"

      modules = {
        search = {
          name = "RediSearch"
        }
        bloom = {
          name = "RedisBloom"
        }
      }
    }
  }

  tags = {
    environment = "demo"
    repository  = "terraform-azure-amr"
  }
}
