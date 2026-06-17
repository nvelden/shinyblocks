# Progress

> Shinyblocks function: `block_progress()`
> Shadcn reference: <https://ui.shadcn.com/docs/components/progress>
> Status: Runtime presentational component, display-only and
> server-addressable (`update_block_progress()` / `inc_block_progress()`).

Embedded, inline progress bar. Unlike Shiny's native `Progress` /
`withProgress()` notification panel, it renders exactly where it is placed in
the UI rather than as a floating session notification.

## States

- **determinate** — indicator filled to `(value - min) / (max - min)`,
  composited via `translateX` with a ~200ms ease transition.
- **indeterminate** — looping sweep keyframe; percent and
  `aria-valuenow`/`aria-valuetext` suppressed, `aria-busy="true"`.
- **complete** — `value == max` is a stable no-op steady state (no auto-hide,
  no auto-reset, no completion event).
- **degenerate** — a single-endpoint update yielding `min == max` renders 0%
  with validly ordered progressbar ARIA rather than fabricating a width.
- **reduced-motion** — width transition disabled; the indeterminate sweep rests
  as a static ~40% bar under `prefers-reduced-motion: reduce`.

## R API

| Argument | Purpose |
| --- | --- |
| `id` | Component id used to address the bar from the server. Not a form control — no `input$<id>` value. |
| `value` / `min` / `max` | Determinate scale. Constructor clamps `value` into `[min, max]`; requires `min < max`. |
| `message` | Dynamic status line (header-left, or a muted second line when `label` is also set). |
| `detail` | Secondary muted text below the track. |
| `label` | Static description of what is progressing (header-left). |
| `show_value` | Render the clamped percent at header-right. Suppressed when indeterminate. |
| `indeterminate` | Show the unknown-progress sweep instead of a determinate fill. |
| `variant` | `default`, `success`, `warning`, `info`, or `destructive`. |
| `width` | CSS width of the component (`NULL` fills the container). |
| `class` / `style` | Merged onto / applied to the runtime mount. |

Server helpers: `update_block_progress()` sets any field (omitted args preserve,
`NULL` text clears, `NULL` numeric errors); `inc_block_progress(amount=)` is
signed and saturating. The runtime owns merged-state validity — it clamps into
the merged `[min, max]` and repairs an inverted range.

## Runtime mapping

| R input | Runtime payload |
| --- | --- |
| `value` / `min` / `max` / `indeterminate` | `state` |
| `message` / `detail` / `label` / `show_value` / `variant` / `style` | `props` |
| `width` | mount `<div>` inline style (wrapper sizing only) |
| `class` | `className` on the mount |

`style` and `width` target different nodes by design: `width` sizes the mount
wrapper, while `style` is applied to the inner `.sb-progress-body`. Both
`block_progress(style=)` and `update_block_progress(style=)` style that same node
with the same normalized-React-object grammar (matching the textarea/select
convention).

## Token contract

| Visual role | Token |
| --- | --- |
| Track surface | `--muted` |
| Indicator (default) | `--primary` |
| Indicator (success / warning / info) | `--success-foreground` / `--warning-foreground` / `--info-foreground` |
| Indicator (destructive) | `--destructive` |
| Label text | `--foreground` |
| Message / detail / value text | `--muted-foreground` |

The variant fills are driven by one rule: `data-variant` on `.sb-progress-body`
remaps the `--sb-progress-indicator` custom property. The success/warning/info
fills intentionally use the saturated `-foreground` tokens, not the pale
`--success`/`--warning`/`--info` badge-background tints, so the bar stays legible.

## Deliberate divergences from shadcn

- **Embedded, not a notification.** shadcn Progress is a bare bar; shinyblocks
  adds a header (`label`/`message`/`show_value`) and `detail` slot so it works
  as a self-contained inline status block. It is explicitly *not* a port of
  Shiny's session-notification progress panel.
- **Server-driven, display-only.** Addressed by `id` (not `input_id`); it
  exposes no meaningful `input$<id>` value (receive-only runtime binding).

## Reference screenshot

![Progress](_screenshots/progress.png)

Captured from <https://ui.shadcn.com/docs/components/progress> on 2026-06-16.
Refresh and update the date whenever shadcn updates the canonical look.
