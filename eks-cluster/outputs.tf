output "cluster_id" {
  description = "EKS cluster ID"
  value       = aws_eks_cluster.eks-tf.cluster_id
}

output "cluster_endpoint" {
  description = "Endpoint for EKS control plane"
  value       = aws_eks_cluster.eks-tf.endpoint
}

output "cluster_name" {
  description = "EKS cluster name"
  value       = aws_eks_cluster.eks-tf.name
}

output "cluster_ca_certificate" {
  description = "EKS cluster CA certificate"
  value       = aws_eks_cluster.eks-tf.certificate_authority[0].data
}


output "node_security_group_id" {
  description = "EKS NG SG ID"
  value = aws_security_group.eks_nodes.id
}

