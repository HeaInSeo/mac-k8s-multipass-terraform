#### TODO

- scripts/host/setup-host-rocky8.sh 대응 삭제 스크립트(호스트 정리) 추가
- addons/install.sh, addons/uninstall.sh, addons/verify.sh 통합 점검
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
