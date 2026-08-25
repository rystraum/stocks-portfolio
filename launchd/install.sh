#!/bin/bash
# Install the updated com.rystraum.* LaunchDaemons.
# Run with: sudo bash /Users/rystraum/Code/personal/stocks-portfolio/launchd/install.sh
set -euo pipefail

STAGED_DIR="$(cd "$(dirname "$0")" && pwd)"
LOG_PARENT="/Users/rystraum/Library/Logs"

# 1. Create the log directories. They live in the user's home, so they
#    survive macOS updates and never need root again.
mkdir -p "$LOG_PARENT/stocks-portfolio" "$LOG_PARENT/life-os-backend"
chown rystraum:staff "$LOG_PARENT/stocks-portfolio" "$LOG_PARENT/life-os-backend"

# 2. Stop the manually started app so the daemon can bind port 8081.
PID="$(lsof -tiTCP:8081 -sTCP:LISTEN || true)"
if [ -n "$PID" ]; then
  kill $PID || true
  sleep 2
fi

# 3. Copy the plists and reload each daemon.
for label in com.rystraum.stocks-portfolio com.rystraum.stocks-updater com.rystraum.crypto-updater com.rystraum.life-os-backend; do
  cp "$STAGED_DIR/$label.plist" "/Library/LaunchDaemons/$label.plist"
  chown root:wheel "/Library/LaunchDaemons/$label.plist"
  chmod 644 "/Library/LaunchDaemons/$label.plist"
  launchctl bootout "system/$label" 2>/dev/null || true
  launchctl bootstrap system "/Library/LaunchDaemons/$label.plist"
  echo "loaded $label"
done

# 4. Verify the web app answers.
sleep 15
if curl -s -o /dev/null --max-time 10 http://localhost:8081/; then
  echo "OK: app answers on port 8081"
else
  echo "WARN: app did not answer on port 8081; check $LOG_PARENT/stocks-portfolio/rails-server.error.log"
fi
