output "cluster_name" {
  description = "Name of the created Kind cluster"
  value       = kind_cluster.default.name
}

output "kubeconfig_path" {
  description = "Path to the kubeconfig file"
  value       = local_file.kubeconfig.filename
}

output "cluster_endpoint" {
  description = "Kubernetes cluster endpoint"
  value       = kind_cluster.default.endpoint
}

output "cluster_context" {
  description = "Kubectl context name"
  value       = "kind-${kind_cluster.default.name}"
}

output "cluster_nodes" {
  description = "Number of nodes in the cluster"
  value       = 1 + var.worker_nodes
}

output "kubectl_command" {
  description = "Command to use kubectl with this cluster"
  value       = "kubectl --kubeconfig=${local_file.kubeconfig.filename}"
}
