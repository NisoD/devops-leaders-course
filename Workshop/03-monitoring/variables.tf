variable "kubeconfig_path" {
  description = "Path to the kubeconfig file"
  type        = string
  default     = "../01-cluster-setup/kubeconfig"
}

variable "monitoring_namespace" {
  description = "Namespace for monitoring stack"
  type        = string
  default     = "monitoring"
}

variable "prometheus_retention" {
  description = "Prometheus data retention period"
  type        = string
  default     = "15d"
}

variable "prometheus_storage_size" {
  description = "Storage size for Prometheus"
  type        = string
  default     = "10Gi"
}

variable "loki_retention" {
  description = "Loki data retention period"
  type        = string
  default     = "168h"  # 7 days
}

variable "loki_storage_size" {
  description = "Storage size for Loki"
  type        = string
  default     = "5Gi"
}

variable "grafana_admin_password" {
  description = "Admin password for Grafana"
  type        = string
  default     = "admin123"
  sensitive   = true
}

variable "enable_ingress" {
  description = "Enable ingress for Grafana"
  type        = bool
  default     = false
}
