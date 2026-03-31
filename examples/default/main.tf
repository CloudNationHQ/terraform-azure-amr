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

module "cache" {
  source  = "cloudnationhq/amr/azure"
  version = "~> 1.0"

  instance = {
    name                = module.naming.managed_redis.name_unique
    location            = module.rg.groups.demo.location
    resource_group_name = module.rg.groups.demo.name
    sku_name            = "Balanced_B1"

    default_database = {}
  }

  tags = {
    environment = "demo"
    repository  = "terraform-azure-amr"
  }
}
