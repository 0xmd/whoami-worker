#!/bin/bash

if [[ -z "${CF_ACCOUNT_ID}" ]]; then
  echo "Error: Environment variable CF_ACCOUNT_ID is not set or is empty." >&2
  exit 1
fi

if [[ -z "${TOKEN_CREATOR_TOKEN}" ]]; then
  echo "Error: Environment variable TOKEN_CREATOR_TOKEN is not set or is empty." >&2
  exit 1
fi

TOKEN_NAME="GitHub Actions Worker Deploy"

# Exact names as found in Cloudflare documentation/UI
declare -a DESIRED_PERM_NAMES=(
  "Account Settings Read"
  "Workers Scripts Read"
  "Workers Scripts Write"
  "Workers Routes Read"
  "Workers Routes Write"
  "Workers R2 Storage Bucket Item Read"
  "Workers R2 Storage Bucket Item Write"
)

# Fetch all Permission Groups
echo "Fetching all permission groups..."
ALL_PERMS_JSON=$(curl -s -X GET "https://api.cloudflare.com/client/v4/accounts/{$CF_ACCOUNT_ID}/tokens/permission_groups" \
  -H "Authorization: Bearer ${READ_ALL_TOKEN}" \
  -H "Content-Type: application/json")

# Check for errors fetching permissions
if ! echo "${ALL_PERMS_JSON}" | jq -e '.success == true' > /dev/null; then
  echo "Error fetching permission groups:"
  echo "${ALL_PERMS_JSON}" | jq .
  exit 1
fi

# Filter and Extract Target IDs
echo "Extracting IDs for desired permissions..."
PERM_GROUPS_PAYLOAD_ARRAY="[" # Start building the JSON array string

first=true
for name in "${DESIRED_PERM_NAMES[@]}"; do
  # Use jq to find the ID for the current name
  id=$(echo "${ALL_PERMS_JSON}" | jq -r --arg NAME "$name" '.result[] | select(.name == $NAME) | .id')

  if [[ -z "$id" ]]; then
    echo "Warning: Could not find ID for permission group named '$name'. Skipping."
    continue
  fi

  # Add comma if not the first element
  if [ "$first" = false ]; then
    PERM_GROUPS_PAYLOAD_ARRAY="${PERM_GROUPS_PAYLOAD_ARRAY},"
  fi
  first=false

  # Append the JSON object for this permission group
  PERM_GROUPS_PAYLOAD_ARRAY="${PERM_GROUPS_PAYLOAD_ARRAY}{\"id\":\"${id}\",\"meta\":{}}"

done
PERM_GROUPS_PAYLOAD_ARRAY="${PERM_GROUPS_PAYLOAD_ARRAY}]" # Close the JSON array string

# Fetch GitHub IPs
echo "Fetching GitHub Actions IP ranges..."
GITHUB_IPS_JSON=$(curl -s https://api.github.com/meta | jq '.actions')
if [[ -z "$GITHUB_IPS_JSON" || "$GITHUB_IPS_JSON" == "null" ]]; then
    echo "Error fetching GitHub IPs."
    exit 1
fi


# Construct Token Creation Payload
echo "Constructing final payload..."
JSON_PAYLOAD=$(cat <<EOF
{
  "name": "${TOKEN_NAME}",
  "policies": [
    {
      "effect": "allow",
      "resources": {
        "com.cloudflare.api.account.${CF_ACCOUNT_ID}": "*"
      },
      "permission_groups": ${PERM_GROUPS_PAYLOAD_ARRAY}
    }
  ],
  "condition": {
    "request.ip": {
      "in": ${GITHUB_IPS_JSON}
    }
  }
}
EOF
)

# Print payload for debugging
# echo "Payload to be sent:"
# echo "${JSON_PAYLOAD}" | jq .

# API Call to Create Token
echo "Creating API Token..."
curl -X POST "https://api.cloudflare.com/client/v4/user/tokens" \
     -H "Authorization: Bearer ${TOKEN_CREATOR_TOKEN}" \
     -H "Content-Type: application/json" \
     -d "${JSON_PAYLOAD}"

echo