#### TODO

- shell 에서 #!/usr/bin/env bash 바꾸는 것 해야함.  
- python3 로 얇게 적용하는 것 bash 와 병용해서 사용하는 것 구현해야함. 이게 깔끔함. python 공부 시작함.  
- setup-host-rocky8.sh 확인해줘야함.  
- setup-host-rocky8.sh 에 대응하는 삭제 부분도 해줘야 함. 
- addons 에서 uninstall.sh, install.sh 확인 후 통합해줘야 함.   

#### Test

- RECREATE_ON_DIFF=0 bash shell/multipass-launch.sh mp-test 24.04 1G 5G 1 init/k8s.yaml  


- setup-host-rocky8.sh 기본실행  

```bash
chmod +x setup-host-rocky8.sh
./setup-host-rocky8.sh

```

- OpenTofu/kubectl/helm 설치 스킵    
- 그룹 적용/재로그인/SELinux 확인해야함    

```bash
SKIP_TOFU=1 SKIP_KUBECTL=1 SKIP_HELM=1 ./setup-host-rocky8.sh
```

