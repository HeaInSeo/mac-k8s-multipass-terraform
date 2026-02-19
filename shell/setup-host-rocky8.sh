#!/usr/bin/env bash
set -euo pipefail

need_cmd() { command -v "$1" >/dev/null 2>&1; }
say()  { echo "$*"; }
ok()   { echo "OK: $*"; }
warn() { echo "WARN: $*"; }
die()  { echo "ERROR: $*" >&2; exit 1; }

require_linux() {
  [ -f /etc/os-release ] || die "Cannot detect OS (/etc/os-release missing)."
  # shellcheck disable=SC1091
  . /etc/os-release
  ok "Detected OS: ${PRETTY_NAME:-unknown} (ID=${ID:-unknown})"
}

ensure_dnf_basics() {
  say "=== [1] Install basic packages (dnf) ==="
  sudo dnf -y install \
    ca-certificates \
    curl \
    git \
    gnupg2 \
    unzip \
    jq
  ok "Basic packages installed (curl/git/gnupg2/jq, etc.)"
}

ensure_python3() {
  say "=== [2] Install Python3 (host; for mp_spec.py, etc.) ==="
  if need_cmd python3; then
    ok "python3 already installed: $(python3 --version 2>&1)"
    return 0
  fi
  sudo dnf -y install python3 python3-pip
  ok "python3 installed: $(python3 --version 2>&1)"
}

ensure_snapd() {
  say "=== [3] Ensure snapd (Rocky requires EPEL) ==="
  if need_cmd snap; then
    ok "snap already available"
    return 0
  fi

  sudo dnf -y install epel-release
  sudo dnf -y install snapd

  # snapd socket 활성화 (RHEL 계열 가이드)
  sudo systemctl enable --now snapd.socket

  # classic snap 지원용 /snap 링크 (RHEL 계열 가이드)
  sudo ln -sf /var/lib/snapd/snap /snap

  ok "snapd installed & enabled"
  warn "If 'snap' command still not found, open a new shell (re-login may be needed)."
}

ensure_opentofu() {
  say "=== [4] Install OpenTofu (RPM method) ==="
  if need_cmd tofu; then
    ok "OpenTofu already installed: $(tofu --version | head -n 1)"
    return 0
  fi

  # OpenTofu 공식 설치 스크립트 (rpm 방법)
  curl --proto '=https' --tlsv1.2 -fsSL https://get.opentofu.org/install-opentofu.sh -o install-opentofu.sh
  chmod +x install-opentofu.sh
  ./install-opentofu.sh --install-method rpm
  rm -f install-opentofu.sh

  ok "OpenTofu installed: $(tofu --version | head -n 1)"
}

ensure_multipass() {
  say "=== [5] Install Multipass (snap) ==="
  if need_cmd multipass; then
    ok "Multipass already installed: $(multipass version | head -n 1)"
    return 0
  fi

  ensure_snapd
  sudo snap install multipass

  ok "Multipass installed: $(multipass version | head -n 1)"

  # 소켓 그룹 권한 안내 (Multipass 문서에 있는 체크)
  local sock="/var/snap/multipass/common/multipass_socket"
  if [ -S "$sock" ]; then
    local grp
    grp="$(ls -l "$sock" | awk '{print $4}')"
    if ! id -nG | tr ' ' '\n' | grep -qx "$grp"; then
      warn "You are not in the Multipass socket group ($grp). Add and re-login:"
      echo "  sudo usermod -aG $grp $USER"
      echo "  # then log out/in (or new SSH session)"
    else
      ok "User is in Multipass socket group ($grp)"
    fi
  else
    warn "Multipass socket not found yet: $sock"
  fi
}

ensure_kubectl_optional() {
  say "=== [6] Install kubectl (optional) ==="
  if need_cmd kubectl; then
    ok "kubectl already installed: $(kubectl version --client --short 2>/dev/null || true)"
    return 0
  fi

  # 방법 A) snap (간단)
  ensure_snapd
  sudo snap install kubectl --classic
  ok "kubectl installed (snap)"
  warn "kubectl 버전은 클러스터와 '1 minor 이내'가 권장됨." # 공식 가이드 참고 :contentReference[oaicite:4]{index=4}
}

ensure_helm_optional() {
  say "=== [7] Install helm (optional) ==="
  if need_cmd helm; then
    ok "helm already installed: $(helm version --short 2>/dev/null || true)"
    return 0
  fi

  ensure_snapd
  sudo snap install helm --classic
  ok "helm installed"
}

print_next_steps() {
  echo
  ok "Host setup completed"
  echo "Next steps (from repo root):"
  echo "  tofu init"
  echo "  tofu plan"
  echo "  tofu apply"
  echo
  echo "After the cluster is created:"
  echo "  export KUBECONFIG=./kubeconfig"
  echo "  kubectl get nodes"
  echo
}

main() {
  require_linux
  ensure_dnf_basics
  ensure_python3
  ensure_opentofu
  ensure_multipass
  ensure_kubectl_optional
  ensure_helm_optional
  print_next_steps
}

main "$@"
