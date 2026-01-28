
terraform {
  # required_version = ">= 1.11.3"
  # OpenTofu/Terraform 모두에서 동작하는 현실적인 최소 버전(대부분의 프로젝트에서 무난)
  required_version = ">= 1.6"

  required_providers {
    null = {
      source  = "hashicorp/null"
      version = "~> 3.2"
    }
  }
}
