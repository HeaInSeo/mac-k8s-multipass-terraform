#!/usr/bin/env bash
set -euo pipefail

name="${1:?name required}"

if ! command -v multipass >/dev/null 2>&1; then
  echo "multipass not found" >&2
  exit 1
fi

if ! multipass info "$name" >/dev/null 2>&1; then
  echo "[INFO] $name does not exist; skip delete"
  exit 0
fi

echo "[INFO] deleting $name"
multipass delete --purge "$name"
echo "[OK] deleted $name"
