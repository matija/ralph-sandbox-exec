#!/bin/bash

set_agent_from_args() {
  AGENT="claude"
  REMAINING_ARGS=()

  while [ "$#" -gt 0 ]; do
    case "$1" in
      --claude)
        AGENT="claude"
        ;;
      --codex)
        AGENT="codex"
        ;;
      --opencode)
        AGENT="opencode"
        ;;
      --cursor)
        AGENT="cursor"
        ;;
      --help|-h)
        REMAINING_ARGS+=("$1")
        ;;
      --)
        shift
        REMAINING_ARGS+=("$@")
        break
        ;;
      *)
        REMAINING_ARGS+=("$1")
        ;;
    esac
    shift
  done
}

run_agent() {
  local agent="$1"
  local mode="$2"
  local prompt="$3"

  case "$agent:$mode" in
    claude:once)
      claude --permission-mode acceptEdits "$prompt"
      ;;
    claude:sandboxed)
      claude --dangerously-skip-permissions "$prompt"
      ;;
    claude:print)
      claude --dangerously-skip-permissions -p "$prompt"
      ;;
    codex:once|codex:sandboxed)
      codex --sandbox danger-full-access --ask-for-approval never "$prompt"
      ;;
    codex:print)
      codex exec --sandbox danger-full-access --ask-for-approval never --color never "$prompt"
      ;;
    opencode:once|opencode:sandboxed|opencode:print)
      opencode run --dangerously-skip-permissions "$prompt"
      ;;
    cursor:once|cursor:sandboxed)
      cursor-agent --force --sandbox disabled "$prompt"
      ;;
    cursor:print)
      cursor-agent --print --force --trust --sandbox disabled "$prompt"
      ;;
    *)
      echo "Unknown agent/mode: $agent/$mode" >&2
      return 1
      ;;
  esac
}

if [[ "${BASH_SOURCE[0]}" == "$0" ]]; then
  if [ "$#" -ne 3 ]; then
    echo "Usage: $0 <claude|codex|opencode|cursor> <once|sandboxed|print> <prompt>" >&2
    exit 1
  fi

  run_agent "$1" "$2" "$3"
fi
