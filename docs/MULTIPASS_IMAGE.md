# Multipass 이미지 명세 (Rocky 8)

이 프로젝트는 Rocky Linux 8 기반 이미지를 사용합니다. 환경에 따라 Multipass에서 제공하는 이미지 이름이 다를 수 있으므로, 아래 절차로 확인 후 `dev.auto.tfvars`의 `multipass_image`를 조정하세요.

## 이미지 확인
```bash
multipass find
```

출력에서 Rocky Linux 8 계열 이미지를 확인하고, 원하는 이름을 `multipass_image`로 지정합니다.

예시:
```hcl
multipass_image = "rocky-8"
```

## 확인 기준
- Rocky Linux 8 계열 이미지
- cloud-init 지원
- K8s 설치/운영에 충분한 디스크/메모리 확보
