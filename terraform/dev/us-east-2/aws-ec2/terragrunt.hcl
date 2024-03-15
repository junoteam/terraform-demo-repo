include "root" {
  path   = find_in_parent_folders("aws.hcl")
  expose = true
}

terraform {
  source = "tfr://registry.terraform.io/terraform-aws-modules/ec2-instance/aws?version=5.6.1"
}

dependency "vpc" {
  config_path = "../aws-vpc"
}

dependency "sg" {
  config_path = "../aws-sg"
  mock_outputs = yamldecode(file(find_in_parent_folders("mock-outputs.yaml"))).sg
}

dependency "aws-datasource" {
  config_path = "../aws-datasource"
  mock_outputs = yamldecode(file(find_in_parent_folders("mock-outputs.yaml"))).datasource
}

inputs = {
  name                        = include.root.inputs.ec2_1.ec2_name
  ami                         = dependency.aws-datasource.outputs.amazon_linux_ami_id
  create_spot_instance        = true
  spot_price                  = "0.60"
  spot_type                   = "persistent"
  instance_type               = "t3.medium"
  availability_zone           = element(dependency.vpc.outputs.azs, 0)
  subnet_id                   = element(dependency.vpc.outputs.private_subnets, 0)
  vpc_security_group_ids      = [dependency.sg.outputs.security_group_id]
  associate_public_ip_address = true
  user_data                   = file("./init.yaml")

  create_iam_instance_profile = true
  iam_role_description        = "IAM role for EC2 instance"
  iam_role_policies = {
    AdministratorAccess = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
  }

  enable_volume_tags = false
  root_block_device = [
    {
      encrypted   = true
      volume_type = "gp3"
      throughput  = 200
      volume_size = 50
    },
  ]
}
