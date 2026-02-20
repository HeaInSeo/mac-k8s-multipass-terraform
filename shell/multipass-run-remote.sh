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

echo "[INFO] transfer $local_script -> ${vm}:${remote_path} via stdin"
< "$local_script" multipass exec "$vm" -- sudo bash -c "cat > '$remote_path'"

echo "[INFO] exec on $vm: sudo bash $remote_path"
# multipass exec "$vm" -- bash -lc "sudo chmod +x '$remote_path' && sudo bash '$remote_path'"
multipass exec "$vm" -- bash -lc "sudo chmod +x '$remote_path' && sudo ALLOW_SCHEDULE_ON_CP=1 bash '$remote_path'"
echo "[OK] ran $local_script on $vm"
