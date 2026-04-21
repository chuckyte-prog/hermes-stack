#!/bin/bash
# Runs the Hermes web dashboard (on localhost:9119, accessible via SSH tunnel)
# and the messaging gateway in the same container.
# If either one dies, the container exits so Railway restarts the whole thing.
set -e

# Dashboard binds to localhost only — safe default. SSH-tunnel from your laptop
# to reach it. Do NOT pass --insecure here; that would expose API keys on the
# public Railway URL.
hermes dashboard --no-open --port 9119 --host 127.0.0.1 &
DASHBOARD_PID=$!

# Gateway is what we actually want running 24/7 for Telegram.
hermes gateway &
GATEWAY_PID=$!

# Exit when either process dies so Railway's restart policy kicks in.
wait -n "$DASHBOARD_PID" "$GATEWAY_PID"
EXIT_CODE=$?

# Kill the surviving process so the container exits cleanly.
kill "$DASHBOARD_PID" "$GATEWAY_PID" 2>/dev/null || true

exit "$EXIT_CODE"
