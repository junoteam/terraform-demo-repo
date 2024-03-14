/*
Core Services for EKS:
- ingress-public [kube-system namespaces]
- ingress-private [kube-system namespaces]
- kube-prometheus [monitoring namespaces]
- metric-server [monitoring namespaces]
*/

locals {
  namespaces  = [var.environment, "mgmt", "monitoring"]
  helm_stable = "https://charts.helm.sh/stable"

  helm_releases = {
    ingress-public = {
      namespace  = "kube-system"
      repository = "https://kubernetes.github.io/ingress-nginx"
      chart      = "ingress-nginx"
      version    = "4.1.3"
      enabled    = "true"
    }

    ingress-private = {
      namespace  = "kube-system"
      repository = "https://kubernetes.github.io/ingress-nginx"
      chart      = "ingress-nginx"
      version    = "4.1.3"
      enabled    = "true"
    }

    metrics-server = {
      namespace  = "monitoring"
      repository = "https://kubernetes-sigs.github.io/metrics-server"
      chart      = "metrics-server"
      version    = "3.8.2"
      enabled    = "true"
    }
  }
}

# Main/core namespaces which should be created in Kubernetes cluster
resource "kubernetes_namespace" "core" {
  count = length(local.namespaces)

  metadata {
    name = local.namespaces[count.index]
  }
}

# prometheus should be installed first
resource "helm_release" "prometheus" {
  namespace  = "monitoring"
  repository = "https://prometheus-community.github.io/helm-charts"
  chart      = "kube-prometheus-stack"
  version    = "35.5.1"
  name       = "kube-prometheus-stack"
}

# Install populated releases into Kubernetes cluster
resource "helm_release" "release" {
  for_each = {
    for release in distinct(concat(keys(local.helm_releases), keys(var.helm_releases_overrides))) :

    release => merge(
      try(local.helm_releases[release], {}),
      try(var.helm_releases_overrides[release], {})
    )

    if try(
      "true" == lookup(
        merge(
          try(local.helm_releases[release], {}),
          try(var.helm_releases_overrides[release], {})
        ),
        "enabled"
      ),
      true
    )
  }

  name       = each.key
  namespace  = lookup(each.value, "namespace", "default")
  repository = lookup(each.value, "repository", local.helm_stable)
  chart      = lookup(each.value, "chart", each.key)
  version    = lookup(each.value, "version", null)

  values = try(
    [
      templatefile(
        "${path.module}/values/${each.key}.yaml",
        {
          cluster_id         = var.cluster_id
          environment        = var.environment
          aws_region         = var.region
          enable_prometheus  = var.enable_prometheus
          enable_pod_monitor = var.enable_pod_monitor
        }
      )
    ],
    []
  )

  depends_on        = [kubernetes_namespace.core, helm_release.prometheus]
  dependency_update = true
}
