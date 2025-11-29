# Configure Terraform Provider
terraform {
  required_providers {
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "2.29.0"
    }
  }
}

provider "kubernetes" {
  config_path = "~/.kube/config"
}

# Create Namespace
resource "kubernetes_namespace" "milestone3" {
  metadata {
    name = var.namespace
  }
}

# Create PVC
resource "kubernetes_persistent_volume_claim" "pvc" {
  metadata {
    name      = "sidecar-shared-pvc"
    namespace = var.namespace
  }

  spec {
    access_modes = ["ReadWriteOnce"]

    resources {
      requests = {
        storage = "500Mi"
      }
    }

    storage_class_name = "standard"
  }
}

# Create Deployment
resource "kubernetes_deployment" "nginx_sidecar" {
  metadata {
    name      = "nginx-sidecar-deployment"
    namespace = var.namespace
  }

  spec {
    replicas = 2

    selector {
      match_labels = {
        app = "nginx-sidecar"
      }
    }

    template {
      metadata {
        labels = {
          app = "nginx-sidecar"
        }
      }

      spec {
        container {
          name  = "nginx"
          image = "nginx:latest"

          port {
            container_port = 80
          }

          volume_mount {
            mount_path = "/usr/share/nginx/html"
            name       = "shared-data"
          }
        }

        container {
          name    = "sidecar"
          image   = "busybox"
          command = ["sh", "-c"]
          args = [
            "echo 'Hello from sidecar via PVC' > /data/index.html && sleep 3600"
          ]

          volume_mount {
            mount_path = "/data"
            name       = "shared-data"
          }
        }

        volume {
          name = "shared-data"

          persistent_volume_claim {
            claim_name = kubernetes_persistent_volume_claim.pvc.metadata[0].name
          }
        }
      }
    }
  }
}

# Create Service
resource "kubernetes_service" "nginx_service" {
  metadata {
    name      = "nginx-sidecar-service"
    namespace = var.namespace
  }

  spec {
    selector = {
      app = "nginx-sidecar"
    }

    port {
      port        = 80
      target_port = 80
      node_port   = var.nodeport
    }

    type = "NodePort"
  }
}
