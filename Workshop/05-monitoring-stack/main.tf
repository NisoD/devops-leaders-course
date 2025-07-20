# Configure providers
provider "kubernetes" {
  config_path = var.kubeconfig_path
}

provider "helm" {
  kubernetes {
    config_path = var.kubeconfig_path
  }
}

# Create monitoring namespace
resource "kubernetes_namespace" "monitoring" {
  metadata {
    name = var.monitoring_namespace
    
    labels = {
      name        = var.monitoring_namespace
      environment = "workshop"
      managed-by  = "terraform"
    }
  }
}

# Deploy Prometheus using Helm
resource "helm_release" "prometheus" {
  name       = "prometheus"
  repository = "https://prometheus-community.github.io/helm-charts"
  chart      = "prometheus"
  namespace  = kubernetes_namespace.monitoring.metadata[0].name
  version    = "25.8.0"

  values = [
    yamlencode({
      server = {
        retention = var.prometheus_retention
        
        persistentVolume = {
          enabled = true
          size    = var.prometheus_storage_size
        }
        
        service = {
          type = "ClusterIP"
        }
        
        # Enable service discovery
        config = {
          global = {
            scrape_interval     = "15s"
            evaluation_interval = "15s"
          }
          
          scrape_configs = [
            {
              job_name = "kubernetes-pods"
              kubernetes_sd_configs = [
                {
                  role = "pod"
                }
              ]
              relabel_configs = [
                {
                  source_labels = ["__meta_kubernetes_pod_annotation_prometheus_io_scrape"]
                  action        = "keep"
                  regex         = "true"
                },
                {
                  source_labels = ["__meta_kubernetes_pod_annotation_prometheus_io_path"]
                  action        = "replace"
                  target_label  = "__metrics_path__"
                  regex         = "(.+)"
                },
                {
                  source_labels = ["__address__", "__meta_kubernetes_pod_annotation_prometheus_io_port"]
                  action        = "replace"
                  regex         = "([^:]+)(?::\\d+)?;(\\d+)"
                  replacement   = "$1:$2"
                  target_label  = "__address__"
                }
              ]
            },
            {
              job_name = "kubernetes-services"
              kubernetes_sd_configs = [
                {
                  role = "service"
                }
              ]
              relabel_configs = [
                {
                  source_labels = ["__meta_kubernetes_service_annotation_prometheus_io_scrape"]
                  action        = "keep"
                  regex         = "true"
                }
              ]
            }
          ]
        }
      }
      
      alertmanager = {
        enabled = false  # Simplified for workshop
      }
      
      nodeExporter = {
        enabled = true
      }
      
      kubeStateMetrics = {
        enabled = true
      }
      
      pushgateway = {
        enabled = false
      }
    })
  ]

  depends_on = [kubernetes_namespace.monitoring]
}

# Deploy Loki using Helm
resource "helm_release" "loki" {
  name       = "loki"
  repository = "https://grafana.github.io/helm-charts"
  chart      = "loki"
  namespace  = kubernetes_namespace.monitoring.metadata[0].name
  version    = "5.41.4"

  values = [
    yamlencode({
      # Use simple scalable mode
      deploymentMode = "SimpleScalable"
      
      loki = {
        auth_enabled = false
        
        commonConfig = {
          replication_factor = 1
        }
        
        storage = {
          type = "filesystem"
        }
        
        schemaConfig = {
          configs = [
            {
              from         = "2020-10-24"
              store        = "boltdb-shipper"
              object_store = "filesystem"
              schema       = "v11"
              index = {
                prefix = "index_"
                period = "24h"
              }
            }
          ]
        }
        
        limits_config = {
          retention_period = var.loki_retention
        }
      }
      
      singleBinary = {
        replicas = 1
        
        persistence = {
          enabled = true
          size    = var.loki_storage_size
        }
      }
      
      monitoring = {
        selfMonitoring = {
          enabled = true
        }
        
        lokiCanary = {
          enabled = false
        }
      }
      
      test = {
        enabled = false
      }
    })
  ]

  depends_on = [kubernetes_namespace.monitoring]
}

# Deploy Grafana using Helm
resource "helm_release" "grafana" {
  name       = "grafana"
  repository = "https://grafana.github.io/helm-charts"
  chart      = "grafana"
  namespace  = kubernetes_namespace.monitoring.metadata[0].name
  version    = "7.0.9"

  values = [
    yamlencode({
      adminPassword = var.grafana_admin_password
      
      persistence = {
        enabled = true
        size    = "1Gi"
      }
      
      service = {
        type = "ClusterIP"
        port = 80
      }
      
      ingress = {
        enabled = var.enable_ingress
      }
      
      datasources = {
        "datasources.yaml" = {
          apiVersion = 1
          datasources = [
            {
              name      = "Prometheus"
              type      = "prometheus"
              url       = "http://prometheus-server:80"
              access    = "proxy"
              isDefault = true
              uid       = "prometheus"
            },
            {
              name   = "Loki"
              type   = "loki"
              url    = "http://loki:3100"
              access = "proxy"
              uid    = "loki"
            }
          ]
        }
      }
      
      dashboardProviders = {
        "dashboardproviders.yaml" = {
          apiVersion = 1
          providers = [
            {
              name      = "default"
              orgId     = 1
              folder    = ""
              type      = "file"
              disableDeletion = false
              editable       = true
              options = {
                path = "/var/lib/grafana/dashboards/default"
              }
            }
          ]
        }
      }
      
      dashboards = {
        default = {
          "kubernetes-cluster" = {
            gnetId    = 315
            revision  = 3
            datasource = "Prometheus"
          }
          "node-exporter" = {
            gnetId    = 1860
            revision  = 31
            datasource = "Prometheus"
          }
        }
      }
      
      sidecar = {
        dashboards = {
          enabled = true
        }
      }
    })
  ]

  depends_on = [
    kubernetes_namespace.monitoring,
    helm_release.prometheus,
    helm_release.loki
  ]
}

# Deploy Grafana Alloy using Helm
resource "helm_release" "alloy" {
  name       = "alloy"
  repository = "https://grafana.github.io/helm-charts"
  chart      = "alloy"
  namespace  = kubernetes_namespace.monitoring.metadata[0].name
  version    = "0.3.0"
  
  timeout = 600 # 10 minutes timeout

  values = [
    yamlencode({
      # Disable config reloader that causes image pull issues
      configReloader = {
        enabled = false
      }
      
      alloy = {
        configMap = {
          content = file("${path.module}/alloy-config.alloy")
        }
      }
      
      controller = {
        type = "daemonset"
      }
      
      serviceAccount = {
        create = true
      }
      
      rbac = {
        create = true
      }
      
      # Resources to prevent resource issues
      resources = {
        requests = {
          memory = "128Mi"
          cpu    = "100m"
        }
        limits = {
          memory = "256Mi"
          cpu    = "200m"
        }
      }
    })
  ]

  depends_on = [
    kubernetes_namespace.monitoring,
    helm_release.prometheus,
    helm_release.loki
  ]
}
