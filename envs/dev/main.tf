terraform {
  backend "s3" {
    bucket         = "dev-eks-bucket-747034604262"
    key            = "eks/dev/terraform.tfstate"
    region         = "us-east-2"
    dynamodb_table = "dev-terraform-locks"
    encrypt        = true
  }
}

provider "aws" {
  region  = "us-east-2"
  profile = "" # or a dedicated dev profile if you prefer

  default_tags {
    tags = {
      Environment = "dev"
      Project     = "eks-demo"
      Terraform   = "true"
    }
  }
}

module "stack" {
  source = "../.."

  env_name            = "dev"
  project_name        = "eks-demo"
  aws_region          = "us-east-2"
  aws_profile         = "" # override if using a named profile
  vpc_cidr            = "10.0.0.0/16"
  nat_gateway_count   = 1 # cost-saving dev

  kubernetes_version  = "1.30"
  node_instance_types = ["t3.small"]

  node_desired_capacity = 2
  node_min_size         = 1
  node_max_size         = 3

  node_capacity_type = "ON_DEMAND" # dev can use spot to reduce cost

  cluster_public_access_cidrs = ["0.0.0.0/0"]

  enable_irsa            = true
  enable_ssm_on_nodes    = true
  enable_control_plane_logging = true

  additional_tags = {
    Owner = "platform-team"
  }
}
