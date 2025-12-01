output "cluster_name" {
  description = "EKS cluster name."
  value       = module.eks.cluster_name
}

output "cluster_arn" {
  description = "EKS cluster ARN."
  value       = module.eks.cluster_arn
}

output "cluster_endpoint" {
  description = "EKS cluster API endpoint."
  value       = module.eks.cluster_endpoint
}

output "cluster_certificate_authority_data" {
  description = "EKS cluster certificate authority data."
  value       = module.eks.cluster_certificate_authority_data
}

# Single output with details of all managed node groups
output "managed_node_groups" {
  description = "Map of all EKS managed node groups and their attributes."
  value       = module.eks.eks_managed_node_groups
}

output "cloudwatch_log_group_name" {
  description = "CloudWatch log group name for EKS control plane logs."
  value       = module.eks.cloudwatch_log_group_name
}
