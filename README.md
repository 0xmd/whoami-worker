# Cloudflare Worker

- Serves authenticated user information
- Displays: "{EMAIL} authenticated at {TIMESTAMP} from {COUNTRY}"
- Where COUNTRY is a clickable link to tunnel.yourwebsite.com/secure/{COUNTRY} where SVG flags are displayed

# CICD Deployment via Github Actions
- Uses wrangler-action to deploy code changes
- See .github/workflows/deploy-worker.yml