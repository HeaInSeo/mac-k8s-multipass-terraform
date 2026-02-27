#!/usr/bin/env bash
set -euo pipefail

TOOL="${TOOL:-tofu}"
KUBECONFIG_PATH="${KUBECONFIG_PATH:-./kubeconfig}"

usage() {
  cat <<'USAGE'
Usage: scripts/k8s-tool.sh <up|down|status|clean|addons-install|addons-uninstall|addons-verify|addons-hosts>

Commands:
  up               Create VMs and bootstrap Kubernetes (tofu apply)
  down             Destroy VMs and resources (tofu destroy)
  status           Show cluster or VM status
  clean            Remove local state files (requires FORCE=1)
  addons-install   Install addons (addons/manage.sh install)
  addons-uninstall Uninstall addons (addons/manage.sh uninstall)
  addons-verify    Verify addons (addons/manage.sh verify)
  addons-hosts     Re-generate hosts.generated only

Env:
  TOOL=tofu|terraform
  KUBECONFIG_PATH=./kubeconfig
  FORCE=1 (required for clean)
USAGE
}

need_cmd() {
  command -v "$1" >/dev/null 2>&1 || { echo "missing: $1" >&2; exit 1; }
}

cmd="${1:-}"
if [[ -z "$cmd" ]]; then
  usage
  exit 1
fi

case "$cmd" in
  up)
    need_cmd "$TOOL"
    "$TOOL" init
    "$TOOL" plan
    "$TOOL" apply -auto-approve
    ;;
  down)
    need_cmd "$TOOL"
    "$TOOL" destroy -auto-approve
    ;;
  status)
    if [[ -f "$KUBECONFIG_PATH" ]] && command -v kubectl >/dev/null 2>&1; then
      export KUBECONFIG="$KUBECONFIG_PATH"
      kubectl get nodes -o wide || true
    else
      if command -v multipass >/dev/null 2>&1; then
        multipass list || true
      else
        echo "kubectl or multipass not found" >&2
        exit 1
      fi
    fi
    ;;
  clean)
    if [[ "${FORCE:-0}" != "1" ]]; then
      echo "FORCE=1 is required to clean local state files" >&2
      exit 1
    fi
    rm -rf .terraform .terraform.lock.hcl terraform.tfstate* tofu.tfstate* tofu.tfstate.d
    rm -f "$KUBECONFIG_PATH"
    ;;
  addons-install)
    bash addons/manage.sh install
    ;;
  addons-uninstall)
    bash addons/manage.sh uninstall
    ;;
  addons-verify)
    bash addons/manage.sh verify
    ;;
  addons-hosts)
    bash addons/manage.sh hosts
    ;;
  *)
    usage
    exit 1
    ;;
esac
