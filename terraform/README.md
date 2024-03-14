## Manage infrastructure

### Config structure

`./terraform/live` contains configuration files per environment and devided on partitions depending on region
`./terraform/live/shared` environment contains resources which shared across environments  
`./terraform/modules` contains terraform modules

### Resources

These configs are managing:

* VPC and subnets
* Security Groups
* ALB (public and internal)
* EKS cluster

## Operations

### Set VPC settings
Use `./terraform/live/<new_env>/<region>/partition.hcl` file to set VPC settings: cidr, subnets etc

### Terragrunt plan

To check configuration across entire partition
```
cd terraform/live/dev/eu-central-1
terragrunt run-all plan
```
### Terragrunt apply

To apply configuration across entire partition.
```
cd terraform/live/dev/eu-central-1
terragrunt run-all apply
```

### Terragrunt plan (per resource)

To check configuration across entire partition
```
cd terraform/live/dev/eu-central-1/aws-ecr/
terragrunt run-all plan
```
