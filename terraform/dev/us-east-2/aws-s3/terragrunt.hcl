include "root" {
  path           = find_in_parent_folders("aws.hcl")
  expose         = true
  merge_strategy = "deep"
}

# I use wrappers to create multiple items of same type
terraform {
  source = "tfr://registry.terraform.io/terraform-aws-modules/s3-bucket/aws//wrappers?version=4.1.1"
}

inputs = {
  defaults = {
    force_destroy = true

    attach_elb_log_delivery_policy        = true
    attach_lb_log_delivery_policy         = true
    attach_deny_insecure_transport_policy = true
    attach_require_latest_tls_policy      = true
  }

  items = {
    bucket1 = {
      bucket = "${include.root.inputs.s3_buckets.bucket_name_1}"
      tags = {
        Secure = "probably"
      }
    }
    bucket2 = {
      bucket = "${include.root.inputs.s3_buckets.bucket_name_2}"
      tags = {
        Secure = "probably"
      }
    }
  }

}
