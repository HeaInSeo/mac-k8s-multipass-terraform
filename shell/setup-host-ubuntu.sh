#!/usr/bin/env bash
set -euo pipefail

need_cmd() { command -v "$1" >/dev/null 2>&1; }
say()  { echo "$*"; }
ok()   { echo "OK: $*"; }
warn() { echo "WARN: $*"; }
die()  { echo "ERROR: $*" >&2; exit 1; }

require_linux_ubuntu() {
  if [ ! -f /etc/os-release ]; then
    die "This script targets Linux (Ubuntu/Debian family)."
  fi
  . /etc/os-release
  case "${ID:-}" in
    ubuntu|debian) ;;
    *)
      warn "Detected OS: ID=${ID:-unknown}. Install steps may differ on non-Ubuntu/Debian."
      ;;
  esac
}

ensure_apt_basics() {
  say "=== [1] Install basic packages (apt) ==="
  sudo apt-get update
  sudo apt-get install -y \
    ca-certificates \
    curl \
    git \
    gnupg \
    apt-transport-https \
    unzip \
    jq
  ok "Basic packages installed (curl/git/gnupg/jq, etc.)"
}

ensure_snapd() {
  say "=== [2] Ensure snapd ==="
  if need_cmd snap; then
    ok "snap is available"
    return 0
  fi

  warn "snap is missing; installing snapd"
  sudo apt-get install -y snapd
  sudo systemctl enable --now snapd || true
  ok "snapd installed"
}

ensure_opentofu() {
  say "=== [3] Install OpenTofu (official deb repo) ==="
  if need_cmd tofu; then
    ok "OpenTofu already installed: $(tofu --version | head -n 1)"
    return 0
  fi

  sudo install -m 0755 -d /etc/apt/keyrings

  curl -fsSL https://get.opentofu.org/opentofu.gpg | sudo tee /etc/apt/keyrings/opentofu.gpg >/dev/null
  curl -fsSL https://packages.opentofu.org/opentofu/tofu/gpgkey \
    | sudo gpg --no-tty --batch --dearmor -o /etc/apt/keyrings/opentofu-repo.gpg >/dev/null

  sudo chmod a+r /etc/apt/keyrings/opentofu.gpg /etc/apt/keyrings/opentofu-repo.gpg

  sudo tee /etc/apt/sources.list.d/opentofu.list >/dev/null <<'EOF'
deb [signed-by=/etc/apt/keyrings/opentofu.gpg,/etc/apt/keyrings/opentofu-repo.gpg] https://packages.opentofu.org/opentofu/tofu/any/ any main
deb-src [signed-by=/etc/apt/keyrings/opentofu.gpg,/etc/apt/keyrings/opentofu-repo.gpg] https://packages.opentofu.org/opentofu/tofu/any/ any main
EOF

  sudo apt-get update
  sudo apt-get install -y tofu

  ok "OpenTofu installed: $(tofu --version | head -n 1)"
}

ensure_multipass() {
  say "=== [4] Install Multipass ==="
  if need_cmd multipass; then
    ok "Multipass already installed: $(multipass version | head -n 1)"
    return 0
  fi

  ensure_snapd
  sudo snap install multipass
  ok "Multipass installed: $(multipass version | head -n 1)"
}

ensure_kubectl_optional() {
  say "=== [5] Install kubectl (optional but recommended) ==="
  if need_cmd kubectl; then
    ok "kubectl already installed"
    return 0
  fi

  ensure_snapd
  sudo snap install kubectl --classic
  ok "kubectl installed"
}

ensure_helm_optional() {
  say "=== [6] Install helm (optional; required for addon install.sh) ==="
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
  warn "On low-RAM laptops, start with workers=0 or workers=1 in dev.auto.tfvars."
}

ensure_python3() {
  say "=== [0] Install Python3 (host; required for mp_spec.py) ==="
  if need_cmd python3; then
    ok "python3 already installed: $(python3 --version 2>&1)"
    return 0
  fi

  # Ubuntu/Debian
  sudo apt-get update
  sudo apt-get install -y python3 python3-venv python3-pip
  ok "python3 installed: $(python3 --version 2>&1)"
}

main() {
  require_linux_ubuntu
  ensure_apt_basics
  ensure_python3
  ensure_opentofu
  ensure_multipass
  ensure_kubectl_optional
  ensure_helm_optional
  print_next_steps
}

main "$@"
