name_prefix     = "k8s"
masters         = 1
workers         = 0
master_memory   = "4G"
master_cpus     = 2
master_disk     = "20G"
kubeconfig_path = "./kubeconfig"
recreate_on_diff = true

# Rocky 8 기본 설정
multipass_image = "rocky-8"
vm_user         = "rocky"
