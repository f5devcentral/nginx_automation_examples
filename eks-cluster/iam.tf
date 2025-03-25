resource "aws_iam_role" "eks-iam-role" {
  name = format("%s-eks-iam-role-%s", local.project_prefix, local.build_suffix)
  path = "/"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "eks.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "AmazonEKSClusterPolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  role       = aws_iam_role.eks-iam-role.name
}

resource "aws_iam_role_policy_attachment" "AmazonEC2ContainerRegistryReadOnly-EKS" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  role       = aws_iam_role.eks-iam-role.name
}

# OIDC Provider Configuration (Unchanged)
data "aws_eks_cluster" "cluster" {
  name = aws_eks_cluster.eks-tf.name
}

locals {
  oidc_issuer_url = replace(data.aws_eks_cluster.cluster.identity[0].oidc[0].issuer, "https://", "")
}

data "tls_certificate" "eks_oidc" {
  url = data.aws_eks_cluster.cluster.identity[0].oidc[0].issuer
}

resource "aws_iam_openid_connect_provider" "oidc" {
  url             = data.aws_eks_cluster.cluster.identity[0].oidc[0].issuer
  client_id_list  = ["sts.amazonaws.com"]
  thumbprint_list = [data.tls_certificate.eks_oidc.certificates[0].sha1_fingerprint]
}

locals {
  oidc_provider_arn = aws_iam_openid_connect_provider.oidc.arn
}

# Worker Node IAM Role (Fixed)
resource "aws_iam_role" "workernodes" {
  name = format("%s-eks-node-iam-role-%s", local.project_prefix, local.build_suffix)

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Principal = {
          Service = "ec2.amazonaws.com"
        },
        Action = "sts:AssumeRole"
      }
    ]
  })
}

# Standard Node Policies (Unchanged)
resource "aws_iam_role_policy_attachment" "AmazonEKSWorkerNodePolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
  role       = aws_iam_role.workernodes.name
}

resource "aws_iam_role_policy_attachment" "AmazonEKS_CNI_Policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
  role       = aws_iam_role.workernodes.name
}

resource "aws_iam_role_policy_attachment" "EC2InstanceProfileForImageBuilderECRContainerBuilds" {
  policy_arn = "arn:aws:iam::aws:policy/EC2InstanceProfileForImageBuilderECRContainerBuilds"
  role       = aws_iam_role.workernodes.name
}

resource "aws_iam_role_policy_attachment" "AmazonEC2ContainerRegistryReadOnly" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  role       = aws_iam_role.workernodes.name
}

# Removed the custom EBS policy and its attachment - using managed policy instead

# IAM Instance Profile (Unchanged)
resource "aws_iam_instance_profile" "workernodes" {
  name = format("%s-eks-node-instance-profile-%s", local.project_prefix, local.build_suffix)
  role = aws_iam_role.workernodes.name
}

resource "aws_iam_role" "ebs_csi_driver" {
  name = format("%s-ebs-csi-driver-role-%s", local.project_prefix, local.build_suffix)

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Principal = {
          Federated = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:oidc-provider/${replace(
            aws_eks_cluster.eks-tf.identity[0].oidc[0].issuer, 
            "https://", 
            ""
          )}"
        },
        Action = "sts:AssumeRoleWithWebIdentity",
        Condition = {
          StringEquals = {
            "${replace(
              aws_eks_cluster.eks-tf.identity[0].oidc[0].issuer, 
              "https://", 
              ""
            )}:sub" = "system:serviceaccount:kube-system:ebs-csi-controller-sa",
            "${replace(
              aws_eks_cluster.eks-tf.identity[0].oidc[0].issuer, 
              "https://", 
              ""
            )}:aud" = "sts.amazonaws.com"
          }
        }
      }
    ]
  })
}

data "aws_caller_identity" "current" {}

# Use the official AWS managed policy instead of custom one
resource "aws_iam_role_policy_attachment" "ebs_csi_driver" {
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEBSCSIDriverPolicy"
  role       = aws_iam_role.ebs_csi_driver.name
}
