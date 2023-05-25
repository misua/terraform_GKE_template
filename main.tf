provider "aws" {
  region = "us-east-1"
}

provider "kubernetes" {
  host = "https://api.eks.us-east-1.amazonaws.com"
  cluster_ca_certificate = file("./kubeconfig/ca.crt")
  client_certificate = file("./kubeconfig/client.crt")
  client_key = file("./kubeconfig/client.key")
}

resource "aws_eks_cluster" "default" {
  name = "my-eks-cluster"
}

resource "aws_eks_node_group" "default" {
  name = "my-eks-node-group"
  node_type = "t2.micro"
  desired_capacity = 3
}

resource "kubernetes_namespace" "default" {
  name = "default"
}

resource "kubernetes_deployment" "default" {
  name = "my-deployment"
  namespace = kubernetes_namespace.default.name
  replicas = 3
  selector {
    match_labels = {
      app = "my-app"
    }
  }
  template {
    metadata {
      labels = {
        app = "my-app"
      }
    }
    spec {
      containers {
        name = "my-container"
        image = "nginx"
        ports {
          container_port = 80
        }
      }
    }
  }
}

resource "kubernetes_service" "default" {
  name = "my-service"
  namespace = kubernetes_namespace.default.name
  type = "LoadBalancer"
  selector = {
    app = "my-app"
  }
  ports {
    port = 80
    target_port = 80
  }
}

resource "kubernetes_stateful_set" "postgresql" {
  name = "postgresql"
  namespace = kubernetes_namespace.default.name
  replicas = 2
  selector {
    match_labels = {
      app = "postgresql"
    }
  }
  template {
    metadata {
      labels = {
        app = "postgresql"
      }
    }
    spec {
      containers {
        name = "postgresql"
        image = "postgres:12"
        ports {
          container_port = 5432
        }
        volumeMounts {
          mountPath = "/var/lib/postgresql/data"
          name = "postgres-pv"
        }
      }
      volumes {
        name = "postgres-pv"
        persistentVolumeClaim {
          claimName = "postgres-pvc"
        }
      }
    }
  }
}

resource "kubernetes_persistent_volume_claim" "postgres-pvc" {
  name = "postgres-pvc"
  accessModes = ["ReadWriteOnce"]
  storageClassName = "standard"
  resources {
    requests {
      storage = "1Gi"
    }
  }
}
