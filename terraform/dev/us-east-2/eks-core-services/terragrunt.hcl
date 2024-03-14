locals {
  project_vars     = read_terragrunt_config(find_in_parent_folders("project.hcl"))
  environment_vars = read_terragrunt_config(find_in_parent_folders("environment.hcl"))
  partition_vars   = read_terragrunt_config(find_in_parent_folders("partition.hcl"))

  aws_region_short_name_map = local.project_vars.locals.aws_region_short_name_map

  project_name          = local.project_vars.locals.project_name
  environment           = local.environment_vars.locals.environment
  account_id            = local.environment_vars.locals.account_id
  aws_region            = local.partition_vars.locals.aws_region
  aws_region_short_name = local.aws_region_short_name_map[local.aws_region]
}

include {
  path = find_in_parent_folders()
}

terraform {
  source = "${get_parent_terragrunt_dir()}/../modules//core-services"
}

dependency "aws-eks" {
  config_path = "../aws-eks"
}

# Generate local Kubernetes\Helm provider for EKS module
generate "kubernetes" {
  path      = "kube.tf"
  if_exists = "overwrite_terragrunt"
  contents  = <<EOF
data "aws_eks_cluster" "this" {
  name = var.cluster_id
}

data "aws_eks_cluster_auth" "this" {
  name = var.cluster_id
}

provider "kubernetes" {
  host                   = data.aws_eks_cluster.this.endpoint
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.this.certificate_authority.0.data)
  token                  = data.aws_eks_cluster_auth.this.token
}

provider "helm" {
  kubernetes {
    host                   = data.aws_eks_cluster.this.endpoint
    token                  = data.aws_eks_cluster_auth.this.token
    cluster_ca_certificate = base64decode(data.aws_eks_cluster.this.certificate_authority.0.data)
  }
}
    EOF
}

inputs = {
  cluster_id            = dependency.aws-eks.outputs.cluster_id
  environment           = local.environment_vars.locals.environment
  aws_region            = local.partition_vars.locals.aws_region
  enable_prometheus     = true
  enable_pod_monitor    = true

  helm_releases_overrides = {

    metrics-server = {
      enabled = "true"
    }
  }
}