locals {
  # Build a consistent cluster name: project-env[-suffix]
  base_cluster_name = "${var.project_name}-${var.env_name}"
  cluster_name      = var.cluster_name_suffix == "" ? local.base_cluster_name : "${local.base_cluster_name}-${var.cluster_name_suffix}"

  # Control-plane log types when enabled
  eks_enabled_log_types = var.enable_control_plane_logging ? [
    "api",
    "audit",
    "authenticator",
    "controllerManager",
    "scheduler",
  ] : []

  common_tags = merge(
    {
      Name        = local.cluster_name
      Environment = var.env_name
      Project     = var.project_name
      Terraform   = "true"
    },
    var.additional_tags
  )
}
