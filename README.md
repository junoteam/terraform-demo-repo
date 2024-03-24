### Example of how to provision cloud resources in AWS Amazon with the help of Terraform and Terragrunt

TF/TG versions pin:

```bash
Terraform version  = "~> 1.7.4"
Terragrunt version = "~> 0.55.16"
```

TF's providers versions pin:
```bash
aws = {
  source  = "hashicorp/aws"
  version = "~> 5.40.0"
}

kubectl = {
  source  = "gavinbunney/kubectl"
  version = "~> 1.14.0"
}

kubernetes = {
  source  = "hashicorp/kubernetes"
  version = "~> 2.27.0"
}
```

## Manage infrastructure

### Config structure

### Resources

## Operations

```bash
pre-commit run --all-files
```

### Terragrunt plan/apply per region
```bash
cd terraform/dev/us-east-2/
aws-vault exec $AWS_PROFILE -- terragrunt run-all apply
```

### Terragrunt plan/apply (per resource)

```bash
cd terraform/dev/us-east-2/aws-vpc
aws-vault exec $AWS_PROFILE -- terragrunt apply
```

Get cluster config
```bash
aws eks --region us-east-2 update-kubeconfig --kubeconfig ./config --name <cluster-name>
```

Connect to cluster:
```bash
k9s --kubeconfig config
```
