# немного про метрики

0. возможные метрики [вот](https://www.vaultproject.io/docs/internals/telemetry) и [вот](https://learn.hashicorp.com/tutorials/vault/usage-metrics)

1. политика для доступа к метрикам

```yaml
# To retrieve the usage metrics
path "sys/internal/counters/activity" {
  capabilities = ["read"]
}

# To read and update the usage metrics configuration
path "sys/internal/counters/config" {
  capabilities = ["read", "update"]
}

#---------------------------
# Vault Enterprise only
#---------------------------

# To view existing namespaces if any
path "sys/namespaces" {
  capabilities = ["list", "read", "update"]
}

# UI to show the namespace selector
path "sys/internal/ui/namespaces" {
  capabilities = ["read", "list", "update", "sudo"]
}

# UI to list existing mounts
path "sys/internal/ui/mounts" {
  capabilities = ["read", "sudo"]
}

# To read and update the usage metrics configuration for any namespace
path "+/sys/internal/counters/config" {
  capabilities = ["read", "update"]
}

# To retrieve the usage metrics for any namespace
path "+/sys/internal/counters/activity" {
  capabilities = ["read"]
}
```

2. включение сборки метрик

`vault write sys/internal/counters/config enabled=enable retention_months=12`

3. посмотреть метрики через запрос

`vault read -format=json  sys/internal/counters/activity | jq -r ".data"`

4. с фильтром

```bash
vault read -format=json sys/internal/counters/activity \
     start_time=2021-09-01T00:00:00Z \
     end_time=2021-09-30T23:59:59Z  | jq -r ".data"
```

5. дашбоард
для [графаны](https://grafana.com/grafana/dashboards/12904-hashicorp-vault/) и для [zabbix](https://www.zabbix.com/ru/integrations/hashicorp_vault)

6. логи

начиная с версии 1.3 доступен отдельный [бинарь](https://releases.hashicorp.com/vault-auditor/)

`vault-auditor parse --help`

`vault-auditor parse audit-logs`

7. мониторинг и алерты

для prom [тут](https://github.com/bosh-prometheus/prometheus-boshrelease/blob/master/jobs/vault_alerts/templates/vault.alerts.yml) и [тут](https://awesome-prometheus-alerts.grep.to/rules.html#hashicorp-vault)
