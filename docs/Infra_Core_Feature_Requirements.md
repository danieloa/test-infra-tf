## IaC core feature requirements (Terraform Edition)

Author: daniel ortega

### Multi-Stage Infrastructure Deployment

The deployment is organized into separated and clear stages (`vpc`, `core`, `apps`), each responsible for a logical layer of infrastructure (e.g., VPC/networking, databases, EKS, S3, Helm charts, IAM, third-party integrations).

### Multi-Region Infra Deployment

This project should be region agnostic in the sense that we do not need to define the region anywhere but using whatever is set in `AWS_REGION` env var or passed via `-var="aws_region=..."`.
Multi-Region: We leave the CI/CD process to reset `AWS_REGION` env var to process multiple regions.

### Modular & Declarative Design

Infrastructure is modularized into reusable Terraform modules under `modules/` (`vpc`, `eks`, `s3`, `core`) and stage root compositions under `stages/` (`vpc`, `core`, `apps`).

### Limited user configurable items

Environment definition YAML files are kept to a minimum (less than 15 lines). Terraform loads these dynamically using `yamldecode()`.

### Automated Tagging

Implements auto-tagging for all resources (Customer, Environment, Region, Product Domain, Stage) to ensure consistent metadata and traceability across environments.

### Kubernetes and Helm Integration

Supports deploying and configuring EKS clusters with auto mode / compute configuration, native IAM roles, and readiness for Karpenter, AWS Load Balancer Controller, and add-ons.

### Secrets and State Management

- Uses AWS S3 backend with bucket versioning and SSE encryption for remote Terraform state.
- Automated creation of state buckets via deployment tool.

### Policy and IAM Management

Centralizes IAM and resource policies with least-privilege principles, attaching required EKS cluster and node policies.

### CI/CD Integration

Includes deployment CLI tool (`cmd/deploy`) and Makefile for automated execution in CI/CD pipelines.
