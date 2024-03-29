include "root" {
  path           = find_in_parent_folders("aws.hcl")
  expose         = true
  merge_strategy = "deep"
}

terraform {
  source = "tfr://registry.terraform.io/terraform-aws-modules/iam/aws//modules/iam-assumable-role?version=5.37.1"
}

dependency "iam-policy" {
  config_path = "../aws-iam-policy-lambda"
  mock_outputs                            = yamldecode(file(find_in_parent_folders("mock-outputs.yaml"))).lambda_policy
  mock_outputs_allowed_terraform_commands = ["plan", "init"]
}

inputs = {
  create_role = true
  role_requires_mfa = false

  role_name    = include.root.inputs.iam.lambda_role_name
  role_description = include.root.inputs.iam.lambda_role_description
  role_path = "/"

  trusted_role_services = ["lambda.amazonaws.com"]
  custom_role_policy_arns = [dependency.iam-policy.outputs.wrapper["lambda_s3_policy"].arn, dependency.iam-policy.outputs.wrapper["lambda_ecr_policy"].arn]
}
