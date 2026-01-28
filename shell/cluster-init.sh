#!/usr/bin/env bash
set -euo pipefail

MASTER_IP="$(hostname -I | awk '{print $1}')"

sudo kubeadm init \
  --control-plane-endpoint "${MASTER_IP}:6443" \
  --upload-certs \
  --pod-network-cidr=10.244.0.0/16

mkdir -p "$HOME/.kube"
sudo cp /etc/kubernetes/admin.conf "$HOME/.kube/config"
sudo chown "$(id -u)":"$(id -g)" "$HOME/.kube/config"

# flannel
kubectl apply -f https://raw.githubusercontent.com/coreos/flannel/master/Documentation/kube-flannel.yml

# worker join script
JOIN_CMD="$(sudo kubeadm token create --print-join-command)"
echo "sudo ${JOIN_CMD}" | sudo tee /home/ubuntu/join.sh >/dev/null
sudo chmod +x /home/ubuntu/join.sh

# control-plane join script
CERT_KEY="$(sudo kubeadm init phase upload-certs --upload-certs | tail -n 1)"
JOIN_CP_CMD="$(sudo kubeadm token create --print-join-command --certificate-key "${CERT_KEY}")"
echo "sudo ${JOIN_CP_CMD}" | sudo tee /home/ubuntu/join-controlplane.sh >/dev/null
sudo chmod +x /home/ubuntu/join-controlplane.sh
