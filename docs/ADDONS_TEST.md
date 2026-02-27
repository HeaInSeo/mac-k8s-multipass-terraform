# Add-ons 테스트 시나리오

이 문서는 Add-ons 설치/검증/삭제 흐름을 검증하기 위한 체크리스트입니다.

## 사전 조건
- 클러스터가 정상 기동되어 있어야 함
- `kubectl` 및 `helm` 설치
- `KUBECONFIG`가 올바르게 설정됨

## 설치 테스트
```bash
cd addons
./manage.sh install
```

확인 항목:
- `metallb-system`, `istio-system`, `argocd`, `monitoring`, `logging`, `tracing`, `vault` 네임스페이스 생성
- 각 Helm 릴리스가 정상 설치 상태
- `hosts.generated` 파일 생성

## 검증 테스트
```bash
cd addons
./manage.sh verify
```

확인 항목:
- 각 Helm 릴리스 status OK
- 각 네임스페이스 존재
- Pod Running 비율 확인
- LoadBalancer 서비스 확인

## hosts 갱신 테스트
```bash
cd addons
./manage.sh hosts
```

확인 항목:
- `hosts.generated`에 최신 LoadBalancer IP가 반영됨

## 삭제 테스트
```bash
cd addons
./manage.sh uninstall
```

확인 항목:
- Helm 릴리스 삭제
- 네임스페이스 삭제(필요 시 수동 실행)
- `/etc/hosts` 도메인 정리

## 메모
실제 실행 결과(성공/실패)는 별도 실행 로그로 기록한다.
