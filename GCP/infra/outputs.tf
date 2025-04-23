output "project_prefix" {
  value = var.project_prefix
}

output "gcp_project_id" {
  value = var.GCP_PROJECT_ID
}

output "gcp_region" {
  value = var.GCP_REGION
}

output "build_suffix" {
  value = random_id.build_suffix.hex
}

output "vpc_name" {
	value = google_compute_network.vpc_network.name
}

output "vpc_subnet" {
	value = google_compute_subnetwork.public_subnetwork.name
}

output "vpc_subnet_id" {
	value = google_compute_subnetwork.public_subnetwork.id
}

output "cidr" {
	value = var.cidr
}

# output "service_account" {
# 	value = var.service_account
# }