variable "kubeconfig_path" {
  description = "Path to the kubeconfig file"
  type        = string
  default     = "../01-cluster-setup/kubeconfig"
}

variable "app_name" {
  description = "Name of the application"
  type        = string
  default     = "sample-app"
}

variable "namespace" {
  description = "Kubernetes namespace for the application"
  type        = string
  default     = "devops-app"
}

variable "replica_count" {
  description = "Number of application replicas"
  type        = number
  default     = 3
}

variable "app_image" {
  description = "Container image for the application"
  type        = string
  default     = "nginx:latest"  # We'll build our own later
}

variable "app_port" {
  description = "Port the application runs on"
  type        = number
  default     = 5000
}

variable "service_port" {
  description = "Port for the Kubernetes service"
  type        = number
  default     = 80
}
