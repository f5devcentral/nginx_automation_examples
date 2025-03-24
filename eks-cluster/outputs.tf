output "cluster_id" {
  description = "EKS cluster ID"
  value       = aws_eks_cluster.eks-tf.cluster_id
}

output "cluster_endpoint" {
  description = "Endpoint for EKS control plane"
  value       = aws_eks_cluster.eks-tf.endpoint
}

output "ebs_csi_sa_name" {
  value = kubernetes_service_account.ebs_csi_controller.metadata[0].name
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