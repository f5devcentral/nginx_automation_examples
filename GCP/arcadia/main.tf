provider "google" {
    region                  = local.region
}
provider "kubernetes" {
    host = local.host
    cluster_ca_certificate = base64decode(local.cluster_ca_certificate)
    token = local.cluster_token
}
provider "helm" {
    kubernetes {
        host = local.host
        cluster_ca_certificate = base64decode(local.cluster_ca_certificate)
        token = local.cluster_token
    }
}