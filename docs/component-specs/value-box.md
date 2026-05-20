# Value Box

> Shinyblocks function: `block_value_box()`
> Shadcn reference: <https://ui.shadcn.com/blocks>
> Status: Runtime composition primitive; Phase 7 spec refreshed around
> the shipped title/value/description/icon/content slot contract.

## States

- **default** — compact metric card with title, primary value, and
  optional description.
- **with-icon** — optional leading metric icon.
- **with-extra-body** — supplementary body content via `...` below the
  main value.

## R API

| Argument | Purpose |
| --- | --- |
| `title` | Metric title. String or tag. Required. |
| `value` | Primary metric value. String or tag. Required. |
| `...` | Additional body content rendered below the value. |
| `description` | Optional description text. |
| `icon` | Optional icon tag or vendored icon name. Forced to `inline-start` placement. |
| `class` | Extra classes merged onto the runtime wrapper. |

## Runtime mapping

| R input | Runtime payload |
| --- | --- |
| `title` | `props$titleHtml` |
| `value` | `props$valueHtml` |
| `description` | `props$descriptionHtml` |
| `...` | `props$contentHtml` |
| `icon` | `props$iconHtml` |
| `class` | `className` |

## Token contract

| Visual role | Token |
| --- | --- |
| Surface | `--card` |
| Foreground | `--card-foreground` |
| Muted text | `--muted-foreground` |
| Border | `--border` |

## Deliberate divergences from shadcn

- `block_value_box()` is a dashboard-specific composition primitive;
  shadcn offers similar metric cards as block patterns rather than a
  dedicated export.

## Reference screenshot

![Value box](_screenshots/value-box.png)

Captured from <https://ui.shadcn.com/blocks> on 2026-05-11.
Refresh and update the date whenever shadcn updates the canonical look.
