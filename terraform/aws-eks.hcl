# We overwrite terraform block to use custom provider
generate "terraform" {
  path      = "versions.tf"
  if_exists = "overwrite"
  contents  = <<-EOF
    terraform {
      backend "s3" {}
      required_version = "~> 1.7.4"
      required_providers {
        aws = {
          source  = "hashicorp/aws"
          version = "~> 5.40.0"
        }
        kubectl = {
          source  = "gavinbunney/kubectl"
          version = "~> 1.14.0"
        }
        kubernetes = {
          source  = "hashicorp/kubernetes"
          version = "~> 2.27.0"
        }
      }
    }
  EOF
}

# We configure k8s related providers
generate "aws-eks" {
  path      = "k8s.auto.tf"
  if_exists = "overwrite_terragrunt"
  contents  = <<-EOF
    provider "kubectl" {
      host                   = data.aws_eks_cluster.cluster.endpoint
      cluster_ca_certificate = base64decode(data.aws_eks_cluster.cluster.certificate_authority.0.data)

      exec {
        api_version = "client.authentication.k8s.io/v1beta1"
        command     = "aws"
        # This requires the awscli to be installed locally where Terraform is executed
        args = ["eks", "get-token", "--cluster-name", data.aws_eks_cluster.cluster.id]
      }
    }

    provider "kubernetes" {
      host                   = data.aws_eks_cluster.cluster.endpoint
      cluster_ca_certificate = base64decode(data.aws_eks_cluster.cluster.certificate_authority.0.data)

      exec {
        api_version = "client.authentication.k8s.io/v1beta1"
        command     = "aws"
        # This requires the awscli to be installed locally where Terraform is executed
        args = ["eks", "get-token", "--cluster-name", data.aws_eks_cluster.cluster.id]
      }
    }

    provider "helm" {
      kubernetes {
        host                   = data.aws_eks_cluster.cluster.endpoint
        cluster_ca_certificate = base64decode(data.aws_eks_cluster.cluster.certificate_authority.0.data)

        exec {
          api_version = "client.authentication.k8s.io/v1beta1"
          command     = "aws"
          # This requires the awscli to be installed locally where Terraform is executed
          args = ["eks", "get-token", "--cluster-name", data.aws_eks_cluster.cluster.id]
        }
      }
    }
  EOF
}
