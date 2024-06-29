# бекапим vault правильно

## если у вас бесплатная версия

1. создание снепа

```bash
vault login
vault operator raft snapshot save <snapshot-name>
```

2. пример политики для снепшотов

```yaml
vault policy write snapshot-read - <<EOF
path "sys/storage/raft/snapshot" {
  capabilities = ["read"]
}
EOF
```

## если у вас Enterprise лицензия, то все проще

1. локально

```bash
vault write sys/storage/raft/snapshot-auto/config/daily interval="24h" retain=5 \
     path_prefix="raft-backup" storage_type="local" local_max_space=1073741824
```

2. удаленно на s3

```bash
vault write sys/storage/raft/snapshot-auto/config/daily interval="24h" retain=5 \
     storage_type="aws-s3" \
     aws_s3_bucket="vault" aws_s3_region="ru-1" aws_access_key_id="access-key" aws_secret_access_key="secret-key" \
     aws_s3_endpoint="https://s3-point.ru" aws_s3_force_path_style="true"
```
## восстанавливаем из снепа

```bash
vault operator raft snapshot restore <snapshot-name>
```
