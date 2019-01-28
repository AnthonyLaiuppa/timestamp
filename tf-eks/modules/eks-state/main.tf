#
# EKS Cluster state
# * Token generator since this functionality isnt rolled cleanly into the provider yet
# * Provider to manage interacting with the cluster
# * Create namespace
# * Create service account
# * Apply the stateful set
# * Expose the endpoint via load balanced service

variable "cluster-name"{}
variable "aws_iam_role_demo_node"{}
variable "aws_eks_cluster_demo_endpoint"{}
variable "aws_eks_cluster_demo_cert_auth_0_data"{}

data "external" "aws_iam_authenticator" {
  program = ["sh", "-c", "aws-iam-authenticator token -i ${var.cluster-name} | jq -r -c .status"]
}

provider "kubernetes" {
  host                   = "${var.aws_eks_cluster_demo_endpoint}"
  cluster_ca_certificate = "${base64decode(var.aws_eks_cluster_demo_cert_auth_0_data)}"
  token                  = "${data.external.aws_iam_authenticator.result.token}"
  load_config_file       = false
}

resource "kubernetes_config_map" "aws_auth" {
  metadata {
    name      = "aws-auth"
    namespace = "kube-system"
  }

  data {
    mapRoles = <<YAML
- rolearn: ${var.aws_iam_role_demo_node}
  username: system:node:{{EC2PrivateDNSName}}
  groups:
    - system:bootstrappers
    - system:nodes
YAML
  }
}

resource "kubernetes_namespace" "timestamp" {
  metadata {
    annotations {
      name = "api"
    }

    labels {
      env = "prod"
    }

    name = "timestamp"
  }
}

resource "kubernetes_service_account" "api-server" {
  metadata {
    name      = "api-server"
    namespace = "timestamp"
  }
}


resource "kubernetes_service" "timestamp-api-service" {
  metadata {
    name = "api-server"
    namespace = "timestamp"
  }
  spec {
    type = "LoadBalancer"
    selector {
      name = "api-server"
    }
    port {
      name        = "http"
      port        = 80
      target_port = 8080
      protocol    ="TCP"
    }
}
}

resource "kubernetes_stateful_set" "api-server" {
  metadata {

    namespace        = "timestamp"

    annotations {
      SomeAnnotation = "api-server"
    }

    labels {
      k8s-app                           = "api-server"
      "kubernetes.io/cluster-service"   = "true"
      "addonmanager.kubernetes.io/mode" = "Reconcile"
      version                           = "v1"
    }

    name = "api-server"
  }

  spec {

    pod_management_policy  = "OrderedReady"
    replicas               = 3
    revision_history_limit = 3

    selector {
      match_labels {
        k8s-app = "api-server"
      }
    }

    service_name = "api-server"
    
    update_strategy {
      type = "RollingUpdate"

      rolling_update {
        partition = 0
      }
    }

    template {
      metadata {
        name = "api-server"
        labels {
          k8s-app = "api-server"
          name = "api-server"
        }

        annotations {}
      }

      spec {
        termination_grace_period_seconds = 10
        service_account_name = "api-server"

        container {
          name              = "api-endpoint"
          image             = "example/timestamp"
          image_pull_policy = "Always"


          volume_mount {
            name       = "api-server-logs"
            mount_path = "/var/api-server-logs"
            read_only  = false
          }

          port {
            container_port = 9090
          }

          resources {
            limits {
              cpu    = "1"
              memory = "512Mi"
            }

            requests {
              cpu    = "0.5"
              memory = "256Mi"
            }
          }


          readiness_probe {
            http_get {
              path = "/timestamp"
              port = 8080
            }

            initial_delay_seconds = 60
            timeout_seconds       = 5
            failure_threshold     = 12
          }

          liveness_probe {
            http_get {
              path = "/timestamp"
              port = 8080
            }

            initial_delay_seconds = 60
            timeout_seconds       = 5
            failure_threshold     = 12
          }
        }
      }
    }

    volume_claim_template {
      metadata {
        name = "api-server-logs"
      }

      spec {
        access_modes       = ["ReadWriteOnce"]
        //storage_class_name = "standard"

        resources {
          requests {
            storage = "1Gi"
          }
        }
      }
    }


   }

  provisioner "local-exec" {
    command = "echo 'Waiting on pods to come up' && sleep 180"
   }
  provisioner "local-exec" {
   command = "curl http://${kubernetes_service.timestamp-api-service.load_balancer_ingress.0.hostname}/timestamp"
  }
}

output "api_ep" {
  value = "${kubernetes_service.timestamp-api-service.load_balancer_ingress.0.hostname}"
  depends_on = [
    "kubernetes_service.timestamp-api-service"
  ]
}

