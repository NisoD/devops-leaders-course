output "namespace" {
  description = "Kubernetes namespace where the app is deployed"
  value       = kubernetes_namespace.app.metadata[0].name
}

output "app_name" {
  description = "Name of the deployed application"
  value       = var.app_name
}

output "service_name" {
  description = "Name of the Kubernetes service"
  value       = kubernetes_service.app.metadata[0].name
}

output "ingress_name" {
  description = "Name of the Kubernetes ingress"
  value       = kubernetes_ingress_v1.app.metadata[0].name
}

output "replica_count" {
  description = "Number of application replicas"
  value       = var.replica_count
}

output "app_url" {
  description = "Application URL (assuming localhost ingress)"
  value       = "http://localhost"
}

output "health_check_url" {
  description = "Health check endpoint URL"
  value       = "http://localhost/health"
}

output "metrics_url" {
  description = "Metrics endpoint URL"
  value       = "http://localhost/metrics"
}

output "kubectl_commands" {
  description = "Useful kubectl commands for this deployment"
  value = {
    get_pods     = "kubectl get pods -n ${kubernetes_namespace.app.metadata[0].name}"
    get_services = "kubectl get services -n ${kubernetes_namespace.app.metadata[0].name}"
    get_ingress  = "kubectl get ingress -n ${kubernetes_namespace.app.metadata[0].name}"
    logs         = "kubectl logs -l app=${var.app_name} -n ${kubernetes_namespace.app.metadata[0].name}"
    port_forward = "kubectl port-forward service/${kubernetes_service.app.metadata[0].name} 8080:80 -n ${kubernetes_namespace.app.metadata[0].name}"
  }
}
