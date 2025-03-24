# eks-cluster/ekscluster.tf
# Create EKS cluster and node groups
resource "aws_eks_cluster" "eks-tf" {

 name = local.cluster_name
 role_arn = aws_iam_role.eks-iam-role.arn
 version = "1.32"

 vpc_config {
  security_group_ids      = flatten([aws_security_group.eks_cluster.id, aws_security_group.eks_nodes.id])
  endpoint_private_access = true
  endpoint_public_access  = true
  #public_access_cidrs = [var.admin_src_addr]
  public_access_cidrs = ["0.0.0.0/0"]
  subnet_ids = concat([for e in aws_subnet.eks-external: e.id], [for i in aws_subnet.eks-internal: i.id])
  }

 depends_on = [
  aws_iam_role.eks-iam-role,
 ]
}

resource "aws_eks_node_group" "private-node-group-1-tf" {
  cluster_name  = aws_eks_cluster.eks-tf.name
  node_group_name = format("%s-private-ng-1-%s", local.project_prefix, local.build_suffix)
  node_role_arn  = aws_iam_role.workernodes.arn
  subnet_ids =  [for i in aws_subnet.eks-internal: i.id]
  instance_types = ["t3.medium"]
 
  scaling_config {
   desired_size = 1
   max_size   = 2
   min_size   = 1
  }

  tags = {
    Name = format("%s-private-ng-1-%s", local.project_prefix, local.build_suffix)
  }
 
  depends_on = [
   aws_iam_role_policy_attachment.AmazonEKSWorkerNodePolicy,
   aws_iam_role_policy_attachment.AmazonEKS_CNI_Policy,
   aws_iam_role_policy_attachment.AmazonEC2ContainerRegistryReadOnly,
  ]
 }


resource "aws_eks_node_group" "private-node-group-2-tf" {
  cluster_name  = aws_eks_cluster.eks-tf.name
  node_group_name = format("%s-private-ng-2-%s", local.project_prefix, local.build_suffix)
  node_role_arn  = aws_iam_role.workernodes.arn
  subnet_ids =  [for i in aws_subnet.eks-internal: i.id]
  ami_type       = "AL2_x86_64"
  instance_types = ["t3.medium"]
 
  scaling_config {
   desired_size = 1
   max_size   = 2
   min_size   = 1
  }

  tags = {
    Name = format("%s-private-ng-2-%s", local.project_prefix, local.build_suffix)
  }
 
  depends_on = [
   aws_iam_role_policy_attachment.AmazonEKSWorkerNodePolicy,
   aws_iam_role_policy_attachment.AmazonEKS_CNI_Policy,
   aws_iam_role_policy_attachment.AmazonEC2ContainerRegistryReadOnly,
  ]
 }

# Create EKS Addons
resource "aws_eks_addon" "cluster-addons" {
  for_each       = { for addon in var.eks_addons : addon.name => addon }
  cluster_name   = aws_eks_cluster.eks-tf.id
  addon_name     = each.value.name
  resolve_conflicts = "OVERWRITE"
  
  # Add service account role ARN for EBS CSI driver
  service_account_role_arn = each.value.name == "aws-ebs-csi-driver" ? aws_iam_role.ebs_csi_driver.arn : null

  depends_on = [
    aws_eks_node_group.private-node-group-1-tf,
    aws_eks_node_group.private-node-group-2-tf,
    aws_iam_role.ebs_csi_driver
  ]
}

output "kubeconfig" {
  value = <<EOT
apiVersion: v1
clusters:
- cluster:
    server: ${aws_eks_cluster.eks-tf.endpoint}
    certificate-authority-data: ${aws_eks_cluster.eks-tf.certificate_authority[0].data}
  name: ${aws_eks_cluster.eks-tf.arn}  # Use ARN as context name
contexts:
- context:
    cluster: ${aws_eks_cluster.eks-tf.arn}
    user: ${aws_eks_cluster.eks-tf.arn}
  name: ${aws_eks_cluster.eks-tf.arn}  # Dynamic context name
current-context: ${aws_eks_cluster.eks-tf.arn}
kind: Config
users:
- name: ${aws_eks_cluster.eks-tf.arn}
  user:
    exec:
      apiVersion: client.authentication.k8s.io/v1beta1
      command: aws
      args:
        - "eks"
        - "get-token"
        - "--cluster-name"
        - ${aws_eks_cluster.eks-tf.name}
        - "--region"
        - ${local.aws_region}
EOT
  sensitive = true
}
