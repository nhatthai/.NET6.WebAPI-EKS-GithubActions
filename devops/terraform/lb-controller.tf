resource "helm_release" "alb" {
  repository = "https://aws.github.io/eks-charts"
  chart      = "aws-load-balancer-controller"
  name  	=  "aws-load-balancer-controller"
  namespace = "kube-system"

  set {
    name  = "region"
    value = var.region
  }

  set {
    name  = "vpcId"
    value = module.vpc.vpc_id
  }

  set {
    name  = "image.repository"
    value = "602401143452.dkr.ecr.eu-west-2.amazonaws.com/amazon/aws-load-balancer-controller"
  }

  set {
    name  = "serviceAccount.create"
    value = "false"
  }

  set {
    name  = "serviceAccount.name"
    value = kubernetes_service_account.alb_service_account.metadata[0].name
  }

  set {
    name  = "clusterName"
    value = local.cluster_name
  }
}


resource "aws_iam_policy" "alb_policy" {
  name        = "${local.cluster_name}-alb-policy"
  path        = "/"
  description = "Policy for the AWS Load Balancer Controller that allows it to make calls to AWS APIs."
  policy = file("iam-policy.json")
}


resource "aws_iam_role" "alb_iam_role" {
  name = "${local.cluster_name}-alb-role"

  assume_role_policy = jsonencode({
	Version = "2012-10-17"
	Statement = [
        {
            Effect = "Allow"
            Principal = {
              Federated = "${module.eks.oidc_provider_arn}"
            }
            Action = "sts:AssumeRoleWithWebIdentity"
            Condition = {
                StringEquals = {
                  "${module.eks.oidc_provider_arn}:aud" = "sts.amazonaws.com"
                  "${replace(module.eks.arn, "https://", "")}:sub" = "system:serviceaccount:kube-system:aws-load-balancer-controller
                }
            }
        }
	]
  })
}

resource "aws_iam_role_policy_attachment" "policy_attachment" {
  role   	= aws_iam_role.alb_iam_role.name
  policy_arn = aws_iam_policy.alb_policy.arn
}

# Deploy Ingress Controller(Load Balancer Controller)
# name      = "aws-load-balancer-controller"
# namespace = "kube-system"
resource "kubernetes_service_account" "alb_service_account" {
  metadata {
	name  	=  "aws-load-balancer-controller"
	namespace   = "kube-system"

	labels = {
    "app.kubernetes.io/component" = "controller"
    "app.kubernetes.io/name"  	=  "aws-load-balancer-controller"
	}

	annotations = {
  	"eks.amazonaws.com/role-arn" = "arn:aws:iam::${local.account_id}:role/${aws_iam_role.alb_iam_role.name}"
	}
  }
}
