include "root" {
  path   = find_in_parent_folders("aws.hcl")
  expose = true
  merge_strategy = "deep"
}

include "k8s" {
  path = find_in_parent_folders("aws-eks.hcl")
}

terraform {
  source = "tfr://registry.terraform.io/terraform-aws-modules/eks/aws?version=20.8.3"
}

dependency "vpc" {
  config_path  = "../aws-vpc"
  mock_outputs = yamldecode(file(find_in_parent_folders("mock-outputs.yaml"))).vpc
  mock_outputs_allowed_terraform_commands = ["plan", "init", "apply"]
}

inputs = {

  cluster_name    = include.root.inputs.eks_1.eks_cluster_name
  cluster_version = include.root.inputs.eks_1.eks_version

  cluster_endpoint_public_access           = true
  enable_cluster_creator_admin_permissions = true

  cluster_addons = {
    coredns = {
      most_recent = true
    }
    kube-proxy = {
      most_recent = true
    }
    vpc-cni = {
      most_recent = true
      configuration_values = jsonencode({
        env = {
          # Reference docs https://docs.aws.amazon.com/eks/latest/userguide/cni-increase-ip-addresses.html
          ENABLE_PREFIX_DELEGATION = "true"
          WARM_PREFIX_TARGET       = "1"
        }
      })
    }
  }

  vpc_id     = dependency.vpc.outputs.vpc_id
  subnet_ids = dependency.vpc.outputs.private_subnets

  eks_managed_node_group_defaults = {
    capacity_type  = "SPOT"
    instance_types = ["t3.small", "t2.small"]
    min_size       = 2
    desired_size   = 2
    max_size       = 3
  }

  eks_managed_node_groups = {
    example = {
      min_size     = 2
      max_size     = 3
      desired_size = 2
      instance_types = ["t3.large"]
    }
  }

  aws_auth_users = [
    for user in ["alex-alex", "alex-berber"] : {
      userarn  = "arn:aws:iam::${include.root.locals.account_id}:user/${user}"
      username = user
      groups   = ["system:masters"]
    }
  ]
}

generate "aws-eks-auth" {
  path      = "k8s-auth.auto.tf"
  if_exists = "overwrite_terragrunt"
  contents  = <<-EOF
    data "aws_eks_cluster" "cluster" {
      name = aws_eks_cluster.this[0].id
    }

    data "aws_eks_cluster_auth" "cluster" {
      name = aws_eks_cluster.this[0].id
    }
  EOF
}
