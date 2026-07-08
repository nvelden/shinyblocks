# Breadcrumb Ellipsis

> Shinyblocks function: `block_breadcrumb_ellipsis()`
> Shadcn reference: <https://ui.shadcn.com/docs/components/breadcrumb>
> Status: R-side composition primitive; child of [breadcrumb](breadcrumb.md),
> marked `data-sb-child="breadcrumb-ellipsis"` for parent validation.

## States

- **default** — a decorative `more-horizontal` sprite icon inside
  `<span class="sb-breadcrumb-ellipsis" role="presentation"
  aria-hidden="true">`, followed by a visually hidden label
  (`.sb-breadcrumb-sr-only`, default "More") for assistive technology.

## R API

| Argument | Purpose |
| --- | --- |
| `label` | Visually hidden text announced in place of the collapsed entries. |
| `class` | Extra classes merged onto the `.sb-breadcrumb-item` `<li>`. |

## Composition contract

Stamps `data-sb-child="breadcrumb-ellipsis"`; accepted anywhere a
breadcrumb item is, with separators auto-inserted around it by
`block_breadcrumb()`.

## Token contract

| Visual role | Token |
| --- | --- |
| Ellipsis glyph | `--muted-foreground` (inherited from the trail) |

## Deliberate divergences from shadcn

- No dropdown-menu pairing (shadcn demos expand the ellipsis via
  `DropdownMenu`, which shinyblocks does not ship yet — issue #86); the
  marker is purely presentational in v1.

## Reference screenshot

Pending — covered by the parent [breadcrumb](breadcrumb.md) screenshot.
