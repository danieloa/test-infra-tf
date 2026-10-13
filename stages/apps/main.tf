terraform {
  required_version = ">= 1.5.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }

  backend "s3" {}
}

locals {
  config_path = "${path.root}/../../deployment-configurations/${var.config_file}"
  config      = yamldecode(file(local.config_path))
  region      = var.aws_region != "" ? var.aws_region : "us-east-1"

  tags = {
    Customer      = local.config.customer
    Environment   = local.config.environment
    Region        = local.region
    ProductDomain = local.config.product_domain
    Stage         = "apps"
    ManagedBy     = "terraform"
  }

  state_bucket = "${local.config.customer}-${local.config.environment}-terraform-state"
}

provider "aws" {
  region = local.region
}

# Read Core stage outputs from remote state
data "terraform_remote_state" "core" {
  count   = var.use_remote_state ? 1 : 0
  backend = "s3"

  config = {
    bucket = local.state_bucket
    key    = "${local.config.customer}/core/${local.region}/terraform.tfstate"
    region = local.region
  }
}

module "apps" {
  source = "../../modules/apps"

  customer                   = local.config.customer
  environment                = local.config.environment
  platform_cluster_id        = var.use_remote_state ? data.terraform_remote_state.core[0].outputs.platform_cluster_id : ""
  platform_cluster_endpoint  = var.use_remote_state ? data.terraform_remote_state.core[0].outputs.platform_cluster_endpoint : ""
  tags                       = local.tags
}
