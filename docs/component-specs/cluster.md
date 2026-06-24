# Cluster

> Shinyblocks function: `block_cluster()`
> Shadcn reference: <https://ui.shadcn.com/blocks>
> Status: R-side composition primitive.

## States

- **default** — wrapping horizontal group with centered items and a small gap.
- **distributed** — start, center, end, or space-between justification.
- **nowrap** — one horizontal row when `wrap = FALSE`.

## R API

| Argument | Purpose |
| --- | --- |
| `...` | Ordered child content. |
| `gap` | Semantic spacing: `"sm"`, `"md"`, or `"lg"`. |
| `align` | Cross-axis alignment. |
| `justify` | Main-axis distribution. |
| `wrap` | Whether children may wrap. |
| `class` | Additional classes. |

## Accessibility

- Renders a plain `<div>` and adds no false role or landmark.
- Wrapping does not change child order or keyboard order.

## Token contract

| Visual role | Token |
| --- | --- |
| Small gap | `--sb-layout-gap-sm` → `--sb-control-gap` |
| Medium gap | `--sb-layout-gap-md` → `--sb-overlay-gap` |
| Large gap | `--sb-layout-gap-lg` → `--sb-surface-gap` |

## Deliberate divergences from shadcn

- Shadcn blocks compose flex, alignment, wrapping, and gap utilities directly;
  shinyblocks exposes the repeated pattern as an R helper.

## Reference screenshot

![Cluster](_screenshots/cluster.png)

Composed from <https://ui.shadcn.com/blocks> layout conventions on 2026-06-24.
