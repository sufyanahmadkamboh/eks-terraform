variable "project_name" {
  type        = string
  description = "Project name for tagging."
}

variable "env_name" {
  type        = string
  description = "Environment name for tagging."
}

variable "vpc_cidr" {
  type        = string
  description = "VPC CIDR block."
}

variable "nat_gateway_count" {
  type        = number
  description = "1 or 2: number of NAT gateways. 2 = one per AZ, 1 = shared NAT (cheaper, less HA)."
}

variable "aws_region" {
  type        = string
  description = "AWS region (used to discover AZs)."
}

variable "eks_cluster_name" {
  type        = string
  description = "EKS cluster name (used for Kubernetes-related subnet tags)."
}

variable "tags" {
  type        = map(string)
  description = "Base tags to apply to VPC resources."
  default     = {}
}
