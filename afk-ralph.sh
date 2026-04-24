#!/bin/bash
#
# afk-ralph.sh — loop Ralph until the PRD is done or max iterations reached.
#
# Same sandbox model as ralph-sandboxed.sh: macOS sandbox-exec confines
# file writes to the current project dir (+ a few caches Claude needs).
# No Docker, no credential propagation — runs as your user so macOS
# keychain auth works normally.
#
# When Ralph emits <promise>COMPLETE</promise> the loop exits early.
#
# Usage: ./afk-ralph.sh <max-iterations>

set -e

if [ -z "${1-}" ]; then
  echo "Usage: $0 <iterations>" >&2
  exit 1
fi

PROJECT="$(pwd)"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROFILE="$SCRIPT_DIR/ralph.sb"

if [ ! -f "$PROFILE" ]; then
  echo "Missing sandbox profile: $PROFILE" >&2
  exit 1
fi

for ((i=1; i<=$1; i++)); do
  echo "=== iteration $i/$1 @ $(date +'%H:%M:%S') ==="

  result=$(sandbox-exec \
    -D PROJECT="$PROJECT" \
    -D HOME_CLAUDE="$HOME/.claude" \
    -D HOME_CACHE="$HOME/.cache" \
    -D HOME_NPM="$HOME/.npm" \
    -D HOME_YARN="$HOME/.yarn" \
    -D HOME_PNPM="$HOME/.pnpm-store" \
    -D HOME_LIB_CACHES="$HOME/Library/Caches" \
    -D HOME_LIB_LOGS="$HOME/Library/Logs" \
    -f "$PROFILE" \
    claude --dangerously-skip-permissions -p "@PRD.md @progress.txt @plans/ \
  1. Find the highest-priority task and implement it. \
  2. Run your tests and type checks. \
  3. Update the PRD with what was done. \
  4. Append your progress to progress.txt. \
  5. Commit your changes. \
  ONLY WORK ON A SINGLE TASK. \
  If the PRD is complete, output <promise>COMPLETE</promise>.")

  echo "$result"

  if [[ "$result" == *"<promise>COMPLETE</promise>"* ]]; then
    echo "=== PRD complete after $i iterations ==="
    exit 0
  fi
done

echo "=== reached max iterations ($1) without completion ==="
