# Create IAM role for the EKS cluster
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

# Get EKS cluster details
data "aws_eks_cluster" "cluster" {
  name = aws_eks_cluster.eks-tf.name
}

# Extract the OIDC issuer URL
locals {
  oidc_issuer_url = replace(data.aws_eks_cluster.cluster.identity[0].oidc[0].issuer, "https://", "")
}

# Create OIDC provider dynamically
resource "aws_iam_openid_connect_provider" "oidc_provider" {
  url             = data.aws_eks_cluster.cluster.identity[0].oidc[0].issuer
  client_id_list  = ["sts.amazonaws.com"]
  thumbprint_list = ["9e99a48a9960b14926bb7f3b02e22da2b0ec444e"]

  depends_on = [data.aws_eks_cluster.cluster]
}

# Create IAM role for the worker nodes
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
          Federated = aws_iam_openid_connect_provider.oidc_provider.arn
        },
        Action = "sts:AssumeRoleWithWebIdentity",
        Condition = {
          "StringEquals" = {
            "${replace(data.aws_eks_cluster.cluster.identity[0].oidc[0].issuer, "https://", "")}:sub" = "system:serviceaccount:kube-system:ebs-csi-controller-sa"
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

resource "aws_iam_policy" "workernodes_ebs_policy" {
  name = format("%s-ebs_csi_driver-%s", local.project_prefix, local.build_suffix)

  policy = jsonencode(
  {
    "Version": "2012-10-17",
    "Statement": [
      {
        "Effect": "Allow",
        "Action": [
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
        "Resource": "*"
      },
      {
        "Effect": "Allow",
        "Action": "ec2:CreateTags",
        "Resource": [
          "arn:aws:ec2:*:*:volume/*",
          "arn:aws:ec2:*:*:snapshot/*"
        ],
        "Condition": {
          "StringEquals": {
            "ec2:CreateAction": [
              "CreateVolume",
              "CreateSnapshot"
            ]
          }
        }
      },
      {
        "Effect": "Allow",
        "Action": "ec2:DeleteTags",
        "Resource": [
          "arn:aws:ec2:*:*:volume/*",
          "arn:aws:ec2:*:*:snapshot/*"
        ]
      },
      {
        "Effect": "Allow",
        "Action": "ec2:CreateVolume",
        "Resource": "*",
        "Condition": {
          "StringLike": {
            "aws:RequestTag/ebs.csi.aws.com/cluster": "true"
          }
        }
      },
      {
        "Effect": "Allow",
        "Action": "ec2:CreateVolume",
        "Resource": "*",
        "Condition": {
          "StringLike": {
            "aws:RequestTag/CSIVolumeName": "*"
          }
        }
      },
      {
        "Effect": "Allow",
        "Action": "ec2:DeleteVolume",
        "Resource": "*",
        "Condition": {
          "StringLike": {
            "ec2:ResourceTag/ebs.csi.aws.com/cluster": "true"
          }
        }
      },
      {
        "Effect": "Allow",
        "Action": "ec2:DeleteVolume",
        "Resource": "*",
        "Condition": {
          "StringLike": {
            "ec2:ResourceTag/CSIVolumeName": "*"
          }
        }
      },
      {
        "Effect": "Allow",
        "Action": "ec2:DeleteVolume",
        "Resource": "*",
        "Condition": {
          "StringLike": {
            "ec2:ResourceTag/kubernetes.io/created-for/pvc/name": "*"
          }
        }
      },
      {
        "Effect": "Allow",
        "Action": "ec2:DeleteSnapshot",
        "Resource": "*",
        "Condition": {
          "StringLike": {
            "ec2:ResourceTag/CSIVolumeSnapshotName": "*"
          }
        }
      },
      {
        "Effect": "Allow",
        "Action": "ec2:DeleteSnapshot",
        "Resource": "*",
        "Condition": {
          "StringLike": {
            "ec2:ResourceTag/ebs.csi.aws.com/cluster": "true"
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

# Create IAM instance profile for the worker nodes
resource "aws_iam_instance_profile" "workernodes" {
  name = format("%s-eks-node-instance-profile-%s", local.project_prefix, local.build_suffix)
  role = aws_iam_role.workernodes.name
}

