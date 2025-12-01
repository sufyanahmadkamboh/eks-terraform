# We wrap the official terraform-aws-modules/eks/aws module for reuse.
module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 21.10" # Pin to a stable v21 line (upgradeable later). :contentReference[oaicite:1]{index=1}

  name               = var.cluster_name
  kubernetes_version = var.kubernetes_version

  vpc_id     = var.vpc_id
  subnet_ids = var.private_subnet_ids
  # Optionally, you could add control_plane_subnet_ids using either private or separate "intra" subnets.

  endpoint_private_access = var.endpoint_private_access
  endpoint_public_access  = var.endpoint_public_access
  endpoint_public_access_cidrs     = var.public_access_cidrs

  enable_irsa                              = var.enable_irsa
  enable_cluster_creator_admin_permissions = var.enable_cluster_creator_admin_permissions

  # Control-plane logging -> CloudWatch
  enabled_log_types                 = var.enabled_log_types
  create_cloudwatch_log_group       = length(var.enabled_log_types) > 0
  cloudwatch_log_group_retention_in_days = var.cloudwatch_log_group_retention_in_days

  # Enable core addons; pod identity agent is useful when you use IRSA / pod identity.
  addons = {
    coredns = {
      most_recent = true
    }
    kube-proxy = {
      most_recent = true
    }
    vpc-cni = {
      most_recent = true
    }
    eks-pod-identity-agent = {
      most_recent = true
      # often recommended before compute resources in v21
      before_compute = true
    }
  }



  eks_managed_node_groups = {
    default = {
      min_size     = var.node_min_size
      max_size     = var.node_max_size
      desired_size = var.node_desired_capacity
      # Additional per-node-group overrides can go here if needed.
    }
  }

  authentication_mode = "API_AND_CONFIG_MAP"

  tags = merge(
    var.tags,
    {
      "kubernetes.io/cluster/${var.cluster_name}" = "owned"
    }
  )
}
