#!/usr/bin/env bash
set -euo pipefail

cmd="${1:-}"

usage() {
  cat <<'USAGE'
Usage: addons/manage.sh <install|uninstall|verify|hosts>

Commands:
  install   Install all addons
  uninstall Uninstall all addons
  verify    Verify addon status
  hosts     Re-generate hosts.generated (install must be done first)
USAGE
}

if [[ -z "$cmd" ]]; then
  usage
  exit 1
fi

case "$cmd" in
  install)
    bash "$(dirname "$0")/install.sh"
    ;;
  uninstall)
    bash "$(dirname "$0")/uninstall.sh"
    ;;
  verify)
    bash "$(dirname "$0")/verify.sh"
    ;;
  hosts)
    ONLY_HOSTS=1 bash "$(dirname "$0")/install.sh"
    ;;
  *)
    usage
    exit 1
    ;;
esac
