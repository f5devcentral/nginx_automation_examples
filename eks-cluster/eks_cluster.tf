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

# Create Launch Template for EKS Node Groups
resource "aws_launch_template" "docker_install" {
  name_prefix   = "${local.project_prefix}-docker-install-"
  image_id      = data.aws_ami.amazon_linux_2.id  # Use a dynamic AMI ID

  instance_type = "t3.medium"

  user_data = base64encode(<<-EOF
    #!/bin/bash
    yum update -y
    amazon-linux-extras install docker -y
    systemctl start docker
    systemctl enable docker
  EOF
  )

  lifecycle {
    create_before_destroy = true
  }

  # Optional: Add tags to the launch template
  tag_specifications {
    resource_type = "instance"
    tags = {
      Name = "${local.project_prefix}-docker-instance"
    }
  }
}

# Create EKS Node Group 1 (using external subnets)
resource "aws_eks_node_group" "private-node-group-1-tf" {
  cluster_name   = aws_eks_cluster.eks-tf.name
  node_group_name = format("%s-private-ng-1-%s", local.project_prefix, local.build_suffix)
  node_role_arn  = aws_iam_role.workernodes.arn
  subnet_ids     = [for e in aws_subnet.eks-external: e.id]

  scaling_config {
    desired_size = 1
    max_size     = 2
    min_size     = 1
  }

  launch_template {
    id      = aws_launch_template.docker_install.id
    version = "$Latest"  # Use the latest version of the launch template
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

# Create EKS Node Group 2 (using external subnets)
resource "aws_eks_node_group" "private-node-group-2-tf" {
  cluster_name    = aws_eks_cluster.eks-tf.name
  node_group_name = format("%s-private-ng-2-%s", local.project_prefix, local.build_suffix)
  node_role_arn   = aws_iam_role.workernodes.arn
  subnet_ids      = [for e in aws_subnet.eks-external: e.id]

  scaling_config {
    desired_size = 1
    max_size     = 2
    min_size     = 1
  }

  launch_template {
    id      = aws_launch_template.docker_install.id
    version = "$Latest"  # Use the latest version of the launch template
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

# Data resource for dynamic AMI ID
data "aws_ami" "amazon_linux_2" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }
}

