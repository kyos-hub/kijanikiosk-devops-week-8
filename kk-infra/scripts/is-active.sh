#!/usr/bin/env bash
# is-active.sh — stand-in for `systemctl is-active kk-api-<env>.service`
# since this environment has no systemd.
#
# Usage: bash is-active.sh blue
set -euo pipefail

DEPLOY_ENV="${1:?Usage: is-active.sh <blue|green>}"
BASE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
PID_FILE="$BASE_DIR/run/kk-api-${DEPLOY_ENV}.pid"

if [ -f "$PID_FILE" ] && kill -0 "$(cat "$PID_FILE")" 2>/dev/null; then
  echo "active"
  exit 0
else
  echo "inactive"
  exit 3
fi
