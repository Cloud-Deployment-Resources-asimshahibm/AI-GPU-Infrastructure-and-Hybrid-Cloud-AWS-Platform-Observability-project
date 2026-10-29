module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "~> 5.0"

  name               = var.name
  cidr               = var.vpc_cidr
  azs                = var.azs
  private_subnets    = [for i, _ in var.azs : cidrsubnet(var.vpc_cidr, 4, i)]
  public_subnets     = [for i, _ in var.azs : cidrsubnet(var.vpc_cidr, 8, 200 + i)]
  enable_nat_gateway = true
  single_nat_gateway = false
  private_subnet_tags = {
    "kubernetes.io/role/internal-elb" = 1
  }
  tags = var.tags
}

module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 20.0"

  cluster_name                   = var.name
  cluster_version                = var.kubernetes_version
  vpc_id                         = module.vpc.vpc_id
  subnet_ids                     = module.vpc.private_subnets
  cluster_endpoint_public_access = false
  enable_irsa                    = true
  enable_cluster_creator_admin_permissions = true

  cluster_enabled_log_types = ["api", "audit", "authenticator"]

  eks_managed_node_groups = {
    general = {
      instance_types = ["m6i.xlarge"]
      min_size       = 3
      max_size       = 9
      desired_size   = 3
    }

    observability = {
      instance_types = ["r6i.2xlarge"]
      min_size       = 3
      max_size       = 12
      desired_size   = 3
      labels         = { dedicated = "observability" }
      taints = {
        dedicated = { key = "dedicated", value = "observability", effect = "NO_SCHEDULE" }
      }
    }

    gpu = {
      ami_type       = "AL2023_x86_64_NVIDIA"
      instance_types = var.gpu_instance_types
      capacity_type  = var.gpu_capacity_type
      min_size       = 0
      max_size       = var.gpu_max_size
      desired_size   = 0
      labels         = { "nvidia.com/gpu.present" = "true", workload = "ai" }
      taints = {
        gpu = { key = "nvidia.com/gpu", value = "true", effect = "NO_SCHEDULE" }
      }
    }
  }

  tags = var.tags
}
