#### TODO

- addons 설치/제거/검증 스크립트 정상 동작 재확인
- registry 업로드 플로우 확인
- mp_spec.py 사용처 정리 및 문서화

#### Test

- RECREATE_ON_DIFF=0 bash scripts/multipass/multipass-launch.sh mp-test rocky-8 1G 5G 1 cloud-init/k8s.yaml

- scripts/host/setup-host-rocky8.sh 기본 실행
```bash
chmod +x scripts/host/setup-host-rocky8.sh
./scripts/host/setup-host-rocky8.sh
```

- OpenTofu/kubectl/helm 설치 스킵
```bash
SKIP_TOFU=1 SKIP_KUBECTL=1 SKIP_HELM=1 ./scripts/host/setup-host-rocky8.sh
```

- 통합 스크립트 테스트
```bash
./scripts/k8s-tool.sh up
./scripts/k8s-tool.sh status
./scripts/k8s-tool.sh down
FORCE=1 ./scripts/k8s-tool.sh clean
```
