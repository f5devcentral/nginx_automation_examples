terrafrom {
    backend "s3" {
    bucket         = "your-unique-bucket-name" # Replace with your actual bucket name
    key            = "eks-cluster/terraform.tfstate"       # Path to state file
    region         = "us-east-1"                     # AWS region
    dynamodb_table = "terraform-lock-table"          # DynamoDB table for state locking
    encrypt        = true  
                           
  }
}
