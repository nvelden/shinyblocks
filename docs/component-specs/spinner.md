# Spinner

> Shinyblocks function: `block_spinner()`
> Shadcn reference: <https://ui.shadcn.com/docs/components/skeleton>
> Status: Runtime presentational component; Phase 7 spec refreshed
> around shipped accessible-label contract.

## States

- **default** — compact animated loading indicator with a scoped
  rotation animation under `[data-shinyblocks-root]`.
- **semantic colors** — optional foreground color class using the same
  semantic color choices as `block_icon()`.
- **accessible** — exposes `role="status"` and an `aria-label` so
  screen readers announce the loading state.

## R API

| Argument | Purpose |
| --- | --- |
| `label` | Accessible label. Defaults to `"Loading"`. |
| `size` | Spinner size: `"default"`, `"sm"`, or `"lg"`. |
| `color` | Semantic foreground color: `"default"`, `"muted"`, `"primary"`, `"destructive"`, `"success"`, `"warning"`, or `"info"`. |
| `class` | Extra classes merged onto the runtime wrapper. |
| `style` | Optional inline custom styles. |

## Runtime mapping

| R input | Runtime payload |
| --- | --- |
| `label` | `props$label` → `aria-label` |
| `size` | `props$size` → `.sb-spinner-size-*` |
| `color` | `props$color` → `.sb-spinner-color-*` |
| `class` | `className` |
| `style` | `style` |

## Token contract

| Visual role | Token |
| --- | --- |
| Default spinner stroke | `--foreground` |
| Muted spinner stroke | `--muted-foreground` |
| Primary spinner stroke | `--primary` |
| Destructive spinner stroke | `--destructive` |
| Success spinner stroke | `--success-foreground` |
| Warning spinner stroke | `--warning-foreground` |
| Info spinner stroke | `--info-foreground` |

## Deliberate divergences from shadcn

- shadcn does not ship a dedicated spinner primitive. shinyblocks adds
  one for Shiny loading states while keeping the same token language
  and animation timing as the runtime skeleton.

## Reference screenshot

![Spinner](_screenshots/spinner.png)

Captured from <https://ui.shadcn.com/docs/components/skeleton> on 2026-05-11.
Refresh and update the date whenever shadcn updates the canonical look.
