variable "name_prefix" {
  description = "Multipass VM 이름 prefix (예: k8s-master-0 / k8s-worker-0)"
  type        = string
  default     = "k8s"
  validation {
    condition     = can(regex("^[a-zA-Z0-9](?:[a-zA-Z0-9-]*[a-zA-Z0-9])?$", var.name_prefix))
    error_message = "name_prefix must contain only alphanumeric or '-', and must not start/end with '-'"
  }
}

variable "multipass_image" {
  description = "Multipass에서 사용할 Ubuntu 이미지 버전"
  type        = string
  default     = "24.04"
  validation {
    condition     = length(trimspace(var.multipass_image)) > 0
    error_message = "multipass_image must not be empty"
  }
}

variable "masters" {
  description = "Control Plane 노드 수"
  type        = number
  default     = 3
  validation {
    condition     = var.masters >= 1 && floor(var.masters) == var.masters
    error_message = "masters must be an integer (no decimals) and >= 1"
  }
}

variable "workers" {
  description = "Worker 노드 수"
  type        = number
  default     = 3
  validation {
    condition     = var.workers >= 0 && floor(var.workers) == var.workers
    error_message = "workers must be an integer (no decimals) and >= 0"
  }
}

variable "master_memory" {
  description = "Master 노드 메모리"
  type        = string
  default     = "4G"
  # 0G / 0M 금지: 반드시 1 이상
  validation {
    condition     = can(regex("^[1-9][0-9]*[MG]$", var.master_memory))
    error_message = "master_memory must look like 4G or 4096M (must be > 0)"
  }
}

variable "worker_memory" {
  description = "Worker 노드 메모리"
  type        = string
  default     = "4G"
  validation {
    condition     = can(regex("^[1-9][0-9]*[MG]$", var.worker_memory))
    error_message = "worker_memory must look like 4G or 4096M (must be > 0)"
  }
}

variable "master_cpus" {
  description = "Master 노드 vCPU 수"
  type        = number
  default     = 2
  validation {
    condition     = var.master_cpus >= 1 && floor(var.master_cpus) == var.master_cpus
    error_message = "master_cpus must be an integer (no decimals) and >= 1"
  }
}

variable "worker_cpus" {
  description = "Worker 노드 vCPU 수"
  type        = number
  default     = 2
  validation {
    condition     = var.worker_cpus >= 1 && floor(var.worker_cpus) == var.worker_cpus
    error_message = "worker_cpus must be an integer (no decimals) and >= 1"
  }

}

variable "master_disk" {
  description = "Master 노드 디스크"
  type        = string
  default     = "40G"
  validation {
    condition     = can(regex("^[1-9][0-9]*[MG]$", var.master_disk))
    error_message = "master_disk must look like 40G or 51200M (must be > 0)"
  }
}

variable "worker_disk" {
  description = "Worker 노드 디스크"
  type        = string
  default     = "50G"
  validation {
    condition     = can(regex("^[1-9][0-9]*[MG]$", var.worker_disk))
    error_message = "worker_disk must look like 50G or 51200M (must be > 0)"
  }
}

variable "kubeconfig_path" {
  description = "로컬로 가져올 kubeconfig 파일 경로"
  type        = string
  default     = "./kubeconfig"
  validation {
    condition     = length(trimspace(var.kubeconfig_path)) > 0
    error_message = "kubeconfig_path must not be empty"
  }
}

variable "recreate_on_diff" {
  description = "VM이 이미 존재할 때 스펙(mem/cpu/disk 등)이 다르면 삭제 후 재생성할지 여부"
  type        = bool
  default     = false
}