# Stack

> Shinyblocks function: `block_stack()`
> Shadcn reference: <https://ui.shadcn.com/blocks>
> Status: R-side composition primitive.

## States

- **default** — vertical flow, medium gap, stretched children.
- **aligned** — start, center, end, or stretch cross-axis alignment.
- **spaced** — small, medium, or large semantic layout gap.

## R API

| Argument | Purpose |
| --- | --- |
| `...` | Ordered child content. |
| `gap` | Semantic spacing: `"sm"`, `"md"`, or `"lg"`. |
| `align` | Cross-axis alignment. |
| `class` | Additional classes. |

## Accessibility

- Renders a plain `<div>` and adds no false role or landmark.
- Child semantics and document order are preserved.

## Token contract

| Visual role | Token |
| --- | --- |
| Small gap | `--sb-layout-gap-sm` → `--sb-control-gap` |
| Medium gap | `--sb-layout-gap-md` → `--sb-overlay-gap` |
| Large gap | `--sb-layout-gap-lg` → `--sb-surface-gap` |

Default-scope `block_style()` tokens reach stacks through `.sb-app`. A style
scoped only to a runtime root does not affect sibling R-side primitives.

## Deliberate divergences from shadcn

- Shadcn blocks compose `flex flex-col gap-*` utilities directly; shinyblocks
  exposes that recurring convention as an R helper.

## Reference screenshot

![Stack](_screenshots/stack.png)

Composed from <https://ui.shadcn.com/blocks> layout conventions on 2026-06-24.
