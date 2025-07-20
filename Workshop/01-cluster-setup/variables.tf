variable "cluster_name" {
  description = "Name of the Kind cluster"
  type        = string
  default     = "devops-workshop"
}

variable "kubernetes_version" {
  description = "Kubernetes version for the cluster"
  type        = string
  default     = "v1.28.0"
}

variable "worker_nodes" {
  description = "Number of worker nodes"
  type        = number
  default     = 2
}

variable "kubeconfig_path" {
  description = "Path to save the kubeconfig file"
  type        = string
  default     = "./kubeconfig"
}
