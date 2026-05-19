---
date: 2026-05-19
phase: 5
component: showcase workflow
---

# Sandboxed showcase restarts can fail after binding to port 4321

## Symptom

Running `make showcase` inside a Codex command sandbox can print:

```text
Listening on http://127.0.0.1:4321
createTcpServer: operation not permitted
Error in initialize(...) : Failed to create server
```

This looks like the app started and then crashed for an application
reason, but the failure is environmental.

## Investigation

The local app code loaded correctly and the same command succeeded when
rerun outside the sandbox. A follow-up `curl -sSI
http://127.0.0.1:4321/` returned `200 OK` after the escalated restart.

## Root cause

The Codex sandbox can allow the Shiny process to reach the "Listening"
log line and still reject the actual TCP server creation on the fixed
showcase port. That is a sandbox port-binding limitation, not a
`shinyblocks` runtime regression.

## Fix

Document the workflow in `AGENTS.md` and `docs/ROADMAP.md`: if the
sandboxed restart fails with `createTcpServer: operation not permitted`,
rerun `make showcase` outside the sandbox / with escalation and confirm
the restarted app with `curl -sSI http://127.0.0.1:4321/`.

## What NOT to do

Do not start debugging component code, CSS, or showcase server wiring
from this error alone. First rule out the sandbox by rerunning the app
outside it.

## References

- Related workflow: `docs/ROADMAP.md#local-preview-workflow`
- Related instructions: `AGENTS.md`
