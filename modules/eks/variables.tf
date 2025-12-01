variable "project_name" {
  type        = string
  description = "Project name for tagging."
}

variable "env_name" {
  type        = string
  description = "Environment name for tagging."
}

variable "cluster_name" {
  type        = string
  description = "Name of the EKS cluster."
}

variable "vpc_id" {
  type        = string
  description = "VPC ID where EKS is deployed."
}

variable "private_subnet_ids" {
  type        = list(string)
  description = "Private subnets for worker nodes."
}

variable "public_subnet_ids" {
  type        = list(string)
  description = "Public subnets (not used for nodes here, but may be used by addons / load balancers)."
}

variable "kubernetes_version" {
  type        = string
  description = "Kubernetes version."
}

variable "endpoint_private_access" {
  type        = bool
  description = "Enable private endpoint access for EKS API."
}

variable "endpoint_public_access" {
  type        = bool
  description = "Enable public endpoint access for EKS API."
}

variable "public_access_cidrs" {
  type        = list(string)
  description = "CIDR ranges allowed for public endpoint."
}

variable "enable_irsa" {
  type        = bool
  description = "Enable IRSA for this EKS cluster."
}

variable "enable_cluster_creator_admin_permissions" {
  type        = bool
  description = "Add Terraform caller IAM identity as EKS admin via cluster access entry."
}

variable "node_instance_types" {
  type        = list(string)
  description = "Instance types for managed node group."
}

variable "node_desired_capacity" {
  type        = number
  description = "Desired node count."
}

variable "node_min_size" {
  type        = number
  description = "Min node count."
}

variable "node_max_size" {
  type        = number
  description = "Max node count."
}

variable "node_capacity_type" {
  type        = string
  description = "ON_DEMAND or SPOT."
}

variable "node_ssh_key_name" {
  type        = string
  description = "EC2 key pair name for SSH (optional)."
  default     = ""
}

variable "enable_ssm_on_nodes" {
  type        = bool
  description = "Attach SSM Managed Instance Core policy to node IAM role."
}

variable "enabled_log_types" {
  type        = list(string)
  description = "Control plane log types to enable."
  default     = []
}

variable "cloudwatch_log_group_retention_in_days" {
  type        = number
  description = "Days to retain control plane logs in CloudWatch."
  default     = 30
}

variable "tags" {
  type        = map(string)
  description = "Tags to apply to EKS-related resources."
  default     = {}
}
