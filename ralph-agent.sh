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
    claude:stream)
      claude --dangerously-skip-permissions --verbose --print --output-format stream-json "$prompt" </dev/null \
        | jq --unbuffered -rj '
            select(.type == "assistant").message.content[]?
            | select(.type == "text").text // empty
            | gsub("\n"; "\r\n") + "\r\n\n"'
      ;;
    codex:once|codex:sandboxed)
      codex --sandbox danger-full-access --ask-for-approval never "$prompt"
      ;;
    codex:print)
      codex exec --sandbox danger-full-access --ask-for-approval never --color never "$prompt"
      ;;
    codex:stream)
      codex exec --json --sandbox danger-full-access --color never --skip-git-repo-check "$prompt" </dev/null \
        | jq --unbuffered -rj '
            select(.type == "item.completed").item as $i
            | if   $i.type == "agent_message"    then ($i.text    // "") + "\n\n"
              elif $i.type == "reasoning"        then "[reasoning] " + (($i.text // "") | gsub("\n"; " ")) + "\n"
              elif $i.type == "command_execution" then "$ " + ($i.command // "") + "\n"
              elif $i.text    then $i.text + "\n"
              elif $i.command then "$ " + $i.command + "\n"
              else empty end'
      ;;
    opencode:once|opencode:sandboxed|opencode:print)
      opencode run --dangerously-skip-permissions "$prompt"
      ;;
    opencode:stream)
      # opencode --format json buffers everything until exit, so just use the
      # default plain-text print mode which already streams.
      opencode run --dangerously-skip-permissions "$prompt"
      ;;
    cursor:once|cursor:sandboxed)
      cursor-agent --force --sandbox disabled "$prompt"
      ;;
    cursor:print)
      cursor-agent --print --force --trust --sandbox disabled "$prompt"
      ;;
    cursor:stream)
      cursor-agent --print --force --trust --sandbox disabled \
        --output-format stream-json --stream-partial-output "$prompt" </dev/null \
        | jq --unbuffered -rj '
            select(.type == "assistant" and (.timestamp_ms != null)).message.content[]?
            | select(.type == "text").text // empty
            | gsub("\n"; "\r\n")'
      ;;
    *)
      echo "Unknown agent/mode: $agent/$mode" >&2
      return 1
      ;;
  esac
}

if [[ "${BASH_SOURCE[0]}" == "$0" ]]; then
  if [ "$#" -ne 3 ]; then
    echo "Usage: $0 <claude|codex|opencode|cursor> <once|sandboxed|print|stream> <prompt>" >&2
    exit 1
  fi

  run_agent "$1" "$2" "$3"
fi
