#!/usr/bin/env bash
set -euo pipefail

NAME_PREFIX="${NAME_PREFIX:-k8s}"
MASTERS="${MASTERS:-3}"
WORKERS="${WORKERS:-3}"
KUBECONFIG_PATH="${KUBECONFIG_PATH:-./kubeconfig}"

need() { command -v "$1" >/dev/null 2>&1 || { echo "missing: $1" >&2; exit 1; }; }
need multipass

MASTER0="${NAME_PREFIX}-master-0"

tmpdir="$(mktemp -d)"
cleanup() { rm -rf "$tmpdir"; }
trap cleanup EXIT

JOIN_SH="${tmpdir}/join.sh"
JOIN_CP_SH="${tmpdir}/join-controlplane.sh"

echo "[INFO] Fetch join scripts from ${MASTER0}"
multipass transfer "${MASTER0}":/home/ubuntu/join.sh "${JOIN_SH}"
multipass transfer "${MASTER0}":/home/ubuntu/join-controlplane.sh "${JOIN_CP_SH}"
chmod +x "${JOIN_SH}" "${JOIN_CP_SH}"

# Control-plane join (master-1 .. master-(MASTERS-1))
if [ "${MASTERS}" -gt 1 ]; then
  echo "[INFO] Join control-planes: 1..$((MASTERS - 1))"
  for ((i=1; i<MASTERS; i++)); do
    m="${NAME_PREFIX}-master-${i}"
    multipass transfer "${JOIN_CP_SH}" "${m}":/home/ubuntu/join-controlplane.sh
    # multipass exec "${m}" -- bash -lc "chmod +x /home/ubuntu/join-controlplane.sh && sudo bash /home/ubuntu/join-controlplane.sh"
    multipass exec "${m}" -- bash -lc "\
      if [ -f /etc/kubernetes/kubelet.conf ]; then \
        echo '[INFO] already joined; skip'; \
      else \
        chmod +x /home/ubuntu/join-controlplane.sh && sudo bash /home/ubuntu/join-controlplane.sh; \
      fi"
  done
fi

# Worker join (worker-0 .. worker-(WORKERS-1))
if [ "${WORKERS}" -gt 0 ]; then
  echo "[INFO] Join workers: 0..$((WORKERS - 1))"
  for ((i=0; i<WORKERS; i++)); do
    w="${NAME_PREFIX}-worker-${i}"
    multipass transfer "${JOIN_SH}" "${w}":/home/ubuntu/join.sh
    # multipass exec "${w}" -- bash -lc "chmod +x /home/ubuntu/join.sh && sudo bash /home/ubuntu/join.sh"
    multipass exec "${w}" -- bash -lc "\
      if [ -f /etc/kubernetes/kubelet.conf ]; then \
        echo '[INFO] already joined; skip'; \
      else \
        chmod +x /home/ubuntu/join.sh && sudo bash /home/ubuntu/join.sh; \
      fi"
  done
fi

# Pull kubeconfig to local path
echo "[INFO] Export kubeconfig from ${MASTER0} -> ${KUBECONFIG_PATH}"
multipass exec "${MASTER0}" -- bash -lc "\
  sudo mkdir -p /home/ubuntu/.kube && \
  sudo cp /etc/kubernetes/admin.conf /home/ubuntu/.kube/config && \
  sudo chown ubuntu:ubuntu /home/ubuntu/.kube/config"

mkdir -p "$(dirname "${KUBECONFIG_PATH}")" 2>/dev/null || true
multipass transfer "${MASTER0}":/home/ubuntu/.kube/config "${KUBECONFIG_PATH}"

echo "[OK] kubeconfig written: ${KUBECONFIG_PATH}"
echo "     export KUBECONFIG=${KUBECONFIG_PATH}"
