#Project Globals
variable "admin_src_addr" {
  type        = string
  description = "Allowed Admin source IP prefix"
  default     = "0.0.0.0/0"
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
# eks-cluster/variables.tf
variable "project_prefix" {
  type = string
}

variable "resource_owner" {
  type = string
}

variable "build_suffix" {
  type = string
}

variable "aws_region" {
  type = string
}

variable "azs" {
  type = list(string)
}

variable "vpc_id" {
  type = string
}

variable "vpc_main_route_table_id" {
  type = string
}

variable "public_subnet_ids" {
  type = list(string)
}

variable "eks_cidr" {
  type = string
}

variable "internal_sg_id" {
  type = string
}











