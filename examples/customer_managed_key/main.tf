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

module "identity" {
  source  = "cloudnationhq/uai/azure"
  version = "~> 2.0"

  config = {
    name                = module.naming.user_assigned_identity.name
    location            = module.rg.groups.demo.location
    resource_group_name = module.rg.groups.demo.name
  }

  tags = {
    environment = "demo"
    repository  = "terraform-azure-amr"
  }
}

module "kv" {
  source  = "cloudnationhq/kv/azure"
  version = "~> 4.0"

  naming = local.naming

  vault = {
    name                = module.naming.key_vault.name_unique
    location            = module.rg.groups.demo.location
    resource_group_name = module.rg.groups.demo.name
    purge_protection_enabled = true

    keys = {
      demo = {
        key_type = "RSA"
        key_size = 2048
        key_opts = ["unwrapKey", "wrapKey"]

        role_assignments = {
          crypto_user = {
            role_definition_name = "Key Vault Crypto User"
            principal_id         = module.identity.config.principal_id
          }
        }
      }
    }
  }

  tags = {
    environment = "demo"
    repository  = "terraform-azure-amr"
  }
}

module "cache" {
  source = "../.."

  instance = {
    name                = module.naming.managed_redis.name_unique
    location            = module.rg.groups.demo.location
    resource_group_name = module.rg.groups.demo.name
    sku_name            = "Balanced_B1"

    default_database = {}

    identity = {
      type         = "UserAssigned"
      identity_ids = [module.identity.config.id]
    }

    customer_managed_key = {
      key_vault_key_id          = module.kv.keys.demo.id
      user_assigned_identity_id = module.identity.config.id
    }
  }

  tags = {
    environment = "demo"
    repository  = "terraform-azure-amr"
  }
}
