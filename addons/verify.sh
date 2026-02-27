#!/bin/bash
echo "🔍 Add-on 설치 상태 점검 시작..."

ADDONS=(
  "istio-system:istio-base"
  "istio-system:istiod"
  "istio-ingress:istio-ingress"
  "argocd:argocd"
  "monitoring:kube-prometheus-stack"
  "logging:loki"
  "logging:promtail"
  "tracing:jaeger"
  "tracing:otel"
  "istio-system:kiali"
  "vault:vault"
  "metallb-system:metallb"
)

echo ""
for entry in "${ADDONS[@]}"; do
  ns="${entry%%:*}"
  release="${entry##*:}"
  echo "🧪 [$release] in namespace [$ns]"

  if helm status "$release" -n "$ns" > /dev/null 2>&1; then
    echo "  ✅ Helm release installed"
  else
    echo "  ❌ Helm release NOT found"
    continue
  fi

  if kubectl get ns "$ns" > /dev/null 2>&1; then
    echo "  ✅ Namespace exists"
  else
    echo "  ❌ Namespace missing"
  fi

  running_pods=$(kubectl get pods -n "$ns" --no-headers 2>/dev/null | grep -c Running || true)
  total_pods=$(kubectl get pods -n "$ns" --no-headers 2>/dev/null | wc -l)
  echo "  🟢 Pods Running: $running_pods / $total_pods"

  lb_services=$(kubectl get svc -n "$ns" --no-headers 2>/dev/null | grep -c LoadBalancer || true)
  echo "  🌐 LoadBalancer Services: $lb_services"
  echo ""
done

echo "✅ 검증 완료"
