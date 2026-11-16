#!/bin/sh
# Railway wrapper for Steel Browser: puts an API-key gate (nginx) on $PORT in
# front of the Steel API, which listens on localhost only.
set -e

if [ -z "$STEEL_API_KEY" ]; then
  echo "ERROR: STEEL_API_KEY is not set. Set it to a long random value." >&2
  exit 1
fi
if [ "${#STEEL_API_KEY}" -lt 16 ] || ! printf '%s' "$STEEL_API_KEY" | grep -Eq '^[A-Za-z0-9._~-]+$'; then
  echo "ERROR: STEEL_API_KEY must be at least 16 characters of A-Z a-z 0-9 . _ ~ -" >&2
  exit 1
fi

LISTEN_PORT="${PORT:-8080}"
# Steel's in-browser recorder extension posts to http://localhost:3000, so the
# API keeps port 3000 unless the gate itself was put there.
APP_PORT=3000
[ "$LISTEN_PORT" = "$APP_PORT" ] && APP_PORT=3001

# Public URLs the API puts in session responses (websocketUrl, debugUrl, ...).
if [ -z "$DOMAIN" ]; then
  if [ -n "$RAILWAY_PUBLIC_DOMAIN" ]; then
    DOMAIN="$RAILWAY_PUBLIC_DOMAIN"
    USE_SSL="${USE_SSL:-true}"
  else
    DOMAIN="localhost:$LISTEN_PORT"
  fi
fi
export DOMAIN
export USE_SSL="${USE_SSL:-false}"

# Persistence on the /data volume.
mkdir -p /data/files /data/user-data-dir /data/logs
export LOG_STORAGE_ENABLED="${LOG_STORAGE_ENABLED:-true}"
export LOG_STORAGE_PATH="${LOG_STORAGE_PATH:-/data/logs/browser-logs.duckdb}"

# HTTP Basic credentials for the web UI: user "steel", password = the API key.
BASIC=$(printf 'steel:%s' "$STEEL_API_KEY" | base64 | tr -d '\n')

sed -e "s|__LISTEN_PORT__|$LISTEN_PORT|g" \
    -e "s|__APP_PORT__|$APP_PORT|g" \
    -e "s|__API_KEY__|$STEEL_API_KEY|g" \
    -e "s|__BASIC__|$BASIC|g" \
    /app/railway/nginx.conf.template > /app/api/nginx.conf

# Fail fast on a bad config: upstream's entrypoint ignores nginx start errors.
if ! nginx -t -q -c /app/api/nginx.conf; then
  echo "ERROR: generated nginx config is invalid" >&2
  exit 1
fi

# The upstream entrypoint starts nginx with /app/api/nginx.conf, then the API.
export HOST=127.0.0.1
export PORT="$APP_PORT"
echo "Steel Browser: API key gate on port $LISTEN_PORT, API on 127.0.0.1:$APP_PORT, public domain $DOMAIN (USE_SSL=$USE_SSL)"
exec /app/api/entrypoint.sh "$@"
