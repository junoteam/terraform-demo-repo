include "root" {
  path   = find_in_parent_folders("aws.hcl")
  expose = true
}

terraform {
  source = "tfr://registry.terraform.io/terraform-aws-modules/security-group/aws?version=5.1.2"
}

dependency "vpc" {
  config_path  = "../aws-vpc"
}

inputs = {
  name        = include.root.inputs.sg_ec2.sg_ec2_name
  description = "Security group for example usage with EC2 instance"
  vpc_id      = dependency.vpc.outputs.vpc_id

  ingress_cidr_blocks = ["0.0.0.0/0"]
  ingress_rules       = ["ssh-tcp", "all-icmp"]
  egress_rules        = ["all-all"]

}
