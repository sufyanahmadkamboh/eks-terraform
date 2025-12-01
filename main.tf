module "vpc" {
  source = "./modules/vpc"

  project_name       = var.project_name
  env_name           = var.env_name
  vpc_cidr           = var.vpc_cidr
  nat_gateway_count  = var.nat_gateway_count
  aws_region         = var.aws_region
  eks_cluster_name   = local.cluster_name
  tags               = local.common_tags
}

module "eks" {
  source  = "./modules/eks"

  project_name  = var.project_name
  env_name      = var.env_name
  cluster_name  = local.cluster_name

  vpc_id              = module.vpc.vpc_id
  private_subnet_ids  = module.vpc.private_subnet_ids
  public_subnet_ids   = module.vpc.public_subnet_ids

  kubernetes_version  = var.kubernetes_version

  endpoint_private_access = true
  endpoint_public_access  = true
  public_access_cidrs     = var.cluster_public_access_cidrs

  enable_irsa                              = var.enable_irsa
  enable_cluster_creator_admin_permissions = var.enable_cluster_creator_admin_permissions

  node_instance_types    = var.node_instance_types
  node_desired_capacity  = var.node_desired_capacity
  node_min_size          = var.node_min_size
  node_max_size          = var.node_max_size
  node_capacity_type     = var.node_capacity_type
  node_ssh_key_name      = var.node_ssh_key_name
  enable_ssm_on_nodes    = var.enable_ssm_on_nodes

  enabled_log_types                 = local.eks_enabled_log_types
  cloudwatch_log_group_retention_in_days = var.eks_log_retention_days

  tags = local.common_tags
}
