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
      name        = "lambda-s3-access-policy"
      description = "IAM policy to allow Lambda function to access a specific S3 bucket"

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
        "arn:aws:s3:::prod-random-named-bucket-1",
        "arn:aws:s3:::prod-random-named-bucket-1/*"
      ]
    }
  ]
}
EOF
    }
    lambda_ecr_policy = {
      name        = "lambda-ecr-access-policy"
      description = "IAM policy to allow Lambda function to access ECR"
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
      "Resource": "arn:aws:ecr:us-east-2:382370460911:repository/dev-env-ecr"
    }
  ]
}
EOF

    }
  }
}
