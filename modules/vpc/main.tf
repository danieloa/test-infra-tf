locals {
  subnet_types  = ["public", "platform", "tekton", "database"]
  total_subnets = length(local.subnet_types) * length(var.availability_zones)
  # Calculate bits needed to subdivide parent CIDR, rounding up to next power of 2
  bits_needed   = ceil(log(local.total_subnets, 2))

  # Flatten all subnet definitions across subnet types and availability zones
  subnets_flat = flatten([
    for type_idx, type in local.subnet_types : [
      for az_idx, az in var.availability_zones : {
        key         = "${type}-${az_idx}"
        type        = type
        az          = az
        az_idx      = az_idx
        cidr_block  = cidrsubnet(var.vpc_cidr, local.bits_needed, type_idx * length(var.availability_zones) + az_idx)
        is_public   = type == "public"
      }
    ]
  ])

  subnets_map = {
    for s in local.subnets_flat : s.key => s
  }
}

# VPC
resource "aws_vpc" "this" {
  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = merge(
    var.tags,
    {
      Name = "${var.customer}-vpc"
    }
  )
}

# Internet Gateway
resource "aws_internet_gateway" "this" {
  vpc_id = aws_vpc.this.id

  tags = merge(
    var.tags,
    {
      Name = "${var.customer}-igw"
    }
  )
}

# Subnets
resource "aws_subnet" "this" {
  for_each = local.subnets_map

  vpc_id                  = aws_vpc.this.id
  cidr_block              = each.value.cidr_block
  availability_zone       = each.value.az
  map_public_ip_on_launch = each.value.is_public

  tags = merge(
    var.tags,
    {
      Name = "${var.customer}-${each.value.type}-subnet-${each.value.az_idx}"
      Type = each.value.type
    },
    each.value.type == "public" ? {
      "kubernetes.io/role/elb" = "1"
    } : {},
    contains(["platform", "tekton"], each.value.type) ? {
      "kubernetes.io/role/internal-elb" = "1"
      "karpenter.sh/discovery"         = "${var.customer}-${var.environment}"
    } : {},
    {
      "kubernetes.io/cluster/${var.customer}-${var.environment}-platform" = "shared"
      "kubernetes.io/cluster/${var.customer}-${var.environment}-tekton"   = "shared"
    }
  )
}

# Elastic IPs for NAT Gateways
resource "aws_eip" "platform" {
  domain = "vpc"

  tags = merge(
    var.tags,
    {
      Name = "${var.customer}-platform-nat-eip"
    }
  )
}

resource "aws_eip" "tekton" {
  domain = "vpc"

  tags = merge(
    var.tags,
    {
      Name = "${var.customer}-tekton-nat-eip"
    }
  )
}

# NAT Gateways
resource "aws_nat_gateway" "platform" {
  allocation_id = aws_eip.platform.id
  subnet_id     = aws_subnet.this["public-0"].id

  tags = merge(
    var.tags,
    {
      Name = "${var.customer}-platform-nat-gateway"
    }
  )

  depends_on = [aws_internet_gateway.this]
}

resource "aws_nat_gateway" "tekton" {
  allocation_id = aws_eip.tekton.id
  subnet_id     = length(var.availability_zones) > 1 ? aws_subnet.this["public-1"].id : aws_subnet.this["public-0"].id

  tags = merge(
    var.tags,
    {
      Name = "${var.customer}-tekton-nat-gateway"
    }
  )

  depends_on = [aws_internet_gateway.this]
}

# Route Tables
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.this.id

  tags = merge(
    var.tags,
    {
      Name = "${var.customer}-public-rt"
    }
  )
}

resource "aws_route" "public_internet" {
  route_table_id         = aws_route_table.public.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.this.id
}

resource "aws_route_table" "platform" {
  vpc_id = aws_vpc.this.id

  tags = merge(
    var.tags,
    {
      Name = "${var.customer}-platform-rt"
    }
  )
}

resource "aws_route" "platform_nat" {
  route_table_id         = aws_route_table.platform.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.platform.id
}

resource "aws_route_table" "tekton" {
  vpc_id = aws_vpc.this.id

  tags = merge(
    var.tags,
    {
      Name = "${var.customer}-tekton-rt"
    }
  )
}

resource "aws_route" "tekton_nat" {
  route_table_id         = aws_route_table.tekton.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.tekton.id
}

resource "aws_route_table" "database" {
  vpc_id = aws_vpc.this.id

  tags = merge(
    var.tags,
    {
      Name = "${var.customer}-database-rt"
    }
  )
}

# Database routes through platform NAT Gateway
resource "aws_route" "database_nat" {
  route_table_id         = aws_route_table.database.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.platform.id
}

# Route Table Associations
resource "aws_route_table_association" "this" {
  for_each = local.subnets_map

  subnet_id = aws_subnet.this[each.key].id
  route_table_id = (
    each.value.type == "public" ? aws_route_table.public.id :
    each.value.type == "platform" ? aws_route_table.platform.id :
    each.value.type == "tekton" ? aws_route_table.tekton.id :
    aws_route_table.database.id
  )
}

# Security Groups
resource "aws_security_group" "eks" {
  name        = "${var.customer}-eks-sg"
  description = "Security group for EKS cluster"
  vpc_id      = aws_vpc.this.id

  ingress {
    description = "All traffic from VPC"
    from_port   = 0
    to_port     = 65535
    protocol    = "tcp"
    cidr_blocks = [var.vpc_cidr]
  }

  ingress {
    description = "HTTPS from company IP"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = [var.company_ip]
  }

  egress {
    description = "All outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(
    var.tags,
    {
      Name = "${var.customer}-eks-sg"
    }
  )
}

resource "aws_security_group" "database" {
  name        = "${var.customer}-database-sg"
  description = "Security group for RDS database"
  vpc_id      = aws_vpc.this.id

  ingress {
    description = "PostgreSQL from VPC"
    from_port   = 5432
    to_port     = 5432
    protocol    = "tcp"
    cidr_blocks = [var.vpc_cidr]
  }

  egress {
    description = "All outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(
    var.tags,
    {
      Name = "${var.customer}-database-sg"
    }
  )
}
