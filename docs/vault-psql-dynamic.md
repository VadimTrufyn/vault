# Настраиваем PSQL на работу с динамическими секретами

1. подключаем новый тип хранилища

```bash
vault secrets enable -path=psql database
```

2. настраиваем конфиг и шаблон

```bash
vault write psql/config/testdb1 \
    plugin_name=postgresql-database-plugin \
    allowed_roles="db1-role" \
    connection_url="postgresql://{{username}}:{{password}}@psql:5432/testdb1?sslmode=disable" \
    username="testuser" \
    password="password"
```

3. добавляем роль

```bash
vault write psql/roles/db1-role \
    db_name=testdb1 \
    creation_statements="CREATE ROLE \"{{name}}\" WITH LOGIN PASSWORD '{{password}}' VALID UNTIL '{{expiration}}'; \
        GRANT SELECT ON ALL TABLES IN SCHEMA public TO \"{{name}}\";" \
    default_ttl="1h" \
    max_ttl="24h"
```

4. пробуем получить креды

```bash
vault read psql/creds/db1-role
```

5. пробуем под ними авторизоваться

```bash
psql -d testdb1 -W -U v-root-db1-role-RocdQtHY9MIESxcLjrj3-1661411587
```

6. смотрим юзеров

```bash
\du
```
