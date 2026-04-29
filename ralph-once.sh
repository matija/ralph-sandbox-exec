#!/bin/bash

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/ralph-agent.sh"

set_agent_from_args "$@"

if [ "${REMAINING_ARGS[0]-}" = "--help" ] || [ "${REMAINING_ARGS[0]-}" = "-h" ]; then
  echo "Usage: $0 [--claude|--codex|--opencode|--cursor]" >&2
  exit 0
fi

PROMPT="@PRD.md @progress.txt @plans/ \
1. Read the PRD, the progress file, and any plan files in plans/. \
2. If a plan exists for the next task, follow it. Otherwise, find the next incomplete task in the PRD and implement it. \
3. Commit your changes. \
4. Update progress.txt with what you did. \
ONLY DO ONE TASK AT A TIME."

run_agent "$AGENT" once "$PROMPT"
