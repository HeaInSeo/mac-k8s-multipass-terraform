# mac-k8s-multipass-terraform

이 프로젝트는 **Rocky Linux 8** 환경에서 Multipass와 OpenTofu를 이용해 **kubeadm 기반 멀티 노드 Kubernetes 클러스터**를 자동으로 구성하는 테스트 도구입니다. 운영 대상은 호스트와 VM 모두 Rocky Linux 8입니다.

## 요구 사항
- Rocky Linux 8 (호스트)
- OpenTofu >= 1.6
- Multipass
- bash
- 선택: kubectl
- 선택: helm

## 빠른 시작
1. 호스트 준비
```bash
chmod +x scripts/host/setup-host-rocky8.sh
./scripts/host/setup-host-rocky8.sh
```

2. 클러스터 배포 (통합 스크립트)
```bash
./scripts/k8s-tool.sh up
```

3. 클러스터 확인
```bash
./scripts/k8s-tool.sh status
```

4. 클러스터 삭제
```bash
./scripts/k8s-tool.sh down
```

5. 로컬 상태 정리
```bash
FORCE=1 ./scripts/k8s-tool.sh clean
```

## 디렉터리 구조
```
.
├── cloud-init/
│   ├── k8s.yaml                # K8s용 cloud-init
│   ├── redis.yaml              # Redis VM용 cloud-init
│   └── mysql.yaml              # MySQL VM용 cloud-init
├── scripts/
│   ├── cluster/
│   │   ├── cluster-init.sh      # kubeadm init 실행 (master-0)
│   │   └── join-all.sh          # master/worker join + kubeconfig export
│   ├── host/
│   │   ├── setup-host-rocky8.sh # Rocky 8 호스트 준비 스크립트
│   │   └── cleanup-host-rocky8.sh # Rocky 8 호스트 정리 스크립트
│   ├── legacy/
│   │   └── setup-host-ubuntu.sh # 참고용(지원하지 않음)
│   ├── multipass/
│   │   ├── multipass-launch.sh  # VM 생성 래퍼
│   │   ├── multipass-delete.sh  # VM 삭제 래퍼
│   │   ├── multipass-run-remote.sh # 로컬 스크립트를 VM에서 실행
│   │   ├── delete-vm.sh         # (옵션) 로컬 VM 정리
│   │   └── mp_spec.py           # Multipass 스펙 확인
│   ├── services/
│   │   ├── redis-install.sh     # Redis 패스워드 설정
│   │   └── mysql-install.sh     # MySQL 루트/유저/DB 설정
│   └── k8s-tool.sh              # 통합 클러스터 관리 스크립트
├── addons/
│   ├── manage.sh                # Add-on 통합 스크립트
│   ├── install.sh
│   ├── uninstall.sh
│   ├── verify.sh
│   └── values/
├── docs/
│   ├── MULTIPASS_IMAGE.md
│   ├── ADDONS_TEST.md
│   ├── REGISTRY_FLOW.md
│   ├── MP_SPEC_GUIDE.md
│   └── ARCH_REVIEW.md
├── main.tf
├── variables.tf
└── dev.auto.tfvars
```

## 변수 설정
- `variables.tf` 기본값은 Rocky 8 기준으로 설정되어 있습니다.
- 필요 시 `dev.auto.tfvars`에서 `multipass_image`, `vm_user` 등을 오버라이드하세요.
- Rocky 8 이미지 확인은 `docs/MULTIPASS_IMAGE.md`를 참고하세요.

## Add-ons
```bash
cd addons
./manage.sh install
./manage.sh verify
./manage.sh uninstall
./manage.sh hosts
```

## 호스트 정리
```bash
FORCE=1 ./scripts/host/cleanup-host-rocky8.sh
```

## 참고 문서
- `docs/ADDONS_TEST.md`
- `docs/REGISTRY_FLOW.md`
- `docs/MP_SPEC_GUIDE.md`
- `docs/ARCH_REVIEW.md`

## 주의 사항
- Rocky Linux 8 환경을 기준으로만 지원합니다.
- Ubuntu 기반 스크립트는 `scripts/legacy/`에 보관되며 유지보수 대상이 아닙니다.
