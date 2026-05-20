# Body

> Shinyblocks function: `block_body()`
> Shadcn reference: <https://ui.shadcn.com/blocks>
> Status: R-side layout primitive; Phase 7 spec refreshed around the
> shipped shell hook contract.

## States

- **default** — main content landmark for the page shell, rendered as
  `<main class="sb-body">`.
- **with-sidebar-layout** — sits inside `.sb-page-main` beside the
  optional sidebar/header shell when emitted via `block_page()`.

## R API

| Argument | Purpose |
| --- | --- |
| `...` | Body content. |
| `class` | Extra classes for the `.sb-body` element. |

## Stable shell hooks

`block_body()` owns `.sb-body` as the package shell's main content
layout hook. Runtime-rendered components must not depend on it for
their visual states; the shell stylesheet guardrail enforces this.

## Accessibility

- Rendered as a `<main>` landmark.
- `block_page()` wraps its `...` body content with `block_body()`
  automatically, so a typical app emits exactly one main landmark.

## Token contract

| Visual role | Token |
| --- | --- |
| Surface | `--background` (inherited from shell) |
| Foreground | `--foreground` (inherited from shell) |

## Deliberate divergences from shadcn

- `block_body()` is a semantic layout helper; shadcn block examples use
  plain container markup instead of a named primitive.

## Reference screenshot

![Body](_screenshots/body.png)

Captured from <https://ui.shadcn.com/blocks> on 2026-05-11.
Refresh and update the date whenever shadcn updates the canonical look.
