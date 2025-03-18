# outputs.tf
output "aws_region" {
  value = var.aws_region
}

output "cluster_name" {
  value = data.tfe_outputs.eks.values.cluster_name
}


output "copy_policy_complete" {
  description = "Indicates that the compiled policy has been copied"
  value       = null_resource.copy_compiled_policy.id
}