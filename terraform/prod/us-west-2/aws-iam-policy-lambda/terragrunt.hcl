include "root" {
  path           = find_in_parent_folders("aws.hcl")
  expose         = true
  merge_strategy = "deep"
}

terraform {
  source = "tfr:///terraform-aws-modules/iam/aws//wrappers/iam-policy?version=5.37.1"
}

inputs = {
  items = {
    lambda_s3_policy = {
      name        = include.root.inputs.iam.lambda_s3_policy_name
      description = include.root.inputs.iam.lambda_s3_policy_description

      policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "s3:GetObject",
        "s3:ListBucket"
      ],
      "Resource": [
        "arn:aws:s3:::${include.root.inputs.s3_buckets.bucket_name_1}",
        "arn:aws:s3:::${include.root.inputs.s3_buckets.bucket_name_1}/*"
      ]
    }
  ]
}
EOF
    }
    lambda_ecr_policy = {
      name        = include.root.inputs.iam.lambda_ecr_policy_name
      description = include.root.inputs.iam.lambda_ecr_policy_description
      policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "ecr:GetDownloadUrlForLayer",
        "ecr:BatchGetImage",
        "ecr:GetAuthorizationToken"
      ],
      "Resource": "arn:aws:ecr:${include.root.locals.region}:${get_aws_account_id()}:repository/${include.root.inputs.ecr_1.repo_name}"
    }
  ]
}
EOF

    }
  }
}
