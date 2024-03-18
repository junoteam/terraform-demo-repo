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
