#!/usr/bin/env bash

[ ! -f $HOME/dynamic-dns/secrets-hetzner ] && echo 'secrets file is missing!' && exit 1

source "$HOME/dynamic-dns/secrets-hetzner"

# Hae julkinen IP
public_ip=$(curl -s http://checkip.amazonaws.com/)

# Hae zone_id
ZONE_ID=$(curl -s -H "Auth-API-Token:  $ACCESS_TOKEN" \
  "https://dns.hetzner.com/api/v1/zones" | jq -r '.zones[] | select(.name=="'"$DOMAIN"'") | .id')

[ -z "$ZONE_ID" ] && echo "Zone ID not found for $DOMAIN" && exit 1

# Tarkista jokainen RECORD_ID
for ID in "${RECORD_IDS[@]}"; do

  local_ip=$(curl -s -H "Auth-API-Token: $ACCESS_TOKEN" \
    "https://dns.hetzner.com/api/v1/records/$ID" | jq -r '.record.value')

  [ "$local_ip" == "$public_ip" ] && exit 0

  for white in "${WHITE_IPS[@]}"; do
    [ "$white" == "$public_ip" ] && exit 0
  done

  curl --fail --silent --output /dev/null \
    -X PUT "https://dns.hetzner.com/api/v1/records/$ID" \
    -H "Auth-API-Token: $ACCESS_TOKEN" \
    -H "Content-Type: application/json" \
    -d '{"value": "'"$public_ip"'", "ttl": 60, "type": "A", "name": "'"$RECORD_NAME"'", "zone_id": "'"$ZONE_ID"'"}'

done
