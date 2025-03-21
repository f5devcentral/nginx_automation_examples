# IAM Role for EKS Cluster
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

# OIDC Provider Configuration
data "aws_eks_cluster" "cluster" {
  name = aws_eks_cluster.eks-tf.name
}

locals {
  oidc_issuer_url = replace(data.aws_eks_cluster.cluster.identity[0].oidc[0].issuer, "https://", "")
}

# Get TLS certificate for thumbprint
data "tls_certificate" "eks_oidc" {
  url = data.aws_eks_cluster.cluster.identity[0].oidc[0].issuer
}

# Check if OIDC provider already exists
data "external" "oidc_provider_check" {
  program = ["bash", "-c", <<EOT
    # Get OIDC issuer URL
    issuer_url="${data.aws_eks_cluster.cluster.identity[0].oidc[0].issuer}"
    
    # Check provider existence
    if aws iam list-open-id-connect-providers --query "OpenIDConnectProviderList[?ends_with(Arn, '/$${issuer_url#https://}')].Arn" --output text | grep -q .; then
      echo "{\"exists\":\"true\"}"
    else
      echo "{\"exists\":\"false\"}"
    fi
  EOT
  ]
}

# Create OIDC provider only if it doesn't exist
resource "aws_iam_openid_connect_provider" "oidc" {
  count = data.external.oidc_provider_check.result.exists == "true" ? 0 : 1

  url             = data.aws_eks_cluster.cluster.identity[0].oidc[0].issuer
  client_id_list  = ["sts.amazonaws.com"]
  thumbprint_list = [data.tls_certificate.eks_oidc.certificates[0].sha1_fingerprint]

  depends_on = [aws_eks_cluster.eks-tf]
}

# Get ARN of existing or new provider
data "aws_iam_openid_connect_provider" "existing" {
  count = data.external.oidc_provider_check.result.exists == "true" ? 1 : 0
  url   = data.aws_eks_cluster.cluster.identity[0].oidc[0].issuer
}

locals {
  oidc_provider_arn = try(
    data.aws_iam_openid_connect_provider.existing[0].arn,
    aws_iam_openid_connect_provider.oidc[0].arn
  )
}

# Worker Node IAM Role
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
      },
      {
        Effect = "Allow",
        Principal = {
          Federated = local.oidc_provider_arn
        },
        Action = "sts:AssumeRoleWithWebIdentity",
        Condition = {
          StringEquals = {
            "${local.oidc_issuer_url}:sub" = "system:serviceaccount:kube-system:ebs-csi-controller-sa"
          }
        }
      }
    ]
  })
}

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

# EBS CSI Driver Policy
resource "aws_iam_policy" "workernodes_ebs_policy" {
  name = format("%s-ebs_csi_driver-%s", local.project_prefix, local.build_suffix)

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "ec2:DetachVolume",
          "ec2:AttachVolume",
          "ec2:ModifyVolume",
          "ec2:DescribeInstances",
          "ec2:DescribeAvailabilityZones",
          "ec2:DescribeTags",
          "ec2:DescribeVolumes",
          "ec2:CreateSnapshot",
          "ec2:DescribeVolumesModifications",
          "ec2:DescribeSnapshots"
        ],
        Resource = "*"
      },
      {
        Effect = "Allow",
        Action = "ec2:CreateTags",
        Resource = [
          "arn:aws:ec2:*:*:volume/*",
          "arn:aws:ec2:*:*:snapshot/*"
        ],
        Condition = {
          StringEquals = {
            "ec2:CreateAction" = [
              "CreateVolume",
              "CreateSnapshot"
            ]
          }
        }
      },
      {
        Effect = "Allow",
        Action = "ec2:DeleteTags",
        Resource = [
          "arn:aws:ec2:*:*:volume/*",
          "arn:aws:ec2:*:*:snapshot/*"
        ]
      },
      {
        Effect = "Allow",
        Action = "ec2:CreateVolume",
        Resource = "*",
        Condition = {
          StringLike = {
            "aws:RequestTag/ebs.csi.aws.com/cluster" = "true"
          }
        }
      },
      {
        Effect = "Allow",
        Action = "ec2:CreateVolume",
        Resource = "*",
        Condition = {
          StringLike = {
            "aws:RequestTag/CSIVolumeName" = "*"
          }
        }
      },
      {
        Effect = "Allow",
        Action = "ec2:DeleteVolume",
        Resource = "*",
        Condition = {
          StringLike = {
            "ec2:ResourceTag/ebs.csi.aws.com/cluster" = "true"
          }
        }
      },
      {
        Effect = "Allow",
        Action = "ec2:DeleteVolume",
        Resource = "*",
        Condition = {
          StringLike = {
            "ec2:ResourceTag/CSIVolumeName" = "*"
          }
        }
      },
      {
        Effect = "Allow",
        Action = "ec2:DeleteVolume",
        Resource = "*",
        Condition = {
          StringLike = {
            "ec2:ResourceTag/kubernetes.io/created-for/pvc/name" = "*"
          }
        }
      },
      {
        Effect = "Allow",
        Action = "ec2:DeleteSnapshot",
        Resource = "*",
        Condition = {
          StringLike = {
            "ec2:ResourceTag/CSIVolumeSnapshotName" = "*"
          }
        }
      },
      {
        Effect = "Allow",
        Action = "ec2:DeleteSnapshot",
        Resource = "*",
        Condition = {
          StringLike = {
            "ec2:ResourceTag/ebs.csi.aws.com/cluster" = "true"
          }
        }
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "workernodes-AmazonEBSCSIDriver" {
  policy_arn = aws_iam_policy.workernodes_ebs_policy.arn
  role       = aws_iam_role.workernodes.name
}

# IAM Instance Profile
resource "aws_iam_instance_profile" "workernodes" {
  name = format("%s-eks-node-instance-profile-%s", local.project_prefix, local.build_suffix)
  role = aws_iam_role.workernodes.name
}

# EBS CSI Driver Role
resource "aws_iam_role" "ebs_csi_driver" {
  name = format("%s-ebs-csi-driver-role-%s", local.project_prefix, local.build_suffix)

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Principal = {
          Federated = local.oidc_provider_arn
        },
        Action = "sts:AssumeRoleWithWebIdentity",
        Condition = {
          StringEquals = {
            "${local.oidc_issuer_url}:sub" = "system:serviceaccount:kube-system:ebs-csi-controller-sa"
          }
        }
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "ebs_csi_driver" {
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEBSCSIDriverPolicy"
  role       = aws_iam_role.ebs_csi_driver.name
}