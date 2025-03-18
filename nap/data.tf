data "terraform_remote_state" "infra" {
  backend = "s3"
  config = {
    bucket = "akash-terraform-state-bucket"  # Your S3 bucket name
    key    = "infra/terraform.tfstate"       # Path to infra's state file
    region = "us-east-1"                     # AWS region
  }
}
# Use the role ARN from infra
locals {
  github_actions_role_arn = data.terraform_remote_state.infra.outputs.github_actions_role_arn
}

# Read eks state from S3
data "terraform_remote_state" "eks" {
  backend = "s3"
  config = {
    bucket = "akash-terraform-state-bucket"  # Your S3 bucket name
    key    = "eks-cluster/terraform.tfstate" # Path to EKS state file
    region = "us-east-1"                     # AWS region
  }
}

data "aws_eks_cluster_auth" "auth" {
  name = data.terraform_remote_state.eks.outputs.cluster_name
}

data "kubernetes_service_v1" "nginx-service" {
  metadata {
    name      = try(format("%s-%s-controller", helm_release.nginx-plus-ingress.name, helm_release.nginx-plus-ingress.chart))
    namespace = try(helm_release.nginx-plus-ingress.namespace)
  }
}
