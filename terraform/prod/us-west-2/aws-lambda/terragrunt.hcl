include "root" {
  path           = find_in_parent_folders("aws.hcl")
  expose         = true
  merge_strategy = "deep"
}

terraform {
  source = "tfr://registry.terraform.io/terraform-aws-modules/lambda/aws?version=7.2.3"
}

dependency "iam" {
  config_path                             = "../aws-iam-role-lambda"
  mock_outputs                            = yamldecode(file(find_in_parent_folders("mock-outputs.yaml"))).lambda_iam
  mock_outputs_allowed_terraform_commands = ["plan", "init"]

}

inputs = {
  function_name = include.root.inputs.lambda_1.lambda_name
  description   = "My awesome lambda function"
  lambda_role = dependency.iam.outputs.iam_role_arn
  create_package = false
  image_uri    = include.root.inputs.lambda_1.image_uri
  package_type = "Image"
}
