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

echo "[INFO] stopping $name (best-effort)"
multipass stop "$name" >/dev/null 2>&1 || true

echo "[INFO] deleting $name"
multipass delete --purge "$name"

# (선택) purge가 비동기처럼 지연되는 경우 대비: 사라질 때까지 잠깐 대기
for _ in {1..10}; do
  if ! multipass info "$name" >/dev/null 2>&1; then
    echo "[OK] deleted $name"
    exit 0
  fi
  sleep 1
done

# 여기까지 왔으면 "삭제 명령은 했는데 아직 남아 보임"
echo "[WARN] delete requested but $name still appears to exist (might be cleaning up)."
exit 0
