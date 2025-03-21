#Project Global
variable "admin_src_addr" {
  type        = string
  description = "Allowed Admin source IP prefix"
  default     = "0.0.0.0/0"
}

variable "aws_region" {
  description = "The AWS region to deploy the EKS cluster"
  type        = string
  default     = "us-east-1"
}

#AWS
variable "eks_addons" {
  type = list(object({
    name    = string
    version = string
  }))
  default = [
    {
      name    = "kube-proxy"
      version = "v1.29.10-eksbuild.3"
    },
    {
      name    = "vpc-cni"
      version = "v1.19.0-eksbuild.1"
    },
    {
      name    = "coredns"
      version = "v1.11.1-eksbuild.4"
    },
    {
      name    = "aws-ebs-csi-driver"
      version = "v1.39.0-eksbuild.1"
    }
  ]
}

variable "create_oidc_provider" {
  description = "Whether to create OIDC provider for IRSA"
  type        = bool
  default     = true
}








