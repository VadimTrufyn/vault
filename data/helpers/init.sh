apk add jq curl

export VAULT_ADDR=http://127.0.0.1:8200

unseal_vault() {
  root_token=$(cat /helpers/keys.json | jq -r '.root_token')

	vault operator unseal -address=${VAULT_ADDR} $(cat /helpers/keys.json | jq -r '.keys[0]')
  vault operator unseal -address=${VAULT_ADDR} $(cat /helpers/keys.json | jq -r '.keys[1]')
	vault login token=$root_token
}

if [[ -f /helpers/keys.json ]]
then
  echo "Vault already initialized"
  unseal_vault
else
  echo "Vault not initialized"
  curl -s --request POST --data '{"secret_shares": 2, "secret_threshold": 2}' ${VAULT_ADDR}/v1/sys/init > /helpers/keys.json

  unseal_vault

  # vault secrets enable -version=2 kv
  vault secrets enable -version=2 -path=secret kv
	vault auth enable kubernetes
fi

printf "\n\nVAULT_TOKEN=%s\n\n" $root_token
