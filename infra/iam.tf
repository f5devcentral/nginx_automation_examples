# Fetch existing IAM policy and role
data "aws_iam_policy" "terraform_state_access" {
  name = "TerraformStateAccess"
}

data "aws_iam_role" "terraform_execution_role" {
  name = "TerraformCIExecutionRole"
}

# Attach the existing policy to the existing role
resource "aws_iam_role_policy_attachment" "state_access" {
  role       = data.aws_iam_role.terraform_execution_role.name
  policy_arn = data.aws_iam_policy.terraform_state_access.arn
}