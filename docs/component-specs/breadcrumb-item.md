# Breadcrumb Item

> Shinyblocks function: `block_breadcrumb_item()`
> Shadcn reference: <https://ui.shadcn.com/docs/components/breadcrumb>
> Status: R-side composition primitive; child of [breadcrumb](breadcrumb.md),
> marked `data-sb-child="breadcrumb-item"` for parent validation.

## States

- **link** — `href` renders `<a class="sb-breadcrumb-link">` in muted
  foreground, transitioning to `--foreground` on hover.
- **current page** — `current = TRUE` renders
  `<span class="sb-breadcrumb-page" role="link" aria-disabled="true"
  aria-current="page">` in full foreground. `href` is ignored.
- **plain text** — neither `href` nor `current`: a muted
  `<span class="sb-breadcrumb-text">`.

## R API

| Argument | Purpose |
| --- | --- |
| `label` | Entry label (string or `htmltools` tag). |
| `href` | Destination URL; ignored when `current = TRUE`. |
| `current` | Marks the current page with `aria-current="page"`. |
| `class` | Extra classes merged onto the `.sb-breadcrumb-item` `<li>`. |

## Composition contract

Stamps `data-sb-child="breadcrumb-item"`; `block_breadcrumb()` validates
children by this marker and auto-inserts separators between them.

## Token contract

| Visual role | Token |
| --- | --- |
| Link / plain text | `--muted-foreground` |
| Link hover / current page | `--foreground` |

## Deliberate divergences from shadcn

- Folds shadcn's `BreadcrumbItem`, `BreadcrumbLink`, and
  `BreadcrumbPage` into a single constructor; the variant is chosen from
  `href`/`current` instead of composing three components.

## Reference screenshot

Pending — covered by the parent [breadcrumb](breadcrumb.md) screenshot.
