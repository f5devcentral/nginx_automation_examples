# Fetch infra state from S3
data "terraform_remote_state" "infra" {
  backend = "s3"
  config = {
    bucket = "akash-terraform-state-bucket"
    key    = "infra/terraform.tfstate"
    region = "us-east-1"
  }
}

# Fetch eks state from S3
data "terraform_remote_state" "eks" {
  backend = "s3"
  config = {
    bucket = "akash-terraform-state-bucket"
    key    = "eks-cluster/terraform.tfstate"
    region = "us-east-1"
  }
}

# Fetch EKS cluster authentication data
data "aws_eks_cluster_auth" "auth" {
  name = data.terraform_remote_state.eks.outputs.cluster_name
}

# Fetch Kubernetes service for NGINX Plus Ingress
data "kubernetes_service_v1" "nginx-service" {
  metadata {
    name      = try(format("%s-%s-controller", helm_release.nginx-plus-ingress.name, helm_release.nginx-plus-ingress.chart), "nginx-plus-ingress-controller")
    namespace = try(helm_release.nginx-plus-ingress.namespace, "nginx-ingress")
  }
}