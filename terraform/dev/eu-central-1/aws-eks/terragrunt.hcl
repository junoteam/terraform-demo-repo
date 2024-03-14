locals {
  project_vars     = read_terragrunt_config(find_in_parent_folders("project.hcl"))
  environment_vars = read_terragrunt_config(find_in_parent_folders("environment.hcl"))
  partition_vars   = read_terragrunt_config(find_in_parent_folders("partition.hcl"))

  aws_region_short_name_map = local.project_vars.locals.aws_region_short_name_map

  project_name          = local.project_vars.locals.project_name
  environment           = local.environment_vars.locals.environment
  aws_region            = local.partition_vars.locals.aws_region
  aws_region_short_name = local.aws_region_short_name_map[local.aws_region]
}

# Generate local Kubernetes provider for EKS module
generate "kubernetes" {
  path      = "kube.tf"
  if_exists = "overwrite_terragrunt"
  contents  = <<EOF
data "aws_eks_cluster" "this" {
  name = aws_eks_cluster.this[0].id
}

data "aws_eks_cluster_auth" "this" {
  name = aws_eks_cluster.this[0].id
}

provider "kubernetes" {
  host                   = data.aws_eks_cluster.this.endpoint
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.this.certificate_authority.0.data)
  token                  = data.aws_eks_cluster_auth.this.token
}
    EOF
}

include {
  path = find_in_parent_folders()
}

terraform {
  source = "git::git@github.com:terraform-aws-modules/terraform-aws-eks.git//.?ref=v20.8.3"
}

dependency "aws-vpc" {
  config_path = "../aws-vpc"
}

inputs = {
  cluster_name                    = "${local.environment}-${local.project_name}-${local.partition_vars.locals.eks_cluster_suffix}"
  cluster_version                 = local.partition_vars.locals.eks_cluster_version
  vpc_id                          = dependency.aws-vpc.outputs.vpc_id
  subnet_ids                      = dependency.aws-vpc.outputs.private_subnets
  cluster_endpoint_private_access = true
  cluster_endpoint_public_access  = true

  manage_aws_auth_configmap = true
  aws_auth_users = local.project_vars.locals.eks_map_users

  # Extend cluster security group rules
  cluster_security_group_additional_rules = {
    egress_nodes_ephemeral_ports_tcp = {
      description                = "To node 1025-65535"
      protocol                   = "tcp"
      from_port                  = 1025
      to_port                    = 65535
      type                       = "egress"
      source_node_security_group = true
    }
  }

  # Extend node-to-node security group rules
  node_security_group_additional_rules = {
    ingress_self_all = {
      description = "Node to node all ports/protocols"
      protocol    = "-1"
      from_port   = 0
      to_port     = 0
      type        = "ingress"
      self        = true
    }
    ingress_cluster_all = {
      description                   = "Cluster to node all ports/protocols"
      protocol                      = "-1"
      from_port                     = 0
      to_port                       = 0
      type                          = "ingress"
      source_cluster_security_group = true
    }
    egress_all = {
      description      = "Node all egress"
      protocol         = "-1"
      from_port        = 0
      to_port          = 0
      type             = "egress"
      cidr_blocks      = ["0.0.0.0/0"]
      ipv6_cidr_blocks = ["::/0"]
    }
  }

  # EKS managed group
  eks_managed_node_groups = {
    green = {
      min_size     = 1
      max_size     = 10
      desired_size = 1

      instance_types = ["t3.medium"]
      capacity_type  = "SPOT"
    }
  }

  tags = {
    environment   = "${local.environment}"
    terraformPath = path_relative_to_include()
    project       = "${local.project_name}"
  }
}
