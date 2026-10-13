# EKS Module

This module provisions an AWS EKS Cluster matching `core/eks.go`:
- Dedicated Cluster IAM Role with `AmazonEKSClusterPolicy`, `AmazonEKSComputePolicy`, `AmazonEKSBlockStoragePolicy`, `AmazonEKSLoadBalancingPolicy`, `AmazonEKSNetworkingPolicy`
- Dedicated Node IAM Role with `AmazonEKSWorkerNodeMinimalPolicy`, `AmazonEC2ContainerRegistryPullOnly`, `CloudWatchAgentServerPolicy`
- EKS Cluster Auto Mode / Compute Configuration with `general-purpose` node pools
- Elastic Load Balancing & Block Storage integration enabled
- API access authentication mode
- Private and public endpoint access inside configured subnets
