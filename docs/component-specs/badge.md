# Badge

> Shinyblocks function: `block_badge()`
> Shadcn reference: <https://ui.shadcn.com/docs/components/badge>

## States

- **default** — compact pill with token-driven fill and text.
- **hover** — interactive-looking variants keep their token treatment
  without adding a button/link runtime.
- **destructive** — destructive surface with white text and dark-mode
  dimming aligned to the shadcn contract.
- **outline** — transparent surface with bordered treatment.

## Token contract

| Visual role | Token |
| --- | --- |
| Default surface | `--primary` |
| Default text | `--primary-foreground` |
| Secondary surface | `--secondary` |
| Secondary text | `--secondary-foreground` |
| Outline border | `--border` |
| Destructive surface | `--destructive` |
| Destructive text | `--destructive-foreground` |
| Focus ring | `--ring` |

## Deliberate divergences from shadcn

- `block_badge()` is a plain content primitive; if a consumer wants a
  clickable badge, they compose that outside the helper.

## Reference screenshot

![Badge](_screenshots/badge.png)

Capture pending — use the canonical shadcn badge docs page once the
reference screenshot pass resumes.
