# ADR 0019: Single-Writer Contract for Runtime Input State

## Status

Accepted (2026-05-28). Closes issue #24.

## Context

Each runtime input component (`Checkbox`, `Switch`, `Textarea`, `Input`,
`RadioGroup`, `Dialog`, `Popover`) needs to expose its current value to
the Shiny input binding via a DOM expando such as `root.__sbCheckboxValue`.
The binding's `getValue(el)` reads that property synchronously when Shiny
asks for the input value.

The original implementation wrote each value into the expando from **two
places**:

1. A `useEffect(() => { root.__sbXxxValue = state }, [state])` that
   mirrored React state into the expando whenever it changed.
2. A `notifyChange(next)` (or equivalent) called from user-action setters
   and from the `__sbXxxReceive` server-update path, which also wrote the
   expando and then dispatched the `sb:<component>-change` event the
   binding subscribes to.

Because both writers targeted the same property, the order mattered:
React's commit (writer 1) had to land *after* the synchronous dispatch
write (writer 2) so the value the binding observed matched the value the
user produced. The original code achieved this by wrapping every dispatch
in `requestAnimationFrame(() => notifyChange(next))` — the rAF deferred
writer 2 until after the effect from writer 1 had fired.

The rAF was a workaround, not a fix. It also created a real failure mode:
server-driven `setValue` messages from the binding (e.g. an echoed
`Shiny.setInputValue`) were also held behind a frame, which delayed the
synchronisation back to Shiny by ~16ms per round-trip.

## Decision

Adopt a **single-writer** contract (Option B from issue #24). The
following invariants hold for every interactive runtime input:

- React state is the **owning store** for the value.
- The expando, dataset attribute, and hidden native input are written
  **only** from three explicit code paths:
  1. The mount effect (`useEffect(..., [inputId, root])`) — installs the
     initial value once.
  2. The user-action setter (`setChecked`, `selectValue`, `handleChange`,
     `setOpen`) — runs synchronously inside the event handler.
  3. The `__sbXxxReceive` server-update handler — runs synchronously when
     Shiny pushes an update.
- The `sb:<component>-change` dispatch happens **in the same synchronous
  block** as the expando write. No `requestAnimationFrame` separates them.
- The "mirror state into the DOM" `useEffect`s are removed.

This means by the time the binding's `subscribe` callback fires,
`getValue(el)` already returns the new value. The contract is verified
synchronously inside event handlers — no frame deferral, no race.

## Out of scope

- The `Slider` component is tracked separately (issue #25). Its
  `notifyFrameRef` exists to coalesce per-pointermove notifications, not
  to outwait React. The proper fix there is a Shiny binding rate policy.
- Focus management `requestAnimationFrame(() => target.focus(...))` calls
  remain. They wait for layout, not state.

## Consequences

- ~40 lines removed across the seven affected components, plus the two
  `useEffect` mirror writers each.
- One frame of latency removed from every `update_block_*()` echo path
  for these components.
- New `frontend/src/runtime/<component>` contributors must remember to
  hit all three write paths. The
  [shinyblocks-component](../../.claude/skills/shinyblocks-component/SKILL.md)
  recipe should reference this ADR.
- `test-runtime-js.R` includes a regression test that greps `index.jsx`
  for the old `requestAnimationFrame(...)` patterns.
