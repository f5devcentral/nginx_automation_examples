# Data source to get the latest Amazon Linux 2 AMI
data "aws_ami" "amazon_linux_2" {
  most_recent = true

  owners = ["137112412989"] # Amazon's official account ID for Amazon Linux

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }
}

# Create EKS cluster
resource "aws_eks_cluster" "eks-tf" {
  name     = local.cluster_name
  role_arn = aws_iam_role.eks-iam-role.arn
  version  = "1.32"

  vpc_config {
    security_group_ids      = flatten([aws_security_group.eks_cluster.id, aws_security_group.eks_nodes.id])
    endpoint_private_access = true
    endpoint_public_access  = true
    public_access_cidrs     = ["0.0.0.0/0"]
    subnet_ids = concat([for e in aws_subnet.eks-external: e.id], [for i in aws_subnet.eks-internal: i.id])
  }

  depends_on = [
    aws_iam_role.eks-iam-role,
  ]
}

# Create EKS Node Group 1 (using external subnets)
resource "aws_eks_node_group" "private-node-group-1-tf" {
  cluster_name   = aws_eks_cluster.eks-tf.name
  node_group_name = format("%s-private-ng-1-%s", local.project_prefix, local.build_suffix)
  node_role_arn  = aws_iam_role.workernodes.arn
  subnet_ids     = [for e in aws_subnet.eks-external: e.id]
  instance_types = ["t3.medium"]
  ami_type      = "AL2_x86_64" # Specify the AMI type

  scaling_config {
    desired_size = 2
    max_size     = 3
    min_size     = 1
  }

  tags = {
    Name = format("%s-private-ng-1-%s", local.project_prefix, local.build_suffix)
  }

  # Use the latest Amazon Linux 2 AMI for the node group
  launch_template {
    id      = aws_launch_template.docker_install.id
    version = "$Latest"
  }

  depends_on = [
    aws_iam_role_policy_attachment.AmazonEKSWorkerNodePolicy,
    aws_iam_role_policy_attachment.AmazonEKS_CNI_Policy,
    aws_iam_role_policy_attachment.AmazonEC2ContainerRegistryReadOnly,
  ]
}

# Create EKS Node Group 2 (using external subnets)
resource "aws_eks_node_group" "private-node-group-2-tf" {
  cluster_name    = aws_eks_cluster.eks-tf.name
  node_group_name = format("%s-private-ng-2-%s", local.project_prefix, local.build_suffix)
  node_role_arn   = aws_iam_role.workernodes.arn
  subnet_ids      = [for e in aws_subnet.eks-external: e.id]
  ami_type        = "AL2_x86_64"
  instance_types  = ["t3.medium"]

  scaling_config {
    desired_size = 2
    max_size     = 3
    min_size     = 1
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

  depends_on = [
    aws_eks_node_group.private-node-group-1-tf,
    aws_eks_node_group.private-node-group-2-tf,
  ]
}

