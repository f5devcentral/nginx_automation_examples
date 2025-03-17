data "aws_eks_cluster_auth" "auth" {
  name = data.tfe_outputs.eks.values.cluster_name
}
data "kubernetes_service_v1" "nginx-service" {
  metadata {
   name = try(format("%s-%s-controller", helm_release.nginx-plus-ingress.name, helm_release.nginx-plus-ingress.chart))
   namespace = try(helm_release.nginx-plus-ingress.namespace)
  }
}
