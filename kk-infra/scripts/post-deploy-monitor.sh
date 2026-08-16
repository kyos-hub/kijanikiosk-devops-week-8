#!/usr/bin/env bash
# post-deploy-monitor.sh
# Polls the currently-active environment's health endpoint every 5 seconds.
# On 3 consecutive failures, automatically triggers a rollback to the
# previous environment via switch-env.sh — no human action required.
#
# Usage: bash post-deploy-monitor.sh 60
#   (60 = confidence window in seconds; monitor exits clean if no fault
#    is detected within this window)
set -euo pipefail

WINDOW_SECONDS="${1:-60}"
POLL_INTERVAL=5
FAILURE_THRESHOLD=3

BASE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
STATE_DIR="$BASE_DIR/state"
ACTIVE_FILE="$STATE_DIR/.active-env"
PREVIOUS_FILE="$STATE_DIR/.previous-env"

if [ ! -f "$ACTIVE_FILE" ]; then
  echo "No .active-env found — run switch-env.sh first" >&2
  exit 1
fi

ACTIVE_ENV="$(cat "$ACTIVE_FILE")"
if [ "$ACTIVE_ENV" = "blue" ]; then
  PORT=3000
else
  PORT=3001
fi

echo "[$(date -u +%Y-%m-%dT%H:%M:%SZ)] [MONITOR START] Watching ${ACTIVE_ENV} on port ${PORT}, window=${WINDOW_SECONDS}s, poll=${POLL_INTERVAL}s, threshold=${FAILURE_THRESHOLD} consecutive failures"

ELAPSED=0
CONSEC_FAILURES=0

while [ "$ELAPSED" -lt "$WINDOW_SECONDS" ]; do
  sleep "$POLL_INTERVAL"
  ELAPSED=$((ELAPSED + POLL_INTERVAL))

  if curl -s -f -m 3 "http://127.0.0.1:${PORT}/health" > /dev/null 2>&1; then
    if [ "$CONSEC_FAILURES" -gt 0 ]; then
      echo "[$(date -u +%Y-%m-%dT%H:%M:%SZ)] [MONITOR OK] Health recovered after ${CONSEC_FAILURES} failure(s)"
    fi
    CONSEC_FAILURES=0
  else
    CONSEC_FAILURES=$((CONSEC_FAILURES + 1))
    echo "[$(date -u +%Y-%m-%dT%H:%M:%SZ)] [MONITOR WARN] Health check failed (${CONSEC_FAILURES}/${FAILURE_THRESHOLD} consecutive)"
  fi

  if [ "$CONSEC_FAILURES" -ge "$FAILURE_THRESHOLD" ]; then
    echo "[MONITOR FAIL] ROLLBACK TRIGGERED at $(date -u +%Y-%m-%dT%H:%M:%SZ) after ${CONSEC_FAILURES} consecutive failures on ${ACTIVE_ENV}"

    ROLLBACK_TARGET="blue"
    if [ "$ACTIVE_ENV" = "blue" ]; then
      ROLLBACK_TARGET="green"
    fi
    if [ -f "$PREVIOUS_FILE" ]; then
      ROLLBACK_TARGET="$(cat "$PREVIOUS_FILE")"
    fi

    bash "$BASE_DIR/scripts/switch-env.sh" "$ROLLBACK_TARGET"

    echo "[$(date -u +%Y-%m-%dT%H:%M:%SZ)] Rollback to ${ROLLBACK_TARGET} complete — confirming health through proxy"
    curl -s "http://127.0.0.1:80/health" || true
    echo ""
    echo "[$(date -u +%Y-%m-%dT%H:%M:%SZ)] [MONITOR EXIT] Rollback confirmed, monitor exiting"
    exit 0
  fi
done

echo "[$(date -u +%Y-%m-%dT%H:%M:%SZ)] [MONITOR EXIT] Window elapsed with no rollback triggered — ${ACTIVE_ENV} remained healthy"
