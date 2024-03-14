include "root" {
  path   = find_in_parent_folders("aws.hcl")
  expose = true
}

terraform {
  source = "git::git@github.com:terraform-aws-modules/terraform-aws-vpc.git//.?ref=v5.6.0"
  #source = "tfr://registry.terraform.io/terraform-aws-modules/vpc/aws?version=5.6.0"
}

data "aws_availability_zones" "available" {}

locals {
  name     = "ex-${basename(path.cwd)}"
  vpc_cidr = "10.0.0.0/16"
  azs      = slice(data.aws_availability_zones.available.names, 0, 3)
}

inputs = {
  name = local.name
  cidr = local.vpc_cidr

  azs             = slice(data.aws_availability_zones.available.names, 0, 3)
  private_subnets = [for k, v in local.azs : cidrsubnet(local.vpc_cidr, 8, k)]
  public_subnets  = [for k, v in local.azs : cidrsubnet(local.vpc_cidr, 8, k + 4)]

  enable_nat_gateway = true
  enable_dns_hostnames = true
  enable_dns_support   = true
  single_nat_gateway = true

  public_subnet_tags = {
    "kubernetes.io/role/elb"                                                                                             = "1"
    "kubernetes.io/cluster/${local.environment}-${local.project_name}-${local.partition_vars.locals.eks_cluster_suffix}" = "shared"
  }

  private_subnet_tags = {
    "kubernetes.io/role/internal-elb"                                                                                    = "1"
    "kubernetes.io/cluster/${local.environment}-${local.project_name}-${local.partition_vars.locals.eks_cluster_suffix}" = "shared"
  }

  tags = {
    environment   = "${local.environment}"
    terraformPath = path_relative_to_include()
    project       = "${local.project_name}"
  }
}
