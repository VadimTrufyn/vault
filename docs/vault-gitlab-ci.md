# Подключаем внешний вольт к Gitlab-CI

1. настраиваем метод jwt

```bash
vault auth enable jwt
vault write auth/jwt/config \
  jwks_url="https://git.realmanual.ru/-/jwks" \
  bound_issuer="git.realmanual.ru"
```

2. создаем тестовый секрет

```bash
vault kv put secret/gitlab/db1 password='pa$$w0rd'
```

3. настраиваем политику доступа к конкретному секрету

```bash
vault policy write gitlabci-policy - <<EOF
path "secret/data/gitlab/db1" {
  capabilities = [ "read" ]
}
EOF
```

4. создаем роль

```bash
vault write auth/jwt/role/gitlabci-role - <<EOF
{
  "role_type": "jwt",
  "policies": ["gitlabci-policy"],
  "token_explicit_max_ttl": 60,
  "user_claim": "user_email",
  "bound_claims_type": "glob",
  "bound_claims": {
    "project_id": "121",
    "ref_protected": "true",
    "ref_type": "branch",
    "ref": "main"
  }
}
EOF
```

5. смотрим пример [.gitlab-ci.yml](../.gitlab-ci.yml)
