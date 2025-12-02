terraform {
  backend "s3" {
    bucket         = "prod-eks-bucket-747034604262"
    key            = "eks/prod/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "prod-terraform-locks"
    encrypt        = true
  }
}

provider "aws" {
  region  = "us-east-1"
  profile = ""

  default_tags {
    tags = {
      Environment = "prod"
      Project     = "eks-max-fun"
      Terraform   = "true"
    }
  }
}

module "stack" {
  source = "../.."

  env_name          = "prod"
  project_name      = "eks-max-fun"
  aws_region        = "us-east-1"
  vpc_cidr          = "11.0.0.0/16"
  nat_gateway_count = 2

  kubernetes_version  = "1.34"
  node_instance_types = ["t3.large"]

  node_desired_capacity = 2
  node_min_size         = 2
  node_max_size         = 4

  node_capacity_type          = "ON_DEMAND"
  cluster_public_access_cidrs = ["0.0.0.0/0"] # Prod: strictly limited

  enable_irsa                  = true
  enable_ssm_on_nodes          = true
  enable_control_plane_logging = true

  additional_tags = {
    Owner      = "platform-team"
    Criticality = "high"
  }
}
