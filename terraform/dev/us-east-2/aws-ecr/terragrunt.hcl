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
  source = "${get_parent_terragrunt_dir()}/../modules//aws-ecr"
}

inputs = {
  tags = {
    environment   = "${local.environment}"
    terraformPath = path_relative_to_include()
    project       = "${local.project_name}"
  }
  name = local.project_vars.locals.ecr_name
}