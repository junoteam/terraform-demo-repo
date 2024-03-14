include "root" {
  path   = find_in_parent_folders("aws.hcl")
  expose = true
}

terraform {
  #source = "git::git@github.com:terraform-aws-modules/terraform-aws-vpc.git//.?ref=v5.6.0"
  source = "tfr://registry.terraform.io/terraform-aws-modules/vpc/aws?version=5.6.0"
}

locals {
  azs = formatlist("%s%s", include.root.locals.region, ["a","b","c"])
  vpc_cidr = include.root.inputs.vpc.vpc_cidr
}

inputs = {
  name = include.root.inputs.vpc.vpc_name
  cidr = local.vpc_cidr

  azs             = local.azs
  private_subnets = [for k, v in local.azs : cidrsubnet(local.vpc_cidr, 8, k)]
  public_subnets  = [for k, v in local.azs : cidrsubnet(local.vpc_cidr, 8, k + 4)]

  enable_nat_gateway = true
  enable_dns_hostnames = true
  enable_dns_support   = true
  single_nat_gateway = true

  public_subnet_tags = {
    "kubernetes.io/role/elb" = "1"
    "kubernetes.io/cluster/${include.root.inputs.eks.eks_cluster_name}" = "shared"
  }

  private_subnet_tags = {
    "kubernetes.io/role/internal-elb"  = "1"
    "kubernetes.io/cluster/${include.root.inputs.eks.eks_cluster_name}" = "shared"
  }
}
