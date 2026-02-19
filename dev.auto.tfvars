name_prefix     = "k8s"
masters         = 1
workers         = 0
master_memory   = "4G"
master_cpus     = 2
master_disk     = "20G"
kubeconfig_path = "./kubeconfig"
# 일단 에러날 수 있음. 이거 적용안됨.
recreate_on_diff = true
