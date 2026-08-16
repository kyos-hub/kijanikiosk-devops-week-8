#!/usr/bin/env bash
# deploy-app.sh
# Starts (or restarts) the blue or green instance of kk-payments as a
# background process, since this environment has no systemd.
#
# Usage: APP_VERSION=v1.4.0 DEPLOY_ENV=green bash deploy-app.sh
set -euo pipefail

APP_VERSION="${APP_VERSION:?APP_VERSION is required, e.g. v1.4.0}"
DEPLOY_ENV="${DEPLOY_ENV:?DEPLOY_ENV is required, e.g. blue or green}"

BASE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
APP_DIR="$BASE_DIR/app"
RUN_DIR="$BASE_DIR/run"
LOG_DIR="$BASE_DIR/logs"
mkdir -p "$RUN_DIR" "$LOG_DIR"

if [ "$DEPLOY_ENV" = "blue" ]; then
  PORT=3000
elif [ "$DEPLOY_ENV" = "green" ]; then
  PORT=3001
else
  echo "DEPLOY_ENV must be 'blue' or 'green'" >&2
  exit 1
fi

PID_FILE="$RUN_DIR/kk-api-${DEPLOY_ENV}.pid"

# Stop any existing instance for this environment first
if [ -f "$PID_FILE" ]; then
  OLD_PID="$(cat "$PID_FILE")"
  if kill -0 "$OLD_PID" 2>/dev/null; then
    echo "Stopping existing kk-api-${DEPLOY_ENV} (pid $OLD_PID)"
    kill "$OLD_PID"
    sleep 1
  fi
  rm -f "$PID_FILE"
fi

echo "Starting kk-api-${DEPLOY_ENV} on port $PORT, version $APP_VERSION"
APP_VERSION="$APP_VERSION" PORT="$PORT" \
  nohup node "$APP_DIR/server.js" > "$LOG_DIR/kk-api-${DEPLOY_ENV}.log" 2>&1 &

NEW_PID=$!
echo "$NEW_PID" > "$PID_FILE"
sleep 1

# Confirm it actually came up
if ! kill -0 "$NEW_PID" 2>/dev/null; then
  echo "FAILED: kk-api-${DEPLOY_ENV} did not stay running. Check $LOG_DIR/kk-api-${DEPLOY_ENV}.log" >&2
  exit 1
fi

HEALTH=$(curl -s "http://127.0.0.1:${PORT}/health" || true)
echo "Health check: $HEALTH"
echo "kk-api-${DEPLOY_ENV} deployed successfully (pid $NEW_PID)"
