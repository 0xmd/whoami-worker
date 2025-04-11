TOKEN_NAME="GitHub Actions Worker Deploy"

curl -s -X GET "https://api.cloudflare.com/client/v4/user/tokens" \
     -H "Authorization: Bearer ${TOKEN_CREATOR_TOKEN}" \
     -H "Content-Type: application/json" \
| jq --arg tokenName "$TOKEN_NAME" \
     'first((.result // [])[] | select(.name == $tokenName))' # Select first match