locals {
  k8s_cloud_init_sha = filesha256("${path.module}/init/k8s.yaml")
  cluster_init_sha   = filesha256("${path.module}/shell/cluster-init.sh")
  join_all_sha       = filesha256("${path.module}/shell/join-all.sh")
  run_remote_sha     = filesha256("${path.module}/shell/multipass-run-remote.sh")
}

resource "null_resource" "masters" {
  count = var.masters

  # null_resource는 입력 추적이 약하므로 triggers로 변경 감지
  triggers = {
    name           = "${var.name_prefix}-master-${count.index}"
    image          = var.multipass_image
    mem            = var.master_memory
    cpus           = tostring(var.master_cpus)
    disk           = var.master_disk
    cloud_init_sha = local.k8s_cloud_init_sha
  }

  provisioner "local-exec" {
    command = <<EOT
set -e
bash shell/multipass-launch.sh "${self.triggers.name}" "${self.triggers.image}" "${self.triggers.mem}" "${self.triggers.disk}" "${self.triggers.cpus}" "init/k8s.yaml"
EOT
  }

  # masters에도 destroy 추가
  provisioner "local-exec" {
    when    = destroy
    command = <<EOT
bash shell/multipass-delete.sh "${self.triggers.name}" || true
EOT
  }
}

resource "null_resource" "workers" {
  depends_on = [null_resource.masters]
  count      = var.workers

  triggers = {
    name           = "${var.name_prefix}-worker-${count.index}"
    image          = var.multipass_image
    mem            = var.worker_memory
    cpus           = tostring(var.worker_cpus)
    disk           = var.worker_disk
    cloud_init_sha = local.k8s_cloud_init_sha
  }

  provisioner "local-exec" {
    command = <<EOT
set -e
bash shell/multipass-launch.sh "${self.triggers.name}" "${self.triggers.image}" "${self.triggers.mem}" "${self.triggers.disk}" "${self.triggers.cpus}" "init/k8s.yaml"
EOT
  }

  provisioner "local-exec" {
    when    = destroy
    command = <<EOT
set -e
bash shell/multipass-delete.sh "${self.triggers.name}"
EOT
  }
}

resource "null_resource" "init_cluster" {
  depends_on = [null_resource.masters]

  triggers = {
    script_sha   = local.cluster_init_sha
    run_sha      = local.run_remote_sha
    name_prefix  = var.name_prefix
    masters      = tostring(var.masters)
    master0_name = "${var.name_prefix}-master-0"
  }

  provisioner "local-exec" {
    command = <<EOT
set -e
bash shell/multipass-run-remote.sh "${var.name_prefix}-master-0" "shell/cluster-init.sh" "/home/ubuntu/cluster-init.sh"
EOT
  }
}

resource "null_resource" "join_all" {
  # init/workers 순서 정리: join은 "둘 다" 끝나야 수행
  depends_on = [null_resource.workers, null_resource.init_cluster]

  triggers = {
    script_sha  = local.join_all_sha
    name_prefix = var.name_prefix
    masters     = tostring(var.masters)
    workers     = tostring(var.workers)
    kubeconfig  = var.kubeconfig_path
  }

  provisioner "local-exec" {
    command = <<EOT
set -e
NAME_PREFIX="${var.name_prefix}" MASTERS="${var.masters}" WORKERS="${var.workers}" KUBECONFIG_PATH="${var.kubeconfig_path}" bash shell/join-all.sh
EOT
  }
}
