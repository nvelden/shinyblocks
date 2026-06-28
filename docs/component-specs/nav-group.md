# Nav Group

> Shinyblocks function: `block_nav_group()`
> Shadcn reference: <https://ui.shadcn.com/docs/components/sidebar>
> Status: R-side collapsible sidebar group for nested nav items.

## States

- **expanded** — trigger button has `aria-expanded="true"` and controls a
  visible `.sb-nav-group-items` region containing leaf `block_nav_item()`
  children.
- **collapsed** — trigger button has `aria-expanded="false"` and the items
  region carries `hidden`, keeping nested leaves out of the tab order.
- **nav-input child** — the group never carries `data-value`; only nested leaf
  items report values through the parent `block_nav(id = ...)`.

## R API

| Argument | Purpose |
| --- | --- |
| `label` | Group trigger text and accessible label for the child region. |
| `...` | One or more leaf `block_nav_item()` children; named arguments become group container attributes. |
| `icon` | Optional leading icon tag or vendored icon name. |
| `value` | Optional group identity stored as `data-sb-nav-group-value`; not an input value. |
| `expanded` | Initial disclosure state. |
| `class` | Extra classes for `.sb-nav-group`. |

## Stable Shell Hooks

`block_nav_group()` owns `.sb-nav-group`, `.sb-nav-group-trigger`, and
`.sb-nav-group-items`. Expansion state is mirrored through `data-expanded`,
`aria-expanded`, `data-state`, and the `hidden` attribute.

## Accessibility

- Trigger is a `<button>` with `aria-controls` pointing at the controlled items
  region.
- The items region renders `role="group"` and uses the text label as its
  accessible name.
- Collapsed groups use `hidden` so nested leaves are not focusable.

## Token Contract

| Visual role | Token |
| --- | --- |
| Text | `--foreground` |
| Hover/expanded surface | `--accent` |
| Hover/expanded text | `--accent-foreground` |
| Focus ring | `--ring` |

## Deliberate Divergences From Shadcn

- The group is an R-side composition primitive, not a React sidebar provider
  child. It preserves the existing `block_nav()` input binding.

## Reference Screenshot

![Nav group](_screenshots/nav.png)

Captured from <https://ui.shadcn.com/docs/components/sidebar> on 2026-05-11.
