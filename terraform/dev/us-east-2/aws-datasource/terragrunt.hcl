include "root" {
  path   = find_in_parent_folders("aws.hcl")
  expose = true
}

terraform {
  source = "${get_terragrunt_dir()}/../../../modules/aws-datasource"
}

inputs = {
}
