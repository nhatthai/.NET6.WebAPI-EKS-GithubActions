# .NET6.WebAPI to EKS using GithubActions
Deploy a sample .Net6 WebAPI to Amazon EKS with Github Actions

### Github Runner Requirements
+ Install Docker & DockerCompose
+ Minikube or Kubernetes cluster (see below if needed)
+ Install Amazon CLI/ eksctl
+ Install Kubectl

### Usage

+ Update kubeconfig
```
aws eks update-kubeconfig --region ap-southeast-1 --name eks-github
```

+ Create Role
```
aws iam create-role --role-name eksClusterRole --assume-role-policy-document file://AWS/cluster-trust-policy.json

aws iam attach-role-policy --policy-arn arn:aws:iam::aws:policy/AmazonEKSClusterPolicy --role-name eksClusterRole
```

+ oidc-provider and cluster
```
eksctl utils associate-iam-oidc-provider --region=ap-southeast-1 --cluster=eks-github --approve
```

+ Create policy
```
aws iam create-policy --policy-name ALBIngressControllerIAMPolicy --policy-document file://AWS/iam_policy.json
```

+ Create Role name for aws load Balancer
```
aws iam create-role --role-name AmazonEKSLoadBalancerControllerRole --assume-role-policy-document file://AWS/load-balancer-role-trust-policy.json
```

+ Attach the required Amazon EKS managed IAM policy to the IAM role
```
aws iam attach-role-policy --policy-arn arn:aws:iam::ACCOUNT_ID:policy/ALBIngressControllerIAMPolicy --role-name AmazonEKSLoadBalancerControllerRole
```

+ Create an additional policy
```
aws iam create-policy --policy-name AWSLoadBalancerControllerAdditionalIAMPolicy --policy-document file://AWS/iam_policy_v1_to_v2_additional.json
```

+ Attach Role Policy
```
aws iam attach-role-policy --role-name AmazonEKSLoadBalancerControllerRole  --policy-arn arn:aws:iam::ACCOUNT_ID:policy/AWSLoadBalancerControllerAdditionalIAMPolicy
```

+ Create Service Account
```
eksctl create iamserviceaccount --cluster=eks-github --namespace=kube-system --name=aws-load-balancer-controller --role-name AmazonEKSLoadBalancerControllerRole --attach-policy-arn=arn:aws:iam::ACCOUNT_ID:policy/ALBIngressControllerIAMPolicy --override-existing-serviceaccounts --approve

kubectl apply -f AWS/aws-load-balancer-controller-service-account.yml
```

+ Get IAM Service Account
```
eksctl  get iamserviceaccount --cluster eks-github

kubectl describe sa aws-load-balancer-controller -n kube-system

kubectl apply -k "github.com/aws/eks-charts/stable/aws-load-balancer-controller/crds?ref=master"

helm install aws-load-balancer-controller eks/aws-load-balancer-controller --set clusterName=eks-github --set serviceAccount.create=false --set serviceAccount.name=aws-load-balancer-controller -n kube-system
```

+ Verify that the AWS Load Balancer Controller is installed:
```
kubectl get deployment -n kube-system aws-load-balancer-controller
```

+ Get log AWS Load Balancer Controller
```
kubectl logs -n kube-system deployment.apps/aws-load-balancer-controller
```

### Issues
+ Couldn't create an AWS Load Balancer Controller
```
Add permission iam_policy_v1_to_v2_additional.json
```


+ Couldn't mapping to webapi service
```
Because set Path_Base in code with .NET6(Not set Path_Base variable)
```


### Result
+ ![Web API](./images/mapping-webapi.png)

### Reference
+ [An ALB Ingress in Amazon EKS](https://aws.amazon.com/premiumsupport/knowledge-center/eks-alb-ingress-aws-waf/)
+ [AWS Load Balancer Controller](https://docs.aws.amazon.com/eks/latest/userguide/aws-load-balancer-controller.html)