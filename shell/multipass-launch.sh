#!/usr/bin/env bash
set -euo pipefail

name="${1:?name required}"
image="${2:?image required}"
mem="${3:?mem required}"
disk="${4:?disk required}"
cpus="${5:?cpus required}"
cloud_init="${6:?cloud-init path required}"

if ! command -v multipass >/dev/null 2>&1; then
  echo "multipass not found" >&2
  exit 1
fi

if multipass info "$name" >/dev/null 2>&1; then
  # VM이 이미 존재하면 새로 만들지 않고, cloud-init(패키지 설치/설정)이 끝났는지만 확인/대기한다.
  # (기존 VM이 아직 초기화 중일 수 있어서, 다음 단계가 너무 빨리 실행되면 실패할 수 있음)
  echo "[INFO] $name already exists; ensure cloud-init finished"
  multipass exec "$name" -- bash -lc 'command -v cloud-init >/dev/null && sudo cloud-init status --wait || true'
  exit 0
fi

echo "[INFO] launching $name (image=$image mem=$mem disk=$disk cpus=$cpus cloud-init=$cloud_init)"
multipass launch "$image" --name "$name" --mem "$mem" --disk "$disk" --cpus "$cpus" --cloud-init "$cloud_init"
# VM 첫 부팅 시 cloud-init(패키지 설치/설정 적용)이 끝날 때까지 기다려서,
# 다음 단계(kubeadm init/join 등)가 너무 빨리 실행되어 실패하는 것을 방지한다.
echo "[INFO] waiting for cloud-init to finish on $name"
multipass exec "$name" -- bash -lc 'command -v cloud-init >/dev/null && sudo cloud-init status --wait || true'
echo "[OK] launched $name"
