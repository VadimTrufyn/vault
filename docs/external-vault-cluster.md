# Подключаем внешний вольт в кубе

1. В heml надо отметить:

```yaml
injector:
  externalVaultAddr: "https://vault.bildme.ru"
server:
  enabled: false
```

2. проверяем токен сервисного юзера инжектора

```bash
kubectl describe serviceaccount -n vault vault
```

3. только если куб >= 1.24 версии (если ниже, проверяем что секрет vault есть и этот шаг пропускаем)

```yaml
apiVersion: v1
kind: Secret
metadata:
  name: vault-token-g955r <!!! заменить на свой !!!>
  namespace: vault
  annotations:
    kubernetes.io/service-account.name: vault
type: kubernetes.io/service-account-token
```

4. подбираем себе в переменную имя секрета (ну или смотрим в линзе)
  * проверьте, что у вас стоит утилита `jq`

```bash
VAULT_HELM_SECRET_NAME=$(kubectl get secrets -n vault --output=json | jq -r '.items[].metadata | select(.name|startswith("vault-token-")).name')
```

## настроим k8s для работы с вольтом

1. `vault auth enable kubernetes`
2. формируем JWT и нашего токена

`TOKEN_REVIEW_JWT=$(kubectl get secret -n vault $VAULT_HELM_SECRET_NAME --output='go-template={{ .data.token }}' | base64 --decode)`

3. выдергиваем CA-сертификат из куба

`KUBE_CA_CERT=$(kubectl config view --raw --minify --flatten --output='jsonpath={.clusters[].cluster.certificate-authority-data}' | base64 --decode)`

4. и получаем внешний адрес самого куба

`KUBE_HOST=$(kubectl config view --raw --minify --flatten --output='jsonpath={.clusters[].cluster.server}')`

5. заполняем конфиг подключения к кубу со стороны вольта

```bash
vault write auth/kubernetes/config \
     token_reviewer_jwt="$TOKEN_REVIEW_JWT" \
     kubernetes_host="$KUBE_HOST" \
     kubernetes_ca_cert="$KUBE_CA_CERT" \
     issuer="https://kubernetes.default.svc.cluster.local"
```

## тестируем на деплое

1. создаем политику доступа к конкретному секрету

```bash
vault policy write k8s-policy - <<EOF
path "secret/data/k8s/config" {
  capabilities = ["read"]
}
EOF
```

2. формируем роль

```bash
vault write auth/kubernetes/role/k8s-role \
     bound_service_account_names=sa-vault \
     bound_service_account_namespaces=vault-test \
     policies=k8s-policy \
     ttl=24h
```

## тестируем

1. пулим тестовый секрет

```bash
vault kv put secret/k8s/config username='realmanual' password='password' psqlhost='123.124.22.22' database='realdb'
```

2. запускаем тестовый деплой из [файлика](../k8s/vault-test.yaml)
