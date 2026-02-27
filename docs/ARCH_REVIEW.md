# 아키텍처 의견서 (요청 사항 정리)

## 1) mp_spec.py 및 Python 기반 확장에 대한 의견

### 판단
- **단기적으로는 Bash 유지**가 적합합니다. 지금은 VM 생성/삭제/클러스터 초기화가 핵심이며, Bash로도 충분히 안정적으로 처리됩니다.
- **중기적으로는 Python 전환**이 유리합니다. 테스트/계측/Operator 시나리오가 복잡해질수록 상태 관리와 에러 처리가 Bash보다 Python이 훨씬 유리합니다.

### 권장 방향
- `scripts/k8s-tool.sh`는 유지하되, 내부에서 Python CLI를 호출하는 옵션을 제공하도록 확장
- `mp_spec.py`는 향후 `scripts/py/` 모듈로 정리하고, 스펙 수집/검증/리포팅에 집중

### 결론
- **현재는 Bash**, **기능 확장 시 Python로 점진 전환**이 합리적입니다.

## 2) provider가 쉘 스크립트(local-exec) 기반인 것의 단점과 의견

### 단점
- 재현성/관측성이 약함(상태가 Terraform state 밖에서 발생)
- 실패 시 복구가 어려움(부분 실패 처리/rollback 제한)
- 플랫폼 종속성 강함(호스트 환경/경로 차이 민감)

### 이 프로젝트에서의 적합성
- **테스트용 목적이라면 허용 가능**합니다. 빠른 반복과 편의성이 목표이므로 local-exec 기반 접근도 실용적입니다.
- 단, **테스트 시나리오가 커지면** 실패 재현성/추적 문제가 커질 수 있습니다.

### 권장 보완책
- `scripts/k8s-tool.sh`로 단일 진입점을 제공(이미 적용)
- 단계별 로그 및 결과 파일 저장(추후 확장 권장)
- 중기적으로는 Python/Go 기반 오케스트레이터로 이동 고려

## 3) GitHub Actions 보강 의견

### 현재 상태
- CI: tofu fmt/validate/plan + shellcheck
- Self-hosted: multipass smoke

### 보강 제안(우선순위 순)
1. **shellcheck 대상 확장**: `scripts/**/*.sh`, `addons/*.sh` 포함 (반영 완료)
2. **Markdown lint**: 문서 품질 유지(README, docs) — 필요 시 `markdownlint` 추가
3. **YAML lint**: cloud-init 및 workflow 파일 검증 — 필요 시 `yamllint` 추가
4. **정책/보안 스캔(선택)**: gitleaks/trivy 등(테스트용이면 낮은 우선순위)

### 결론
- CI는 이미 핵심을 충족하며, 문서/구성 파일에 대한 lint를 추가하면 안정성이 더 올라갑니다.
