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

module "identity" {
  source  = "cloudnationhq/uai/azure"
  version = "~> 3.0"

  identity = {
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
  version = "~> 6.0"

  vault = {
    name                     = module.naming.key_vault.name_unique
    location                 = module.rg.groups.demo.location
    resource_group_name      = module.rg.groups.demo.name
    purge_protection_enabled = true

    keys = {
      demo = {
        key_type = "RSA"
        key_size = 2048
        key_opts = ["unwrapKey", "wrapKey"]
      }
    }
  }

  tags = {
    environment = "demo"
    repository  = "terraform-azure-amr"
  }
}

module "rbac" {
  source  = "cloudnationhq/rbac/azure"
  version = "~> 4.0"

  role_assignments = {
    crypto_user = {
      display_name = module.identity.identity.name
      type         = "ServicePrincipal"
      roles = {
        "Key Vault Crypto User" = {
          scopes = {
            kv-vault = { id = module.kv.vault.id }
          }
        }
      }
    }
  }

  depends_on = [module.identity]
}

module "cache" {
  source = "../../"

  cache = {
    name                = module.naming.managed_redis.name_unique
    location            = module.rg.groups.demo.location
    resource_group_name = module.rg.groups.demo.name
    sku_name            = "Balanced_B1"

    default_database = {}

    identity = {
      type         = "UserAssigned"
      identity_ids = [module.identity.identity.id]
    }

    customer_managed_key = {
      key_vault_key_id          = module.kv.keys.demo.id
      user_assigned_identity_id = module.identity.identity.id
    }
  }
}
