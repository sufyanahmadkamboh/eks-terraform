terraform {
  backend "s3" {}
}

provider "aws" {
  region  = "us-east-2"
  profile = ""

  default_tags {
    tags = {
      Environment = "prod"
      Project     = "eks-demo"
      Terraform   = "true"
    }
  }
}

module "stack" {
  source = "../.."

  env_name          = "prod"
  project_name      = "eks-demo"
  aws_region        = "us-east-2"
  vpc_cidr          = "10.2.0.0/16"
  nat_gateway_count = 2

  kubernetes_version  = "1.30"
  node_instance_types = ["m6i.large"]

  node_desired_capacity = 4
  node_min_size         = 3
  node_max_size         = 8

  node_capacity_type          = "ON_DEMAND"
  cluster_public_access_cidrs = ["198.51.100.0/24"] # Prod: strictly limited

  enable_irsa                  = true
  enable_ssm_on_nodes          = true
  enable_control_plane_logging = true

  additional_tags = {
    Owner      = "platform-team"
    Criticality = "high"
  }
}
