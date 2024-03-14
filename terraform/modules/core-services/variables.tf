#
# Declaring an Input Variable accepted by a module
#
variable region {
  type        = string
  default     = ""
  description = "The region to deploy the resources in."
}

variable environment {
  type        = string
  description = "The name of the current environment."
}

variable cluster_id {
  type        = string
  description = "The ID of the EKS cluster."
}

variable "helm_releases_overrides" {
  type        = map(map(string))
  description = "Use to override helm releases configuration"
  default     = {}
}
variable "enable_prometheus" {
  type        = bool
  default     = false
  description = "Enable or Disable Prometheus metrics for Keda"
}

variable "enable_pod_monitor" {
  type        = bool
  default     = true
  description = "Enables or Disables PodMonitor creation for the Prometheus Operator"
}