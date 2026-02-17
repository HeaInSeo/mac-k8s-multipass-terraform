#!/usr/bin/env bash
set -euo pipefail

MASTER_IP="$(hostname -I | awk '{print $1}')"
if [ -f /etc/kubernetes/admin.conf ]; then
  echo "[INFO] kubeadm already initialized; skip init"
else
  sudo kubeadm init \
    --control-plane-endpoint "${MASTER_IP}:6443" \
    --upload-certs \
    --pod-network-cidr=10.244.0.0/16
fi

mkdir -p "$HOME/.kube"
sudo cp /etc/kubernetes/admin.conf "$HOME/.kube/config"
sudo chown "$(id -u)":"$(id -g)" "$HOME/.kube/config"

# flannel 찾아보자.
# kubectl apply -f https://raw.githubusercontent.com/coreos/flannel/master/Documentation/kube-flannel.yml
# 향후 버전은 적용가능한 버전으로 맞추어야 한다.
kubectl apply -f https://raw.githubusercontent.com/flannel-io/flannel/v0.26.0/Documentation/kube-flannel.yml
kubectl -n kube-flannel rollout status ds/kube-flannel-ds --timeout=180s || true
# 단일 노드(dev)에서만 컨트롤플레인에 워크로드 스케줄 허용
if [[ "${ALLOW_SCHEDULE_ON_CP:-0}" == "1" ]]; then
  kubectl taint nodes --all node-role.kubernetes.io/control-plane- || true
fi
kubectl get nodes >/dev/null 2>&1 || echo "[WARN] kubectl not ready yet"

# worker join script
JOIN_CMD="$(sudo kubeadm token create --print-join-command)"
echo "sudo ${JOIN_CMD}" | sudo tee /home/ubuntu/join.sh >/dev/null
sudo chmod +x /home/ubuntu/join.sh

# control-plane join script
CERT_KEY="$(sudo kubeadm init phase upload-certs --upload-certs | tail -n 1)"
JOIN_CP_CMD="$(sudo kubeadm token create --print-join-command --certificate-key "${CERT_KEY}")"
echo "sudo ${JOIN_CP_CMD}" | sudo tee /home/ubuntu/join-controlplane.sh >/dev/null
sudo chmod +x /home/ubuntu/join-controlplane.sh
