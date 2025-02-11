data "tfe_outputs" "infra" {
  organization = var.tf_cloud_organization
  workspace = "infra"
}
data "tfe_outputs" "eks" {
  organization = var.tf_cloud_organization
  workspace = "eks"
}
data "aws_eks_cluster_auth" "auth" {
  name = data.tfe_outputs.eks.values.cluster_name
}
data "kubernetes_service_v1" "nginx-service" {
  metadata {
    name = try(format("%s-%s-controller", helm_release.nginx-plus-ingress.0.name, helm_release.nginx-plus-ingress.0.chart))
    namespace = try(helm_release.nginx-plus-ingress[0].namespace)
  }
}
