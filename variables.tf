variable "name_prefix" {
  description = "Multipass VM 이름 prefix (예: k8s-master-0 / k8s-worker-0)"
  type        = string
  default     = "k8s"
}

variable "multipass_image" {
  description = "Multipass에서 사용할 Ubuntu 이미지 버전"
  type        = string
  default     = "24.04"
}

variable "masters" {
  description = "Control Plane 노드 수"
  type        = number
  default     = 3
}

variable "workers" {
  description = "Worker 노드 수"
  type        = number
  default     = 3
}

variable "master_memory" {
  description = "Master 노드 메모리"
  type        = string
  default     = "4G"
}

variable "worker_memory" {
  description = "Worker 노드 메모리"
  type        = string
  default     = "4G"
}

variable "master_cpus" {
  description = "Master 노드 vCPU 수"
  type        = number
  default     = 2
}

variable "worker_cpus" {
  description = "Worker 노드 vCPU 수"
  type        = number
  default     = 2
}

variable "master_disk" {
  description = "Master 노드 디스크"
  type        = string
  default     = "40G"
}

variable "worker_disk" {
  description = "Worker 노드 디스크"
  type        = string
  default     = "50G"
}

variable "kubeconfig_path" {
  description = "로컬로 가져올 kubeconfig 파일 경로"
  type        = string
  default     = "./kubeconfig"
}
