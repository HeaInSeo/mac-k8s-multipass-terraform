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
  echo "[INFO] $name already exists; skip launch"
  exit 0
fi

echo "[INFO] launching $name (image=$image mem=$mem disk=$disk cpus=$cpus cloud-init=$cloud_init)"
multipass launch "$image" --name "$name" --mem "$mem" --disk "$disk" --cpus "$cpus" --cloud-init "$cloud_init"
echo "[OK] launched $name"
