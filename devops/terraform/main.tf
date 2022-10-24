provider "kubernetes" {
  host                   = module.eks.cluster_endpoint
  cluster_ca_certificate = base64decode(module.eks.cluster_certificate_authority_data)
}

provider "aws" {
  region  = "ap-southeast-1"
  access_key = ""
  secret_key = ""
}

data "aws_availability_zones" "available" {}

locals {
  cluster_name = "webapi-eks"
}

provider "helm" {
  kubernetes {
    host                   = module.eks.cluster_endpoint
    cluster_ca_certificate = base64decode(module.eks.cluster_certificate_authority_data)
  }
}