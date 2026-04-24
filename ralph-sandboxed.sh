#!/bin/bash
#
# ralph-sandboxed.sh — one-shot Ralph run, confined by macOS sandbox-exec.
#
# Same spirit as ralph-once.sh, but:
#   * uses --dangerously-skip-permissions (no prompts at all)
#   * wraps the whole process tree in sandbox-exec so file writes are
#     restricted to the current project dir (+ a few caches Claude
#     legitimately needs).
#   * runs as your normal user, so macOS keychain auth just works —
#     no Docker, no credential juggling.
#
# Test-drive in a throwaway dir first. If Ralph hits a "permission denied"
# on a path it legitimately needs, add that path to ralph.sb.
#
# Tail sandbox denials while debugging:
#   log stream --predicate 'eventMessage contains "Sandbox"' --style compact

set -euo pipefail

PROJECT="$(pwd)"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROFILE="$SCRIPT_DIR/ralph.sb"

if [ ! -f "$PROFILE" ]; then
  echo "Missing sandbox profile: $PROFILE" >&2
  exit 1
fi

exec sandbox-exec \
  -D PROJECT="$PROJECT" \
  -D HOME_CLAUDE="$HOME/.claude" \
  -D HOME_CACHE="$HOME/.cache" \
  -D HOME_NPM="$HOME/.npm" \
  -D HOME_YARN="$HOME/.yarn" \
  -D HOME_PNPM="$HOME/.pnpm-store" \
  -D HOME_LIB_CACHES="$HOME/Library/Caches" \
  -D HOME_LIB_LOGS="$HOME/Library/Logs" \
  -f "$PROFILE" \
  claude --dangerously-skip-permissions "@PRD.md @progress.txt @plans/ \
1. Read the PRD, the progress file, and any relevant plan in plans/. \
2. Find the next incomplete task and implement it. \
3. Commit your changes. \
4. Update progress.txt with what you did. \
ONLY DO ONE TASK AT A TIME."
