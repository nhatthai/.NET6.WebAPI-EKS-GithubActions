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
