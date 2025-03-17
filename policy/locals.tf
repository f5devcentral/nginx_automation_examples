# policy/locals.tf
locals {
  project_prefix          = var.project_prefix
  build_suffix            = var.build_suffix
  aws_region              = var.aws_region
  host                    = var.cluster_endpoint
  cluster_ca_certificate  = var.cluster_ca_certificate
  cluster_name            = var.cluster_name
  app                     = format("%s-nap-%s", local.project_prefix, local.build_suffix)
}
