#!/usr/bin/env bash

if [ ! -f secrets-hetzner ]; then
  echo "❌ secrets-hetzner-tiedosto puuttuu"
  exit 1
fi

source ./secrets-hetzner

if [ -z "$ACCESS_TOKEN" ]; then
  echo "❌ ACCESS_TOKEN ei asettunut. Varmista että secrets-hetzner sisältää oikein kirjoitetun rivin:"
  echo "   ACCESS_TOKEN=abcdef123..."
  exit 1
fi

echo "🔍 Testataan Hetzner DNS API -tokenia..."

response=$(curl -s -w "\\n%{http_code}" -H "Auth-API-Token:  $ACCESS_TOKEN" https://dns.hetzner.com/api/v1/zones)

http_code=$(echo "$response" | tail -n1)
body=$(echo "$response" | sed '$d')

if [ "$http_code" -eq 200 ]; then
    zone_count=$(echo "$body" | jq '.zones | length')
    if [ "$zone_count" -gt 0 ]; then
        echo "✅ API-token toimii. Löydettiin $zone_count zonea:"
        echo "$body" | jq -r '.zones[] | " - \(.name) (id: \(.id))"'
    else
        echo "⚠️ Token toimii, mutta ei näe yhtään zonea."
    fi
elif [ "$http_code" -eq 401 ]; then
    echo "❌ Token hylättiin (401 Unauthorized)."
elif [ "$http_code" -eq 403 ]; then
    echo "❌ Tokenilla ei ole oikeuksia (403 Forbidden)."
else
    echo "❌ Odottamaton virhe (HTTP $http_code)"
    echo "$body"
fi
