output "cluster_id" {
  description = "EKS cluster ID"
  value       = aws_eks_cluster.eks-tf.cluster_id
}

output "cluster_endpoint" {
  description = "Endpoint for EKS control plane"
  value       = aws_eks_cluster.eks-tf.endpoint
}


output "oidc_provider_details" {
  value = {
    url             = aws_eks_cluster.eks-tf.identity[0].oidc[0].issuer
    issuer_url      = local.oidc_issuer_url
    provider_arn    = aws_iam_openid_connect_provider.oidc.arn
    account_id      = data.aws_caller_identity.current.account_id
  }
}

output "cluster_name" {
  description = "Kubernetes Cluster Name"
  value       = nonsensitive(aws_eks_cluster.eks-tf.name)
}

output "kubeconfig-certificate-authority-data" {
  value = aws_eks_cluster.eks-tf.certificate_authority[0].data
  sensitive = true
}

output "node_security_group_id" {
  description = "EKS NG SG ID"
  value = aws_security_group.eks_nodes.id
}

output "aws_region" {
  description = "The AWS region where the EKS cluster is deployed"
  value       = var.aws_region
}

output "ebs_csi_driver_role_arn" {
  value = aws_iam_role.ebs_csi_driver.arn
}