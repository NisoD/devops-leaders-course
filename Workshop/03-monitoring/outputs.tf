output "monitoring_namespace" {
  description = "Namespace where monitoring stack is deployed"
  value       = kubernetes_namespace.monitoring.metadata[0].name
}

output "prometheus_url" {
  description = "Prometheus server URL (cluster internal)"
  value       = "http://prometheus-server.${kubernetes_namespace.monitoring.metadata[0].name}.svc.cluster.local"
}

output "grafana_url" {
  description = "Grafana URL (cluster internal)"
  value       = "http://grafana.${kubernetes_namespace.monitoring.metadata[0].name}.svc.cluster.local"
}

output "loki_url" {
  description = "Loki URL (cluster internal)"
  value       = "http://loki.${kubernetes_namespace.monitoring.metadata[0].name}.svc.cluster.local:3100"
}

output "grafana_admin_password" {
  description = "Grafana admin password"
  value       = var.grafana_admin_password
  sensitive   = true
}

output "access_instructions" {
  description = "Instructions for accessing the monitoring stack"
  value = {
    grafana = {
      port_forward = "kubectl port-forward service/grafana 3000:80 -n ${kubernetes_namespace.monitoring.metadata[0].name}"
      url         = "http://localhost:3000"
      username    = "admin"
      password    = "Use: kubectl get secret grafana -o jsonpath='{.data.admin-password}' -n ${kubernetes_namespace.monitoring.metadata[0].name} | base64 -d"
    }
    prometheus = {
      port_forward = "kubectl port-forward service/prometheus-server 9090:80 -n ${kubernetes_namespace.monitoring.metadata[0].name}"
      url         = "http://localhost:9090"
    }
  }
}

output "helm_releases" {
  description = "Information about deployed Helm releases"
  value = {
    prometheus = {
      name      = helm_release.prometheus.name
      chart     = helm_release.prometheus.chart
      version   = helm_release.prometheus.version
      namespace = helm_release.prometheus.namespace
    }
    grafana = {
      name      = helm_release.grafana.name
      chart     = helm_release.grafana.chart
      version   = helm_release.grafana.version
      namespace = helm_release.grafana.namespace
    }
    loki = {
      name      = helm_release.loki.name
      chart     = helm_release.loki.chart
      version   = helm_release.loki.version
      namespace = helm_release.loki.namespace
    }
    alloy = {
      name      = helm_release.alloy.name
      chart     = helm_release.alloy.chart
      version   = helm_release.alloy.version
      namespace = helm_release.alloy.namespace
    }
  }
}

output "validation_commands" {
  description = "Commands to validate the monitoring stack"
  value = {
    check_pods     = "kubectl get pods -n ${kubernetes_namespace.monitoring.metadata[0].name}"
    check_services = "kubectl get services -n ${kubernetes_namespace.monitoring.metadata[0].name}"
    prometheus_targets = "kubectl port-forward service/prometheus-server 9090:80 -n ${kubernetes_namespace.monitoring.metadata[0].name} & sleep 2 && curl -s http://localhost:9090/api/v1/targets | jq '.data.activeTargets[] | {job: .labels.job, health: .health}'"
    grafana_health = "kubectl port-forward service/grafana 3000:80 -n ${kubernetes_namespace.monitoring.metadata[0].name} & sleep 2 && curl -s http://localhost:3000/api/health"
  }
}
