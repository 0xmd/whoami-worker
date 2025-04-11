curl -s -X GET "https://api.cloudflare.com/client/v4/accounts/${CF_ACCOUNT_ID}/tokens/permission_groups" \
     -H "Authorization: Bearer ${READ_ALL_TOKEN}" \
     -H "Content-Type: application/json" \
| jq -c '
  (.result // [])[]
  | select(
      .name as $current_name |
      [ # Your list of desired names
          "Account Settings Read",
          "Workers Scripts Read",
          "Workers Scripts Write",
          "Workers Routes Read",
          "Workers Routes Write",
          "Workers R2 Storage Bucket Item Read",
          "Workers R2 Storage Bucket Item Write"
      ] | index($current_name)
    )
  | {id, name} # Output each selected object
'