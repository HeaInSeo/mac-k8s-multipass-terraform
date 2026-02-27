#!/usr/bin/env bash
set -euo pipefail

if [[ "${FORCE:-0}" != "1" ]]; then
  echo "FORCE=1 is required to proceed" >&2
  exit 1
fi

say() { echo "$*"; }

say "=== Remove Multipass (snap) ==="
if command -v snap >/dev/null 2>&1; then
  sudo snap remove multipass || true
  sudo snap remove kubectl || true
  sudo snap remove helm || true
  sudo systemctl disable --now snapd.socket || true
  sudo dnf -y remove snapd || true
  sudo rm -rf /var/lib/snapd /var/cache/snapd || true
fi

say "=== Remove OpenTofu ==="
if command -v tofu >/dev/null 2>&1; then
  sudo dnf -y remove tofu || true
fi

say "=== Remove leftover files ==="
rm -rf .terraform .terraform.lock.hcl terraform.tfstate* tofu.tfstate* tofu.tfstate.d kubeconfig || true

say "Cleanup completed"
