---
date: 2026-05-19
phase: 6
component: agent workflow
---

# Sandboxed shell commands can fail before the real check runs

## Symptom

Two recurring failures showed up during cleanup work:

```text
Error: No available showcase smoke port found.
```

from `npm run test:showcase`, and

```text
zsh: parse error near `()'
zsh:1: parse error in command substitution
```

from inline `gh issue comment --body "..."` commands containing
Markdown, backticks, parentheses, or nested quotes.

## Investigation

The showcase smoke test passed immediately when rerun outside the
sandbox, and the GitHub command succeeded when the body was written to a
temp file and posted with `--body-file`.

## Root cause

- The sandbox can block the temporary local port probe used by
  `tools/showcase-smoke.mjs`, so the script fails before the actual
  Shiny app/test logic runs.
- Complex inline shell payloads are fragile under zsh parsing and tool
  wrapping. The shell can reject the command before `gh` or `Rscript`
  receives it.

## Fix

- Rerun `npm run test:showcase` outside the sandbox / with escalation
  when the port probe reports no available ports.
- For complex payloads, write content to a temp file and use
  `gh issue comment --body-file ...`, `gh issue edit --body-file ...`,
  or a here-doc instead of long inline quoted strings.

## What NOT to do

- Do not treat `No available showcase smoke port found.` as a product
  regression until the command has been rerun outside the sandbox.
- Do not keep retrying heavily quoted one-line shell commands when a
  temp file or here-doc would make the payload deterministic.

## References

- Related instructions: `AGENTS.md`
- Related note: `docs/dev-notes/2026-05-19-showcase-sandbox-port-binding.md`
