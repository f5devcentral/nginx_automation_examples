# Read infra state from S3
data "terraform_remote_state" "infra" {
  backend = "s3"
  config = {
    bucket =  var.AWS_S3_BUCKET_NAME        # Your S3 bucket namee
    key    = "infra/terraform.tfstate"       # Path to infra's state file
    region = var.AWS_REGION                      # AWS region
  }
}

# Read eks state from S3
data "terraform_remote_state" "eks" {
  backend = "s3"
  config = {
    bucket =  var.AWS_S3_BUCKET_NAME        # Your S3 bucket name
    key    = "eks-cluster/terraform.tfstate" # Path to EKS state file
    region = var.AWS_REGION                       # AWS region
  }
}

# Read nap state from S3
data "terraform_remote_state" "nap" {
  backend = "s3"
  config = {
    bucket =  var.AWS_S3_BUCKET_NAME        # Your S3 bucket name
    key    = "nap/terraform.tfstate"         # Path to NAP state file
    region = var.AWS_REGION                       # AWS region
  }
}

# Keep existing data sources for Kubernetes
data "aws_eks_cluster_auth" "auth" {
  name = data.terraform_remote_state.eks.outputs.cluster_name
}

