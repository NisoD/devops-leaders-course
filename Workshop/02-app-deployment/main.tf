# Configure Kubernetes provider
provider "kubernetes" {
  config_path = var.kubeconfig_path
}

# Get Docker image hash to detect changes
data "external" "docker_image_hash" {
  program = ["bash", "-c", "docker inspect --format='{{.Id}}' devops-sample-app:latest 2>/dev/null | jq -n --arg hash \"$(cat)\" '{hash: $hash}' || echo '{\"hash\": \"not-found\"}'"]
}

# Load Docker image into Kind cluster
resource "null_resource" "load_image" {
  # Trigger when image hash changes
  triggers = {
    image_hash = data.external.docker_image_hash.result.hash
  }

  provisioner "local-exec" {
    command = "kind load docker-image devops-sample-app:latest --name devops-workshop"
  }
  
  # Ensure this runs before the deployment
  lifecycle {
    create_before_destroy = true
  }
}

# Create namespace
resource "kubernetes_namespace" "app" {
  metadata {
    name = var.namespace
    
    labels = {
      name        = var.namespace
      environment = "workshop"
      managed-by  = "terraform"
    }
  }
}

# Create deployment
resource "kubernetes_deployment" "app" {
  depends_on = [null_resource.load_image]
  
  metadata {
    name      = var.app_name
    namespace = kubernetes_namespace.app.metadata[0].name
    
    labels = {
      app         = var.app_name
      environment = "workshop"
      managed-by  = "terraform"
    }
  }

  spec {
    replicas = var.replica_count

    selector {
      match_labels = {
        app = var.app_name
      }
    }

    template {
      metadata {
        labels = {
          app         = var.app_name
          environment = "workshop"
        }
        
        annotations = {
          "prometheus.io/scrape" = "true"
          "prometheus.io/port"   = "5000"
          "prometheus.io/path"   = "/metrics"
          "image/hash"          = data.external.docker_image_hash.result.hash
        }
      }

      spec {
        container {
          name              = var.app_name
          image             = "devops-sample-app:latest"
          image_pull_policy = "Never"  # Use local image, don't try to pull from registry

          port {
            container_port = var.app_port
            name          = "http"
          }

          # Health checks
          liveness_probe {
            http_get {
              path = "/health"
              port = var.app_port
            }
            initial_delay_seconds = 30
            period_seconds        = 10
            timeout_seconds       = 5
            failure_threshold     = 3
          }

          readiness_probe {
            http_get {
              path = "/ready"
              port = var.app_port
            }
            initial_delay_seconds = 5
            period_seconds        = 5
            timeout_seconds       = 3
            failure_threshold     = 3
          }

          # Resource limits
          resources {
            limits = {
              cpu    = "200m"
              memory = "256Mi"
            }
            requests = {
              cpu    = "100m"
              memory = "128Mi"
            }
          }

          # Environment variables
          env {
            name  = "APP_NAME"
            value = var.app_name
          }
          
          env {
            name  = "ENVIRONMENT"
            value = "workshop"
          }
        }
        
        # Security context
        security_context {
          run_as_non_root = true
          run_as_user     = 1000
        }
      }
    }
  }
}

# Create service
resource "kubernetes_service" "app" {
  metadata {
    name      = "${var.app_name}-service"
    namespace = kubernetes_namespace.app.metadata[0].name
    
    labels = {
      app         = var.app_name
      environment = "workshop"
      managed-by  = "terraform"
    }
    
    annotations = {
      "prometheus.io/scrape" = "true"
      "prometheus.io/port"   = "80"
      "prometheus.io/path"   = "/metrics"
    }
  }

  spec {
    selector = {
      app = var.app_name
    }

    port {
      name        = "http"
      port        = var.service_port
      target_port = var.app_port
      protocol    = "TCP"
    }

    type = "ClusterIP"
  }
}

# Create ingress (using nginx ingress controller)
resource "kubernetes_ingress_v1" "app" {
  metadata {
    name      = "${var.app_name}-ingress"
    namespace = kubernetes_namespace.app.metadata[0].name
    
    labels = {
      app         = var.app_name
      environment = "workshop"
      managed-by  = "terraform"
    }
    
    annotations = {
      "kubernetes.io/ingress.class"                = "nginx"
      "nginx.ingress.kubernetes.io/rewrite-target" = "/"
    }
  }

  spec {
    rule {
      http {
        path {
          path      = "/"
          path_type = "Prefix"
          
          backend {
            service {
              name = kubernetes_service.app.metadata[0].name
              port {
                number = var.service_port
              }
            }
          }
        }
      }
    }
  }
}
