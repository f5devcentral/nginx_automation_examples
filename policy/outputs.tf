output "copy_policy_complete" {
  description = "Indicates that the compiled policy has been copied"
  value       = null_resource.copy_compiled_policy.id
}