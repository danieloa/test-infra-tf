# Core Module

This module orchestrates the **Stage 2 (Core)** infrastructure layer matching `core/core.go`:
- Provisions two EKS clusters using the `eks` module:
  - `platform` EKS cluster
  - `tekton` EKS cluster
- Provisions general-purpose private S3 buckets (`backups`, `logs`, `general-logs`) with SSE-S3 encryption and lifecycle policies
- Provisions public S3 buckets (`images`, `assets`, `public-data`) with CORS configuration
