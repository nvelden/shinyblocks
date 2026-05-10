# Nav Item

> Shinyblocks function: `block_nav_item()`
> Shadcn reference: <https://ui.shadcn.com/docs/components/sidebar>

## States

- **default** — sidebar navigation link with optional leading icon.
- **hover** — accent-tinted hover treatment.
- **focus-visible** — component-owned 3px `--ring` focus ring.
- **selected** — `aria-current="page"` and selected styling.

## Token contract

| Visual role | Token |
| --- | --- |
| Text | `--foreground` |
| Hover/selected surface | `--accent` |
| Hover/selected text | `--accent-foreground` |
| Focus ring | `--ring` |

## Deliberate divergences from shadcn

- `block_nav_item()` is link-first and lightweight; it does not carry
  the full React sidebar menu-button runtime.

## Reference screenshot

![Nav item](_screenshots/nav-item.png)

Capture pending — use the canonical shadcn sidebar docs page once
screenshots are being captured.
