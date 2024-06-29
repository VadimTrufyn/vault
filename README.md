# Vault test

Настраиваем получение логопаса в под из внешнего vault-сервера

## Общий порядок действий

1. поднять vault сервер
2. поднять heml-чарт
3. настроить подключение из куба в vault
4. добавить в vault тестовые секреты, запустить тестовый деплоймент и проверить что секреты получены

### 1. запуск vault в докере

1. `./start.sh`
2. `export VAULT_ADDR=https://vault.domain.com`
3. `vault login`

### 2. запуск heml-чарта

1. прописываем в переменных адрес vault-сервера
2. запускаем чарт `helm upgrade --install --create-namespace -n vault vault helm/vault`
3. если у вас версия куба 1.24 и выше, то создаем токен руками

```bash
cat > vault-secret.yaml <<EOF
apiVersion: v1
kind: Secret
metadata:
  name: vault-token-g955r
  annotations:
    kubernetes.io/service-account.name: vault
type: kubernetes.io/service-account-token
EOF
```

### 3. подключение из куба в vault

1. `vault auth enable kubernetes`
2. подсмотреть имя у VAULT_HELM_SECRET_NAME=vault-token-xxxxx в кубе
3. `TOKEN_REVIEW_JWT=$(kubectl get secret $VAULT_HELM_SECRET_NAME -n vault --output='go-template={{ .data.token }}' | base64 --decode)`
4. `KUBE_CA_CERT=$(kubectl config view --raw --minify --flatten --output='jsonpath={.clusters[].cluster.certificate-authority-data}' | base64 --decode)`
5. `KUBE_HOST=$(kubectl config view --raw --minify --flatten --output='jsonpath={.clusters[].cluster.server}')`
6. прописываем конфиг соединения

```bash
vault write auth/kubernetes/config \
     token_reviewer_jwt="$TOKEN_REVIEW_JWT" \
     kubernetes_host="$KUBE_HOST" \
     kubernetes_ca_cert="$KUBE_CA_CERT" \
     issuer="https://kubernetes.default.svc.cluster.local"
```

7. добавляем полиси доступа

```bash
vault policy write vault-test - <<EOF
path "kv/data/secret/vault-test" {
  capabilities = ["read"]
}
EOF
```

8. формируем роль доступа с куба в вольт

```bash
vault write auth/kubernetes/role/vault-test \
     bound_service_account_names=sa-vault \
     bound_service_account_namespaces=vault-test \
     policies=vault-test \
     ttl=24h
```

### 4. Запуск тестового деплоя

1. `vault kv put kv/secret/vault-test username='vassiliy' password='password' database='testdb' psqlhost='psql-service'`
2. `vault kv get -format=json kv/secret/vault-test | jq ".data.data"`
3. `k apply -f k8s/vault-test.yaml`


### 5. Add-ons

1. [restore-root](docs/restore-root--token.md)
