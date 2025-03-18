data "tfe_outputs" "infra" {
  organization = var.tf_cloud_organization
  workspace = "infra"
}
data "tfe_outputs" "eks" {
  organization = var.tf_cloud_organization
  workspace = "eks"
}
data "tfe_outputs" "nap" {
  organization = var.tf_cloud_organization
  workspace = "nap"
}
data "kubernetes_service_v1" "nginx-service" {
  metadata {
    name      = try(format("%s-%s-controller", helm_release.nginx-plus-ingress.name, helm_release.nginx-plus-ingress.chart))
    namespace = try(helm_release.nginx-plus-ingress.namespace)
  }
}
data "aws_eks_cluster_auth" "auth" {
  name = data.tfe_outputs.eks.values.cluster_name
}
