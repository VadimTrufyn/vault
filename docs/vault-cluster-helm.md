# Разворачиваем vault в k8s

1. В heml надо отметить:

```yaml
ha:
  enabled: true
  raft:
    enabled: true
```

2. после запуска идем в первый vault-0 и инитим его (и открываем сразу)

```bash
vault operator init -key-shares=1 -key-threshold=1
vault operator unseal <key1>
```

3. второй и третий вольты подключаем к рафту первого и так же распечатываем

```bash
vault operator raft join http://vault-0.vault-internal:8200
vault operator unseal <key1>
```

3.1 проверяем HA

```bash
vault status
vault operator raft list-peers
```

4. логинимся в первом вольте, создаем kv-хранилище и пулим в него тестовый секрет

```bash
vault secrets enable -path=secret kv-v2
vault kv put secret/k8s/test username="realmanual" password="password"
```

## настроим k8s для работы с вольтом

1. `vault auth enable kubernetes`
2. `vault write auth/kubernetes/config kubernetes_host="https://$KUBERNETES_PORT_443_TCP_ADDR:443"`
3. создаем политику доступа

```bash
vault policy write k8s - <<EOF
path "secret/data/k8s/test" {
  capabilities = ["read"]
}
EOF
```

4. создаем роль

```bash
vault write auth/kubernetes/role/k8s \
        bound_service_account_names=vault \
        bound_service_account_namespaces=default \
        policies=k8s \
        ttl=24h
```

## запускаем тест

1. создаем в NS default сервисного юзера
`k create sa vault`

2. демлоим тестовое приложение

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: testapp
  labels:
    app: testapp
spec:
  replicas: 1
  selector:
    matchLabels:
      app: testapp
  template:
    metadata:
      labels:
        app: testapp
    spec:
      serviceAccountName: vault
      containers:
        - name: app
          image: hub.realmanual.ru/pub/vault-example-app:latest
          imagePullPolicy: Always
          env:
            - name: VAULT_ADDR
              value: 'http://vault-internal.vault:8200'
            - name: JWT_PATH
              value: '/var/run/secrets/kubernetes.io/serviceaccount/token'
            - name: SERVICE_PORT
              value: '8080'
            - name: SECRETS_PATH
              value: 'secret/data/k8s/test'
            - name: ROLE_NAME
              value: "k8s"
```

3. идем в созданный под, курлим результат нашего токена

```bash
curl http://localhost:8080
```
