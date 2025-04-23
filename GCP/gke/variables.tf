variable "gke_num_nodes" {
  default     = 1
  description = "number of gke nodes"
}

variable "GCP_REGION" {
  description = "GCP region name"
  type        = string
}

variable "GCP_BUCKET_NAME" {
  type    = string
}