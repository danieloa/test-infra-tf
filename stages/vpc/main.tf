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
    Stage         = "vpc"
    ManagedBy     = "terraform"
  }
}

provider "aws" {
  region = local.region
}

module "vpc" {
  source = "../../modules/vpc"

  customer           = local.config.customer
  environment        = local.config.environment
  vpc_cidr           = local.config.vpc_cidr
  availability_zones = local.config.availability_zones
  product_domain     = local.config.product_domain
  company_ip         = try(local.config.company_ip, "0.0.0.0/0")
  tags               = local.tags
}
