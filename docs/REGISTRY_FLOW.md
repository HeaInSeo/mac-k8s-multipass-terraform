# Registry 업로드 플로우 (초안)

이 프로젝트는 테스트용 K8s 클러스터에서 Operator/이미지 실험을 지원하기 위해 로컬/원격 Registry 연동이 필요합니다.

## 권장 흐름
1. 로컬 이미지 빌드
2. Registry 로그인
3. 태그/푸시
4. K8s에서 이미지 사용

## 예시 (Docker)
```bash
# 1) build
podman build -t my-operator:dev .

# 2) login
podman login <registry-host>

# 3) tag + push
podman tag my-operator:dev <registry-host>/my-operator:dev
podman push <registry-host>/my-operator:dev

# 4) deploy
kubectl set image deployment/my-operator my-operator=<registry-host>/my-operator:dev
```

## 테스트 체크리스트
- 이미지가 정상 push 되었는지 확인
- Pull 실패 시: 인증/네트워크/이미지 경로 확인
- 이미지 업데이트 시: `imagePullPolicy`와 태그 정책 확인

## 메모
- 실제 Registry 주소/인증은 환경에 따라 다르므로 별도 설정 문서가 필요
