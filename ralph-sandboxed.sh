#!/bin/bash
#
# ralph-sandboxed.sh — one-shot Ralph run, confined by macOS sandbox-exec.
#
# Same spirit as ralph-once.sh, but:
#   * uses --dangerously-skip-permissions (no prompts at all)
#   * wraps the whole process tree in sandbox-exec so file writes are
#     restricted to the current project dir (+ common agent/cache dirs).
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
source "$SCRIPT_DIR/ralph-agent.sh"

set_agent_from_args "$@"

if [ "${REMAINING_ARGS[0]-}" = "--help" ] || [ "${REMAINING_ARGS[0]-}" = "-h" ]; then
  echo "Usage: $0 [--claude|--codex|--opencode|--pi|--cursor]" >&2
  exit 0
fi

if [ ! -f "$PROFILE" ]; then
  echo "Missing sandbox profile: $PROFILE" >&2
  exit 1
fi

PROMPT="@PRD.md @progress.txt @plans/ \
1. Read the PRD, the progress file, and any relevant plan in plans/. \
2. Find the next incomplete task and implement it. \
3. Commit your changes. \
4. Update progress.txt with what you did. \
ONLY DO ONE TASK AT A TIME."

exec sandbox-exec \
  -D PROJECT="$PROJECT" \
  -D HOME_CLAUDE="$HOME/.claude" \
  -D HOME_CLAUDE_JSON="$HOME/.claude.json" \
  -D HOME_CODEX="$HOME/.codex" \
  -D HOME_OPENCODE="$HOME/.opencode" \
  -D HOME_PI="$HOME/.pi" \
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
  bash "$SCRIPT_DIR/ralph-agent.sh" "$AGENT" sandboxed "$PROMPT"
