terraform {
  required_version = ">= 1.6.0, < 2.0.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      # Use a stable 6.x provider family (upgradeable later)
      version = "~> 6.0"
    }
  }
}
