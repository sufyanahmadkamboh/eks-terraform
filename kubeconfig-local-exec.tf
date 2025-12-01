# Optional: convenience local-exec to update kubeconfig after cluster creation.
# Comment out or remove if you don't want Terraform to run local commands.

resource "null_resource" "update_kubeconfig" {
  triggers = {
    cluster_name = module.eks.cluster_name
    region       = var.aws_region
  }

  provisioner "local-exec" {
    command = "aws eks update-kubeconfig --name ${self.triggers.cluster_name} --region ${self.triggers.region}"
  }
}
