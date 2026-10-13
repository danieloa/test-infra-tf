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
    Stage         = "core"
    ManagedBy     = "terraform"
  }

  state_bucket = "${local.config.customer}-${local.config.environment}-terraform-state"
}

provider "aws" {
  region = local.region
}

# Read VPC stage outputs from remote state
data "terraform_remote_state" "vpc" {
  count   = var.use_remote_state ? 1 : 0
  backend = "s3"

  config = {
    bucket = local.state_bucket
    key    = "${local.config.customer}/vpc/${local.region}/terraform.tfstate"
    region = local.region
  }
}

locals {
  platform_subnet_ids = var.use_remote_state ? data.terraform_remote_state.vpc[0].outputs.platform_subnet_ids : var.override_platform_subnet_ids
  tekton_subnet_ids   = var.use_remote_state ? data.terraform_remote_state.vpc[0].outputs.tekton_subnet_ids : var.override_tekton_subnet_ids
}

module "core" {
  source = "../../modules/core"

  customer            = local.config.customer
  environment         = local.config.environment
  product_domain      = local.config.product_domain
  platform_subnet_ids = local.platform_subnet_ids
  tekton_subnet_ids   = local.tekton_subnet_ids
  tags                = local.tags
}
