# Alert

> Shinyblocks function: `block_alert()`
> Shadcn reference: <https://ui.shadcn.com/docs/components/alert>

## States

- **default** — bordered surface with optional leading icon, title, and
  description.
- **destructive** — destructive-tinted border and foreground treatment.
- **with icon** — grid shifts to icon + content layout.
- **without icon** — content occupies the full width.
- **content** — title and description stack inside the content region.

## Token contract

| Visual role | Token |
| --- | --- |
| Surface | `--card` |
| Text | `--card-foreground` |
| Border | `--border` |
| Destructive foreground | `--destructive` |
| Destructive border | `--destructive` |

## Deliberate divergences from shadcn

- `block_alert()` uses explicit wrapper nodes for icon and content
  instead of relying on nested `[&>svg]` selectors.
- The layout is always a two-column grid shell even when the icon is
  omitted; the content still reads correctly but does not fully collapse
  to the single-column shadcn shape.

## Reference screenshot

![Alert](_screenshots/alert.png)

Captured from <https://ui.shadcn.com/docs/components/alert> on 2026-05-11.
Refresh and update the date whenever shadcn updates the canonical look.
