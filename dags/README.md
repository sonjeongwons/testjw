# scf-airflow-dag

1. 본인을 위한 작업폴더를 생성합니다. (eg. cloud.park)
2. 머신에서 아래를 참조하여 SSH키를 생성합니다.[GitHub 계정에 새 SSH 키 추가 - GitHub Docs](https://docs.github.com/ko/authentication/connecting-to-github-with-ssh/adding-a-new-ssh-key-to-your-github-account)

   ```bash
   mkdir /root/.ssh/airflow
   ssh-keygen -t ed25519 -C "{your_email@example.com}"

   # Enter a file in which to save the key (/home/YOU/.ssh/id_ALGORITHM):[Press enter] 가 프롬프트되면
   > root/.ssh/airflow/airflow_key

   # Enter passphrase (empty for no passphrase): [Type a passphrase]가 뜨면 
   ? 엔터 두번
   ```

   ```bash
   # SSH agent 작동 확인

   $ eval "$(ssh-agent -s)"
   > Agent pid 59566
   
   ssh-add /root/.ssh/ariflow/airflow_key
   # Hi sdspaas/ssf-airflow-dag! You've successfully authenticated, but GitHub does not provide shell access 
   
   ```
3. 이후 다음을 참조하여 SSH키를 repo에 등록합니다.
   [Adding a new SSH key to your GitHub account - GitHub Docs](https://docs.github.com/en/authentication/connecting-to-github-with-ssh/adding-a-new-ssh-key-to-your-github-account)

   ```bash
   cat /root/.ssh/ariflow/airflow_key.pub
   ```
   
4. 이후 Repository의 설정 - deploy에 등록합니다.

5. 다음 명령으로 Key가 제대로 등록되었는지 확인해봅니다
   ```
   ssh -T git@code.sdsdev.co.kr
   ```

5. 이후 K8s Secret를 생성합니다.
   ```bash
   kubectl -n airflow delete secret airflow-git-ssh-secret
   
   kubectl create secret generic airflow-git-ssh-secret \
    --from-file=gitSshKey=/root/.ssh/airflow/airflow_key \
    --from-file=id_ed25519.pub=/root/.ssh/airflow/airflow_key.pub \
    -n airflow
   ```

6. 하기의 Airflow Repo를 참고하여 Helm의 value를 셋팅해줍니다.
    https://code.sdsdev.co.kr/sdspaas/scf-helm/tree/main/airflow
 

   
