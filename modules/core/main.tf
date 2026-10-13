# EKS Platform Cluster
module "eks_platform" {
  source = "../eks"

  cluster_name       = "platform"
  subnet_ids         = var.platform_subnet_ids
  customer           = var.customer
  environment        = var.environment
  kubernetes_version = "1.31"
  tags               = var.tags
}

# EKS Tekton Cluster
module "eks_tekton" {
  source = "../eks"

  cluster_name       = "tekton"
  subnet_ids         = var.tekton_subnet_ids
  customer           = var.customer
  environment        = var.environment
  kubernetes_version = "1.31"
  tags               = var.tags
}

locals {
  general_purpose_private_buckets = ["backups", "logs", "general-logs"]
  public_buckets                 = ["images", "assets", "public-data"]
}

# Private S3 Buckets
module "private_s3_buckets" {
  for_each = toset(local.general_purpose_private_buckets)
  source   = "../s3"

  bucket_name = "${each.value}-${var.product_domain}"
  is_public   = false
  with_cors   = false
  tags        = var.tags
}

# Public S3 Buckets
module "public_s3_buckets" {
  for_each = toset(local.public_buckets)
  source   = "../s3"

  bucket_name  = "${each.value}-${var.product_domain}"
  is_public    = true
  with_cors    = true
  cors_origins = ["https://${each.value}-${var.product_domain}"]
  tags         = var.tags
}
