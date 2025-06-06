#!/bin/bash

source ./secrets-hetzner

# Hae zone_id domainin perusteella
ZONE_ID=$(curl -s -H "Auth-API-Token: $ACCESS_TOKEN" \
  https://dns.hetzner.com/api/v1/zones | jq -r '.zones[] | select(.name=="'"$DOMAIN"'") | .id')

if [ -z "$ZONE_ID" ]; then
  echo "❌ Zone ID ei löytynyt domainille $DOMAIN"
  exit 1
fi

echo "🔍 Zone ID löytyi: $ZONE_ID"
echo "📦 Haetaan A-tietueet..."

curl -s -H "Auth-API-Token: $ACCESS_TOKEN" \
  "https://dns.hetzner.com/api/v1/records?zone_id=$ZONE_ID" | \
  jq -r '.records[] | select(.type == "A") | "\(.id)\t\(.name)\t\(.value)"'

echo ""
echo "✅ Kopioi haluamasi ID:t secrets-hetzner-tiedostoon esimerkiksi näin:"
echo -n "RECORD_IDS=("
curl -s -H "Auth-API-Token: $ACCESS_TOKEN" \
  "https://dns.hetzner.com/api/v1/records?zone_id=$ZONE_ID" | \
  jq -r '[.records[] | select(.type == "A") | .id] | join(" ")'
echo ")"
