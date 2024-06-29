# восстанавливаем токен рута

1. `vault operator generate-root -generate-otp`
2. `vault operator generate-root -init -otp="<OTP Value>"`
3. `vault operator generate-root` X столько раз, сколько ключей для распечатывания
4. `vault operator generate-root -decode="b64-token-root" -otp="<OTP Value>"`
