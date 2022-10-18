provider "kubernetes" {
  host                   = module.eks.cluster_endpoint
  cluster_ca_certificate = base64decode(module.eks.cluster_certificate_authority_data)
}

provider "aws" {
  region  = "ap-southeast-1"
  access_key = "AKIA3M36Y5WDZL5IU7MI"
  secret_key = "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"
}

data "aws_availability_zones" "available" {}

locals {
  cluster_name = "webapi-eks"
}

provider "helm" {
  kubernetes {
    host                   = module.eks.cluster_endpoint
    cluster_ca_certificate = base64decode(module.eks.cluster_certificate_authority_data)
    exec {
      api_version = "client.authentication.k8s.io/v1alpha1"
      args        = ["eks", "get-token", "--cluster-name", local.cluster_name]
      command     = "aws"
    }
  }
}

# Create IAM role for service accounts (IRSA) for use within EKS clusters
module "lb_irsa_role" {
  source    = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks"

  role_name = "${local.cluster_name}_eks_lb"
  attach_load_balancer_controller_policy = true

  oidc_providers = {
    main = {
      provider_arn               = module.eks.oidc_provider_arn
      namespace_service_accounts = ["kube-system:aws-load-balancer-controller"]
    }
  }

  tags = {
    Name = "vpc-eks-lb-irsa"
  }
}
