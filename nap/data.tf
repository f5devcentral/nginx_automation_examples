data "terraform_remote_state" "infra" {
  backend = "s3"
  config = {
    bucket = var.AWS_S3_BUCKET_NAME       # Your S3 bucket name
    key    = "infra/terraform.tfstate"       # Path to infra's state file
    region = var.AWS_REGION                    # AWS region
  }
}

# Read eks state from S3
data "terraform_remote_state" "eks" {
  backend = "s3"
  config = {
    bucket =  var.AWS_S3_BUCKET_NAME        # Your S3 bucket name
    key    = "eks-cluster/terraform.tfstate" # Path to EKS state file
    region = var.AWS_REGION                    # AWS region
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
