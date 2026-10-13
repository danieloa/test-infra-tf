# danieloa-infrastructure-tf

An Infrastructure as Code (IaC) solution using **Terraform (HCL)** to provision AWS infrastructure for the "danieloa" platform. This project is the direct sibling of [`test-infra-go`](../test-infra-go), implementing the exact same architecture, resource specifications, and multi-stage lifecycle using idiomatic Terraform.

---

## 1. Architecture & Design Principles

* **Multi-Stage Deployment:** Infrastructure is decoupled into distinct, independent stages:
  * **Stage 1 (`vpc`):** Networking foundation (VPC, dynamic subnets, NAT gateways, route tables, security groups).
  * **Stage 2 (`core`):** Core platform services (EKS clusters with auto mode, private and public S3 buckets).
  * **Stage 3 (`apps`):** Application workloads and Helm configurations.
* **Multi-Region & Environment Agnostic:** Target region is controlled via `AWS_REGION` or `-var="aws_region=..."`.
* **Concise YAML Configuration:** High-level environment parameters are maintained in minimal YAML files (`deployment-configurations/*.yaml`) and loaded natively into Terraform via `yamldecode()`.
* **Cross-Stage State Sharing:** Downstream stages (`core`, `apps`) query upstream outputs using `data "terraform_remote_state"`.
* **Automated Tagging:** Consistent metadata tags (`Customer`, `Environment`, `Region`, `ProductDomain`, `Stage`, `ManagedBy = "terraform"`) are applied across all AWS resources.

---

## 2. Project Structure

```text
test-infra-tf/
├── deployment-configurations/           # Environment YAML configs (shared spec with test-infra-go)
│   ├── us-east-1_dev.yaml
│   └── us-west-2_dev.yaml
├── modules/                             # Reusable Terraform modules
│   ├── vpc/                             # VPC, dynamic subnets, NATs, routes, security groups
│   ├── eks/                             # EKS cluster with auto-mode & IAM roles
│   ├── s3/                              # Unified S3 bucket module (SSE-S3, versioning, lifecycle, CORS)
│   ├── core/                            # Orchestrates platform/tekton EKS and S3 buckets
│   └── apps/                            # Placeholder for application layer
├── stages/                              # Root composition stages with remote state backends
│   ├── vpc/                             # Stage 1 root module
│   ├── core/                            # Stage 2 root module (consumes vpc remote state)
│   └── apps/                            # Stage 3 root module (consumes core remote state)
├── cmd/deploy/                          # Go CLI deployment tool matching test-infra-go
│   └── main.go
├── docs/
│   └── Infra_Core_Feature_Requirements.md
├── Makefile                             # Build, plan, and apply helpers
├── go.mod / go.sum
└── README.md
```

---

## 3. Configuration

Configuration files live in `deployment-configurations/` and follow the exact same schema as `test-infra-go`:

```yaml
environment: dev
customer: danieloa
vpc_cidr: "10.0.0.0/16"
availability_zones: ["us-east-1a", "us-east-1b", "us-east-1c"]
product_domain: danieloa-vpc.example.com
company_ip: "0.0.0.0/0"
```

In Terraform, each stage loads the configuration file dynamically:

```hcl
locals {
  config = yamldecode(file("${path.root}/../../deployment-configurations/${var.config_file}"))
}
```

---

## 4. Module Details

### VPC Module (`modules/vpc/`)
* **VPC:** DNS support and hostnames enabled.
* **Subnets:** Generates 4 subnet types (`public`, `platform`, `tekton`, `database`) across all specified availability zones.
* **Dynamic CIDR Math:** Computes `bits_needed = ceil(log(total_subnets, 2))` and uses `cidrsubnet()` to partition the parent CIDR block (matching Go's `getNthSubnet` power-of-2 logic).
* **Tagging:** Automatically tags subnets for Karpenter (`karpenter.sh/discovery`) and Kubernetes load balancers (`kubernetes.io/role/elb`, `kubernetes.io/role/internal-elb`).
* **Routing:** Public route table with Internet Gateway; dedicated NAT Gateways and Elastic IPs for `platform` and `tekton`; `database` subnets routed through the platform NAT.
* **Security Groups:** EKS security group (VPC traffic + HTTPS from `company_ip`), PostgreSQL database security group (VPC internal on port 5432).

### Core Module (`modules/core/`)
* **EKS Clusters:** Provisions two independent clusters (`platform` and `tekton`) with auto mode compute config, IAM cluster role, and node role with attached policies (`AmazonEKSClusterPolicy`, `AmazonEKSComputePolicy`, `AmazonEKSBlockStoragePolicy`, `AmazonEKSLoadBalancingPolicy`, `AmazonEKSNetworkingPolicy`, `CloudWatchAgentServerPolicy`).
* **Private S3 Buckets:** `backups`, `logs`, `general-logs` (named `<name>-<product_domain>`) with AES256 encryption, bucket versioning, non-current version transitions to `STANDARD_IA` (90d) and `GLACIER` (180d), and public access block enabled.
* **Public S3 Buckets:** `images`, `assets`, `public-data` with CORS configuration.

---

## 5. Usage & Deployment

### Option A: Using the Deploy CLI Tool

The project includes a Go CLI under `cmd/deploy` that verifies AWS STS credentials and automates backend initialization and staged executions:

```bash
# 1. Build the tool
make build

# 2. Initialize S3 backend state bucket
./bin/deploy init --config deployment-configurations/us-east-1_dev.yaml

# 3. Plan / preview stages
./bin/deploy vpc --action plan
./bin/deploy core --action plan
./bin/deploy apps --action plan

# 4. Apply stages
./bin/deploy vpc --action apply
./bin/deploy core --action apply
./bin/deploy apps --action apply
```

### Option B: Using the Makefile

```bash
# Plan
make plan-vpc
make plan-core
make plan-apps

# Deploy
make deploy-vpc
make deploy-core
make deploy-apps

# Destroy
make destroy-apps
make destroy-core
make destroy-vpc
```

### Option C: Using Native Terraform Directly

Each stage under `stages/` can be managed directly with the Terraform CLI:

```bash
cd stages/vpc

# Initialize with S3 backend
terraform init \
  -backend-config="bucket=danieloa-dev-terraform-state" \
  -backend-config="key=danieloa/vpc/us-east-1/terraform.tfstate" \
  -backend-config="region=us-east-1"

# Plan and apply
terraform plan -var="config_file=us-east-1_dev.yaml" -var="aws_region=us-east-1"
terraform apply -var="config_file=us-east-1_dev.yaml" -var="aws_region=us-east-1"
```

---

## 6. Pulumi vs. Terraform Implementation Parity

| Feature | `test-infra-go` (Pulumi) | `test-infra-tf` (Terraform) |
| :--- | :--- | :--- |
| **Language** | Go (`pulumi-aws/sdk/v6`) | HCL (`hashicorp/aws ~> 5.0`) |
| **Config Format** | YAML (`gopkg.in/yaml.v3`) | YAML (`yamldecode()`) |
| **Stage Separation** | Pulumi Stacks (`vpc`, `core`, `apps`) | Root stage directories (`stages/vpc`, `stages/core`, `stages/apps`) |
| **Cross-Stage Data** | `pulumi.NewStackReference` | `data "terraform_remote_state"` |
| **State Storage** | S3 Backend (`s3://<customer>-<env>-pulumi-state`) | S3 Backend (`s3://<customer>-<env>-terraform-state`) |
| **Subnet Partitioning** | Custom Go CIDR math (`getNthSubnet`) | HCL `cidrsubnet()` + power-of-2 `ceil(log(n, 2))` |
| **Automation CLI** | Go Cobra CLI (`bin/deploy`) | Go Cobra CLI (`bin/deploy`) |
