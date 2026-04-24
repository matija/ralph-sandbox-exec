# ralph-sandbox-exec

Run [Ralph](https://ghuntley.com/ralph/) with `sandbox-exec` (macOS) instead of Docker.

## Files

- `ralph.sb` — sandbox profile (writes allowed in project + a few caches).
- `ralph-sandboxed.sh` — one-shot run.
- `afk-ralph.sh <n>` — loop up to `n` times, or until Ralph emits `<promise>COMPLETE</promise>`.
- `ralph-once.sh` — original, no sandbox.

## Use

```bash
cd some-project   # needs PRD.md and progress.txt
/path/to/ralph/ralph-sandboxed.sh
# or
/path/to/ralph/afk-ralph.sh 20
```

Blocks dumb writes outside the project dir. Doesn't block reads or network,
so this isn't a hostile-agent defense.
