module "naming" {
  source  = "cloudnationhq/naming/azure"
  version = "~> 0.26"

  suffix = ["demo", "dev"]
}

module "rg" {
  source  = "cloudnationhq/rg/azure"
  version = "~> 2.0"

  groups = {
    demo = {
      name     = module.naming.resource_group.name_unique
      location = "westeurope"
    }
  }
}

module "cache_secondary" {
  source = "../.."

  instance = {
    name                = "${module.naming.managed_redis.name_unique}-sec"
    location            = "northeurope"
    resource_group_name = module.rg.groups.demo.name
    sku_name            = "Balanced_B3"

    default_database = {
      geo_replication_group_name = "demo-geo-group"
    }
  }

  tags = {
    environment = "demo"
    repository  = "terraform-azure-amr"
  }
}

module "cache_primary" {
  source = "../.."

  instance = {
    name                = module.naming.managed_redis.name_unique
    location            = module.rg.groups.demo.location
    resource_group_name = module.rg.groups.demo.name
    sku_name            = "Balanced_B3"

    default_database = {
      geo_replication_group_name = "demo-geo-group"
    }

    geo_replication = {
      linked_managed_redis_ids = [module.cache_secondary.instance.id]
    }
  }

  tags = {
    environment = "demo"
    repository  = "terraform-azure-amr"
  }
}
