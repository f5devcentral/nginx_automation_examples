# OIDC Provider with current GitHub thumbprint and validation
resource "aws_iam_openid_connect_provider" "github_oidc" {
  url             = "https://token.actions.githubusercontent.com"
  client_id_list  = ["sts.amazonaws.com"]
  thumbprint_list = ["1c58a3a8518e8759bf075b76b750d4f2df264fcd"] # Updated 2024-02 thumbprint

  lifecycle {
    precondition {
      condition     = length(var.github_repository) > 0
      error_message = "GitHub repository must be defined"
    }
  }
}

# Enhanced Execution Role with session controls
resource "aws_iam_role" "terraform_execution_role" {
  name               = "TerraformCIExecutionRole"
  description        = "Role for Terraform CI/CD executions"
  assume_role_policy = data.aws_iam_policy_document.oidc_assume.json

  max_session_duration = 3600 # 1 hour maximum
  permissions_boundary = "arn:aws:iam::aws:policy/PowerUserAccess"
}

data "aws_iam_policy_document" "oidc_assume" {
  statement {
    actions = ["sts:AssumeRoleWithWebIdentity"]
    effect  = "Allow"

    principals {
      type        = "Federated"
      identifiers = [aws_iam_openid_connect_provider.github_oidc.arn]
    }

    condition {
      test     = "StringEquals"
      variable = "token.actions.githubusercontent.com:aud"
      values   = ["sts.amazonaws.com"]
    }

    condition {
      test     = "StringLike"
      variable = "token.actions.githubusercontent.com:sub"
      values   = ["repo:akananth/nginx_automation_examples:ref:refs/heads/apply-nap"]
    }
  }
}

# Enhanced State Access Policy with least privilege
resource "aws_iam_policy" "terraform_state_access" {
  name        = "TerraformStateAccess"
  description = "Granular access to state resources"
  policy      = data.aws_iam_policy_document.state_access.json
}

data "aws_iam_policy_document" "state_access" {
  statement {
    sid    = "S3StateAccess"
    effect = "Allow"
    actions = [
      "s3:GetObject",
      "s3:PutObject",
      "s3:ListBucket"
    ]
    resources = [
      aws_s3_bucket.state.arn,
      "${aws_s3_bucket.state.arn}/infra/*" # Restrict to specific path
    ]
  }

  statement {
    sid    = "DynamoDBLocking"
    effect = "Allow"
    actions = [
      "dynamodb:GetItem",
      "dynamodb:PutItem",
      "dynamodb:DeleteItem",
      "dynamodb:DescribeTable"
    ]
    resources = [aws_dynamodb_table.terraform_state_lock.arn]
  }

  statement {
    sid    = "KMSDecrypt"
    effect = "Allow"
    actions = [
      "kms:Decrypt",
      "kms:Encrypt",
      "kms:GenerateDataKey"
    ]
    resources = [aws_kms_key.terraform_state.arn]
  }
}

