variable "project_name" {
  type        = string
  description = "Logical project name used as prefix for resources."
  default     = "eks-demo"
}

variable "env_name" {
  type        = string
  description = "Environment name (e.g., dev, stage, prod)."
}

variable "aws_region" {
  type        = string
  description = "AWS region to deploy into."
  default     = "us-east-1"
}

variable "aws_profile" {
  type        = string
  description = "AWS shared credentials profile name. Leave empty to use default environment credentials."
  default     = ""
}

variable "vpc_cidr" {
  type        = string
  description = "CIDR block for the VPC."
  default     = "10.0.0.0/16"
}

variable "nat_gateway_count" {
  type        = number
  description = "Number of NAT Gateways: 1 for cost-saving, 2 for per-AZ HA."
  default     = 2
  validation {
    condition     = var.nat_gateway_count == 1 || var.nat_gateway_count == 2
    error_message = "nat_gateway_count must be 1 or 2."
  }
}

variable "kubernetes_version" {
  type        = string
  description = "Kubernetes version for EKS (e.g., 1.34)."
  default     = "1.34"
}

variable "cluster_name_suffix" {
  type        = string
  description = "Optional suffix for cluster name (in addition to project and env)."
  default     = ""
}

variable "cluster_public_access_cidrs" {
  type        = list(string)
  description = "CIDR ranges allowed to access the public EKS API endpoint."
  # For real production, restrict this. 0.0.0.0/0 is easy but not secure.
  default = ["0.0.0.0/0"]
}

variable "enable_irsa" {
  type        = bool
  description = "Enable IAM Roles for Service Accounts (IRSA) on the cluster."
  default     = true
}

variable "enable_cluster_creator_admin_permissions" {
  type        = bool
  description = "Whether to add the current caller identity as an EKS admin via cluster access entry."
  default     = true
}

variable "node_instance_types" {
  type        = list(string)
  description = "Instance types for EKS managed node group."
  default     = ["t3.medium"]
}

variable "node_desired_capacity" {
  type        = number
  description = "Desired node count for the default EKS managed node group."
  default     = 2
}

variable "node_min_size" {
  type        = number
  description = "Minimum node count for the default EKS managed node group."
  default     = 2
}

variable "node_max_size" {
  type        = number
  description = "Maximum node count for the default EKS managed node group."
  default     = 4
}

variable "node_capacity_type" {
  type        = string
  description = "Capacity type for node group: ON_DEMAND or SPOT."
  default     = "ON_DEMAND"
  validation {
    condition     = contains(["ON_DEMAND", "SPOT"], var.node_capacity_type)
    error_message = "node_capacity_type must be ON_DEMAND or SPOT."
  }
}

variable "node_ssh_key_name" {
  type        = string
  description = "Optional EC2 key pair name to enable SSH access to worker nodes. Leave empty to disable."
  default     = ""
}

variable "enable_ssm_on_nodes" {
  type        = bool
  description = "Attach SSM Managed Core policy to node IAM role so you can use Session Manager instead of SSH."
  default     = true
}

variable "eks_log_retention_days" {
  type        = number
  description = "CloudWatch log retention in days for EKS control plane logs."
  default     = 30
}

variable "enable_control_plane_logging" {
  type        = bool
  description = "Enable EKS control plane logs (api, audit, authenticator, controllerManager, scheduler)."
  default     = true
}

variable "additional_tags" {
  type        = map(string)
  description = "Additional tags to apply to all supported AWS resources."
  default     = {}
}
