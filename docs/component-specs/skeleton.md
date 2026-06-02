# Skeleton

> Shinyblocks function: `block_skeleton()`
> Shadcn reference: <https://ui.shadcn.com/docs/components/skeleton>
> Status: Runtime presentational component with HTML attribute
> passthrough; Phase 7 spec refreshed around shipped runtime attrs
> contract.

## States

- **default** — animated muted placeholder block with scoped pulse
  animation under `[data-shinyblocks-root]`.
- **custom-size** — caller controls dimensions through extra inline
  styles, classes, or HTML attributes.
- **decorative** — always `aria-hidden="true"`.

## R API

| Argument | Purpose |
| --- | --- |
| `class` | Extra classes merged onto the runtime wrapper. |
| `...` | Additional HTML attributes passed through to the runtime element. `style` is normalised. `class` from `...` is merged with the `class` argument. |

## Runtime mapping

| R input | Runtime payload |
| --- | --- |
| `...` HTML attrs | `props$attrs` (object of attr name → value) |
| `class` + `...$class` | `className` (merged) |

## Token contract

| Visual role | Token |
| --- | --- |
| Placeholder surface | `--accent` |

## Deliberate divergences from shadcn

- The runtime element is a `<div>` with attrs passthrough rather than
  a framework-specific utility component. Sizing comes from CSS
  classes or inline style.

## Reference screenshot

![Skeleton](_screenshots/skeleton.png)

Captured from <https://ui.shadcn.com/docs/components/skeleton> on 2026-05-11.
Refresh and update the date whenever shadcn updates the canonical look.
