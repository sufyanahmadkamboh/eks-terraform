output "cluster_name" {
  description = "Name of the EKS cluster."
  value       = module.eks.cluster_name
}

output "cluster_arn" {
  description = "ARN of the EKS cluster."
  value       = module.eks.cluster_arn
}

output "cluster_endpoint" {
  description = "Endpoint for EKS control plane."
  value       = module.eks.cluster_endpoint
}

output "cluster_certificate_authority_data" {
  description = "Base64-encoded certificate authority data for the EKS cluster."
  value       = module.eks.cluster_certificate_authority_data
}

output "managed_node_groups" {
  description = "Map of all EKS managed node groups and their attributes (from the eks module)."
  value       = module.eks.managed_node_groups
}


# Optional: example kubeconfig blob (you will still normally use aws eks update-kubeconfig)
output "kubeconfig" {
  description = "Minimal kubeconfig for the created EKS cluster (uses certificate & endpoint only). Usually you should prefer aws eks update-kubeconfig."
  value = yamlencode({
    apiVersion = "v1"
    kind       = "Config"
    clusters = [{
      name = module.eks.cluster_name
      cluster = {
        server = module.eks.cluster_endpoint
        "certificate-authority-data" = module.eks.cluster_certificate_authority_data
      }
    }]
    contexts = [{
      name = module.eks.cluster_name
      context = {
        cluster = module.eks.cluster_name
        user    = module.eks.cluster_name
      }
    }]
    "current-context" = module.eks.cluster_name
    users = [{
      name = module.eks.cluster_name
      user = {
        exec = {
          apiVersion = "client.authentication.k8s.io/v1beta1"
          command    = "aws"
          args       = ["eks", "get-token", "--cluster-name", module.eks.cluster_name, "--region", var.aws_region]
        }
      }
    }]
  })
  sensitive = true
}

output "vpc_id" {
  description = "ID of the created VPC."
  value       = module.vpc.vpc_id
}

output "public_subnet_ids" {
  description = "IDs of the public subnets."
  value       = module.vpc.public_subnet_ids
}

output "private_subnet_ids" {
  description = "IDs of the private subnets."
  value       = module.vpc.private_subnet_ids
}

output "eks_cloudwatch_log_group_name" {
  description = "Name of the CloudWatch log group used for EKS control plane logs."
  value       = module.eks.cloudwatch_log_group_name
}
