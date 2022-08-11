# .NET6.WebAPI to EKS using GithubActions
Deploy a sample .Net6 WebAPI to Amazon EKS with Github Actions

### Github Runner Requirements
+ Install Docker & DockerCompose
+ Minikube or Kubernetes cluster (see below if needed)
+ Install Amazon CLI/ eksctl
+ Install Kubectl

### Usage

### Install the AWS Load Balancer Controller using Helm 3.0.0
####Install the TargetGroupBinding custom resource definitions:
    ```
    kubectl apply -k "github.com/aws/eks-charts/stable/aws-load-balancer-controller//crds?ref=master"
    ```

### Reference
