# Example policy

[!]

## открыть полный доступ на все под-пути
path "secret/*" {
  capabilities = ["create", "read", "update", "patch", "delete", "list"]
}

## если давать полные права, но запрещать удаление

path "secrets/*" {
  capabilities = ["create", "read", "update", "list"]
}
path "secrets/destroy/*" {
  capabilities = ["deny"]
}
path "secrets/delete/*" {
  capabilities = ["deny"]
}

## закрыть доступ к конкретному секрету
path "secret/super-secret" {
  capabilities = ["deny"]
}

## открыть list на суб-путь
path "secret/+/team" {
  capabilities = ["list"]
}

## отрыть папку и дать list

path "secret/metadata/team1/*" {
 capabilities = ["list"]
}

path "secret/data/team1/*" {
  capabilities = [, "create", "read", "update"]
}

# а вот так в KV работать не будет!
path "secret/restricted" {
  capabilities = ["create"]
  allowed_parameters = {
    "foo" = []
    "bar" = ["zip", "zap"]
  }
}

## шаблоны

path "secret/data/{{identity.entity.id}}/*" {
  capabilities = ["create", "update", "patch", "read", "delete"]
}

path "secret/metadata/{{identity.entity.id}}/*" {
  capabilities = ["list"]
}

[подробнее](https://www.vaultproject.io/docs/concepts/policies#examples)

## задать обязательные переменные (в KV работать не будет!)

path "secret/profile" {
  capabilities = ["create"]
  required_parameters = ["name", "id"]
}

## или запретить какие-то из них (в KV работать не будет!)

path "auth/userpass/users/*" {
  capabilities = ["update"]
  denied_parameters = {
    "token_policies" = []
  }
}
