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
variable "ssh_key" {
  type        = string
  description = "Unneeded for EKS, only present for warning handling with TF cloud variable set"
}











