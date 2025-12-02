terraform {
  backend "s3" {}
}

provider "aws" {
  region  = "us-east-1"
  profile = ""

  default_tags {
    tags = {
      Environment = "stage"
      Project     = "eks-demo"
      Terraform   = "true"
    }
  }
}

module "stack" {
  source = "../.."

  env_name          = "stage"
  project_name      = "eks-demo"
  aws_region        = "us-east-1"
  vpc_cidr          = "10.1.0.0/16"
  nat_gateway_count = 2

  kubernetes_version  = "1.34"
  node_instance_types = ["t3.large"]

  node_desired_capacity = 3
  node_min_size         = 2
  node_max_size         = 6

  node_capacity_type           = "ON_DEMAND"
  cluster_public_access_cidrs  = ["203.0.113.0/24"] # Example: office CIDR

  enable_irsa                  = true
  enable_ssm_on_nodes          = true
  enable_control_plane_logging = true

  additional_tags = {
    Owner = "platform-team"
  }
}
