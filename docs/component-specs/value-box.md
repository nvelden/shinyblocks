# Value Box

> Shinyblocks function: `block_value_box()`
> Shadcn reference: <https://ui.shadcn.com/blocks>

## States

- **default** — compact metric card with title, primary value, and
  optional description.
- **with-icon** — optional leading metric icon.
- **with-extra-body** — supports supplementary body content below the
  main value.

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
