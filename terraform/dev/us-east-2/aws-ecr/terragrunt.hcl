include "root" {
  path   = find_in_parent_folders("aws.hcl")
  expose = true
}

terraform {
  source = "tfr://registry.terraform.io/terraform-aws-modules/ecr/aws?version=1.6.0"
}

locals {
}

inputs = {
  name                 = var.name
  image_tag_mutability = "MUTABLE"
}
