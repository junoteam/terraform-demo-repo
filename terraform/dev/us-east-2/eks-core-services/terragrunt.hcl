include "root" {
  path   = find_in_parent_folders("aws.hcl")
  expose = true
}

terraform {
  source = "${get_parent_terragrunt_dir()}/../modules//core-services"
}

locals {
}

dependency "aws-eks" {
  config_path = "../aws-eks"
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
