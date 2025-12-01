provider "aws" {
  region  = var.aws_region
  profile = var.aws_profile

  # Tag all supported resources created through this provider
  default_tags {
    tags = merge(
      {
        Environment = var.env_name
        Project     = var.project_name
        Terraform   = "true"
      },
      var.additional_tags
    )
  }
}
