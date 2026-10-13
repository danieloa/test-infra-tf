# VPC Module

This module provisions the **Stage 1 (VPC)** networking foundation for the platform:
- AWS VPC with DNS resolution and hostnames enabled
- Internet Gateway for public ingress/egress
- Subnets dynamically calculated using CIDR math:
  - `public` subnets (with `kubernetes.io/role/elb: 1`)
  - `platform` subnets (with `kubernetes.io/role/internal-elb: 1` and `karpenter.sh/discovery`)
  - `tekton` subnets (with `kubernetes.io/role/internal-elb: 1` and `karpenter.sh/discovery`)
  - `database` subnets
- Dedicated NAT Gateways with Elastic IPs for `platform` and `tekton`
- Route tables with public IGW and private NAT routing
- Security Groups:
  - EKS cluster security group (HTTPS from company IP, VPC internal traffic)
  - RDS database security group (PostgreSQL 5432 from VPC internal)
