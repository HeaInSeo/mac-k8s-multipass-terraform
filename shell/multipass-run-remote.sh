#!/usr/bin/env bash
set -euo pipefail

vm="${1:?vm required}"
local_script="${2:?local script required}"
remote_path="${3:-/home/ubuntu/remote.sh}"

if ! command -v multipass >/dev/null 2>&1; then
  echo "multipass not found" >&2
  exit 1
fi
if [ ! -f "$local_script" ]; then
  echo "local script not found: $local_script" >&2
  exit 1
fi

echo "[INFO] transfer $local_script -> ${vm}:${remote_path}"
multipass transfer "$local_script" "${vm}:${remote_path}"

echo "[INFO] exec on $vm: sudo bash $remote_path"
multipass exec "$vm" -- bash -lc "chmod +x '$remote_path' && sudo bash '$remote_path'"
echo "[OK] ran $local_script on $vm"
