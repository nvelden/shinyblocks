# Breadcrumb

> Shinyblocks functions: `block_breadcrumb()` / `block_breadcrumb_item()` /
> `block_breadcrumb_ellipsis()`
> Shadcn reference: <https://ui.shadcn.com/docs/components/breadcrumb>
> Status: R-side composition primitive (static htmltools markup, no runtime
> payload); added for issue #92.

## States

- **default** — `<nav aria-label="breadcrumb">` landmark wrapping an
  `<ol>` of entries in small muted text; a decorative chevron separator
  sits between consecutive entries.
- **link** — entries with `href` render `<a class="sb-breadcrumb-link">`
  in muted foreground that transitions to `--foreground` on hover.
- **current page** — `current = TRUE` renders a non-interactive
  `<span role="link" aria-disabled="true" aria-current="page">` in full
  foreground color. `href` is ignored for the current entry.
- **plain text** — an entry with neither `href` nor `current` renders a
  muted `<span class="sb-breadcrumb-text">`.
- **collapsed middle** — `block_breadcrumb_ellipsis()` renders a
  decorative `more-horizontal` icon (`role="presentation"`,
  `aria-hidden="true"`) with a visually hidden label (default "More")
  for assistive technology.

## Structure Mapping

| R call | Markup |
| --- | --- |
| `block_breadcrumb(...)` | `nav.sb-breadcrumb[aria-label="breadcrumb"] > ol.sb-breadcrumb-list` |
| `block_breadcrumb_item()` | `li.sb-breadcrumb-item[data-sb-child="breadcrumb-item"]` |
| `block_breadcrumb_ellipsis()` | `li.sb-breadcrumb-item[data-sb-child="breadcrumb-ellipsis"]` |
| auto-inserted separator | `li.sb-breadcrumb-separator[role="presentation"][aria-hidden="true"]` |

- Children are validated by their `data-sb-child` marker; anything other
  than items/ellipses errors at build time, as does an empty trail.
- `separator` accepts a single string (e.g. `"/"`) or an `htmltools`
  tag; the default is the sprite `chevron-right` icon. Separators are
  list entries hidden from assistive technology, matching shadcn.

## Accessibility

- Landmark: `nav[aria-label="breadcrumb"]`.
- Current page: `aria-current="page"` on a `span` exposed as a disabled
  link (`role="link"` + `aria-disabled="true"`), matching shadcn's
  `BreadcrumbPage`.
- Separators and the ellipsis glyph carry `role="presentation"` +
  `aria-hidden="true"`; the ellipsis adds a visually hidden text
  alternative (`.sb-breadcrumb-sr-only`, default "More").

## Token Contract

| Visual role | Token |
| --- | --- |
| Trail text / links / separators | `--muted-foreground` |
| Link hover | `--foreground` |
| Current page | `--foreground` |

## Deliberate Divergences From Shadcn

- Separators are inserted automatically between entries instead of
  requiring manual `<BreadcrumbSeparator />` children; `separator =`
  customizes the glyph for the whole trail.
- `BreadcrumbLink`'s `asChild` composition has no R equivalent; `label`
  accepts an `htmltools` tag for custom content instead.
- No Shiny input integration in v1 (issue #92 left it optional):
  entries are static links. A future slice can wire the trail into the
  `block_nav()` selection model if app demand appears.
- No dropdown-menu integration for the ellipsis (shadcn demos pair it
  with `DropdownMenu`, which shinyblocks does not ship yet — issue #86).

## Reference Screenshot

Pending — capture and add under `_screenshots/breadcrumb.png` during the
next screenshot refresh.
