# Активируем доступ через oauth-Gitlab

## со стороны GitLab

1. https://gitlab.<domain>/admin/applications
2. New application
3. Заполняем данные

* name = Vault
* openid = check
* Redirect Url =
	http://localhost:8025/iodc/callback
	https://vault.<domain>/ui/vault/auth/oidc/oidc/callback

4. Забираем себе значения `your_application_id` и `your_secret`

## Со стороны Vault

0. Создаем админскую политику из файлика admin-policy.json
1. `vault auth enable oidc`
2. создаем конфигурацию

```bash
vault write auth/oidc/config oidc_discovery_url="http://gitlab.<domain>" oidc_client_id="your_application_id" oidc_client_secret="your_secret" default_role="<user-role>" bound_issuer="gitlab.<domain>"
```

3. Конфигурируем роль

```bash
vault write auth/oidc/role/<user-role> -<<EOF
{
   "user_claim": "sub",
   "allowed_redirect_uris": "https://vault.<domain>/ui/vault/auth/oidc/oidc/callback,http://localhost:8250/oidc/callback",
   "bound_audiences": "<your_application_id>",
   "oidc_scopes": "openid",
   "role_type": "oidc",
   "policies": "<user-policy>",
   "ttl": "1h",
   "bound_claims": { "groups": ["yourGroup/yourSubgrup"] }
}
EOF
```

4. Логин через консоль запускается так

`vault login -method=oidc role=<user-role>`
