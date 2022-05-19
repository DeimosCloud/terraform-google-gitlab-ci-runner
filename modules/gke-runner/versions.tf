terraform {
  required_version = ">= 0.13"
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = ">= 3.40"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = ">= 1.12"
    }
    helm = {
      source  = "hashicorp/helm"
      version = ">= 1.2"
    }
  }
}
