# We wrap the official terraform-aws-modules/eks/aws module for reuse.
module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 21.10"

  name               = var.cluster_name
  kubernetes_version = var.kubernetes_version

  vpc_id     = var.vpc_id
  subnet_ids = var.private_subnet_ids

  endpoint_private_access         = var.endpoint_private_access
  endpoint_public_access          = var.endpoint_public_access
  endpoint_public_access_cidrs    = var.public_access_cidrs

  enable_irsa                              = var.enable_irsa
  enable_cluster_creator_admin_permissions = var.enable_cluster_creator_admin_permissions

  enabled_log_types                       = var.enabled_log_types
  create_cloudwatch_log_group             = length(var.enabled_log_types) > 0
  cloudwatch_log_group_retention_in_days  = var.cloudwatch_log_group_retention_in_days

  # ✅ This is the correct syntax for v21.x
  addons = {
    coredns = {
      most_recent       = true
      resolve_conflicts = "OVERWRITE"
      before_compute = true
    }
    kube-proxy = {
      most_recent       = true
      resolve_conflicts = "OVERWRITE"
      before_compute = true
    }
    vpc-cni = {
      most_recent       = true
      resolve_conflicts = "OVERWRITE"
      before_compute = true
    }
    eks-pod-identity-agent = {
      most_recent    = true
      before_compute = true
    }
  }

  eks_managed_node_groups = {
    default = {
      min_size     = var.node_min_size
      max_size     = var.node_max_size
      desired_size = var.node_desired_capacity
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
