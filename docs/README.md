## Manage infrastructure

### Config structure

### Resources

## Operations

```bash
pre-commit run --all-files
```

### Terragrunt plan/apply

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
