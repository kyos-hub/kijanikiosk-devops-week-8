#!/usr/bin/env bash
# switch-env.sh
# Switches nginx traffic to the given environment (blue or green),
# updates state files, and confirms the switch via a live health check.
#
# Usage: sudo bash switch-env.sh green
set -euo pipefail

TARGET_ENV="${1:?Usage: switch-env.sh <blue|green>}"
BASE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
NGINX_CONF="/etc/nginx/kijanikiosk-active-env.conf"
STATE_DIR="$BASE_DIR/state"
mkdir -p "$STATE_DIR"

ACTIVE_FILE="$STATE_DIR/.active-env"
PREVIOUS_FILE="$STATE_DIR/.previous-env"

if [ "$TARGET_ENV" != "blue" ] && [ "$TARGET_ENV" != "green" ]; then
  echo "TARGET_ENV must be 'blue' or 'green'" >&2
  exit 1
fi

CURRENT_ENV="none"
if [ -f "$ACTIVE_FILE" ]; then
  CURRENT_ENV="$(cat "$ACTIVE_FILE")"
fi

if [ "$TARGET_ENV" = "blue" ]; then
  PORT=3000
else
  PORT=3001
fi

echo "[$(date -u +%Y-%m-%dT%H:%M:%SZ)] Switching from ${CURRENT_ENV} to ${TARGET_ENV}"

# Confirm the target instance is actually healthy before switching traffic to it
HEALTH=$(curl -s "http://127.0.0.1:${PORT}/health" || true)
if [ -z "$HEALTH" ]; then
  echo "ABORT: target environment ${TARGET_ENV} on port ${PORT} is not responding to /health" >&2
  exit 1
fi
echo "Pre-switch health check on ${TARGET_ENV}: $HEALTH"

# Write the new nginx config and reload
cp "$BASE_DIR/nginx/kijanikiosk-active-env.conf.${TARGET_ENV}" "$NGINX_CONF"
sudo nginx -t
sudo systemctl reload nginx 2>/dev/null || sudo service nginx reload

# Update state files
if [ "$CURRENT_ENV" != "none" ]; then
  echo "$CURRENT_ENV" > "$PREVIOUS_FILE"
fi
echo "$TARGET_ENV" > "$ACTIVE_FILE"

sleep 1
POST_HEALTH=$(curl -s "http://127.0.0.1:80/health" || true)
echo "[$(date -u +%Y-%m-%dT%H:%M:%SZ)] Post-switch health check through nginx: $POST_HEALTH"
echo "Switch complete: active=$(cat "$ACTIVE_FILE") previous=$(cat "$PREVIOUS_FILE" 2>/dev/null || echo none)"
