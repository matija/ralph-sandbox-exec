# ralph-sandbox-exec

Run [Ralph](https://ghuntley.com/ralph/) with `sandbox-exec` (macOS) instead of Docker.

## Use

```bash
cd some-project   # needs PRD.md and progress.txt

# one task, sandboxed
/path/to/ralph-sandbox-exec/ralph-sandboxed.sh

# loop up to 20 tasks
/path/to/ralph-sandbox-exec/afk-ralph.sh 20
```

Claude is the default. Use another agent with a flag:

```bash
/path/to/ralph-sandbox-exec/ralph-sandboxed.sh --codex
/path/to/ralph-sandbox-exec/afk-ralph.sh --opencode 20
/path/to/ralph-sandbox-exec/ralph-sandboxed.sh --cursor
```

Agent commands:

- Claude: `claude --dangerously-skip-permissions`
- Codex: `codex --sandbox danger-full-access --ask-for-approval never`
- opencode: `opencode run --dangerously-skip-permissions`
- Cursor: `cursor-agent --force --sandbox disabled`

The sandbox blocks writes outside the project and common agent/cache dirs. It does not block reads or network.
