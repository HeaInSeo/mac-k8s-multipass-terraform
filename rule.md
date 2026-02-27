# rule.md

## OS 표준
- 모든 VM 이미지와 패키지 설치 로직은 Rocky Linux 8 기준으로 작성한다.
- 패키지 매니저는 dnf를 사용한다.

## Git 워크플로우
- 변경 사항은 기능 단위로 커밋한다.
- 커밋 메시지 접두어는 다음 중 하나를 사용한다.
  - feat:
  - fix:
  - docs:
  - refactor (Rocky8):

## IaC 원칙
- null_resource 트리거 구조를 엄격히 준수한다.
- 모든 변수는 variables.tf로 변수화한다.
