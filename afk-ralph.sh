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
# Usage: ./afk-ralph.sh [--claude|--codex|--opencode|--cursor] <max-iterations>

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/ralph-agent.sh"

set_agent_from_args "$@"
set -- "${REMAINING_ARGS[@]}"

if [ "${1-}" = "--help" ] || [ "${1-}" = "-h" ]; then
  echo "Usage: $0 [--claude|--codex|--opencode|--cursor] <iterations>" >&2
  exit 0
fi

if [ -z "${1-}" ]; then
  echo "Usage: $0 [--claude|--codex|--opencode|--cursor] <iterations>" >&2
  exit 1
fi

PROJECT="$(pwd)"
PROFILE="$SCRIPT_DIR/ralph.sb"

if [ ! -f "$PROFILE" ]; then
  echo "Missing sandbox profile: $PROFILE" >&2
  exit 1
fi

for ((i=1; i<=$1; i++)); do
  echo "=== iteration $i/$1 @ $(date +'%H:%M:%S') ==="

  prompt="@PRD.md @progress.txt @plans/ \
  1. Find the highest-priority task and implement it. \
  2. Run your tests and type checks. \
  3. Update the PRD with what was done. \
  4. Append your progress to progress.txt. \
  5. Commit your changes. \
  ONLY WORK ON A SINGLE TASK. \
  If the PRD is complete, output <promise>COMPLETE</promise>."

  result=$(sandbox-exec \
    -D PROJECT="$PROJECT" \
    -D HOME_CLAUDE="$HOME/.claude" \
    -D HOME_CLAUDE_JSON="$HOME/.claude.json" \
    -D HOME_CODEX="$HOME/.codex" \
    -D HOME_OPENCODE="$HOME/.opencode" \
    -D HOME_CURSOR="$HOME/.cursor" \
    -D HOME_CONFIG="$HOME/.config" \
    -D HOME_LOCAL_SHARE="$HOME/.local/share" \
    -D HOME_LOCAL_STATE="$HOME/.local/state" \
    -D HOME_CACHE="$HOME/.cache" \
    -D HOME_NPM="$HOME/.npm" \
    -D HOME_YARN="$HOME/.yarn" \
    -D HOME_PNPM="$HOME/.pnpm-store" \
    -D HOME_LIB_CACHES="$HOME/Library/Caches" \
    -D HOME_LIB_LOGS="$HOME/Library/Logs" \
    -f "$PROFILE" \
    bash "$SCRIPT_DIR/ralph-agent.sh" "$AGENT" print "$prompt")

  echo "$result"

  if [[ "$result" == *"<promise>COMPLETE</promise>"* ]]; then
    echo "=== PRD complete after $i iterations ==="
    exit 0
  fi
done

echo "=== reached max iterations ($1) without completion ==="
