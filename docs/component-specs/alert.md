# Alert

> Shinyblocks function: `block_alert()`
> Shadcn reference: <https://ui.shadcn.com/docs/components/alert>
> Status: Runtime composition primitive; Phase 7 spec refreshed around
> shipped variant + slot contract and `block_alert_title()` /
> `block_alert_description()` composition.

## States

- **default** — bordered surface with optional leading icon, title,
  and description.
- **destructive** — destructive-tinted border and foreground treatment.
- **with icon** — grid shifts to icon + content layout.
- **without icon** — content occupies the full width.
- **content** — title and description stack inside the content region.

## R API

| Argument | Purpose |
| --- | --- |
| `title` | Alert title. String, tag, or prebuilt `block_alert_title()`. Required for accessibility. |
| `...` | Additional alert body content. |
| `description` | Optional description. Same auto-wrap rules as title. |
| `icon` | Optional icon tag or vendored icon name. Defaults to `"info"`. Forced to `inline-start` placement. Pass `NULL` to omit. |
| `variant` | One of `default`, `destructive`. |
| `class` | Extra classes merged onto the runtime wrapper. |

## Runtime mapping

| R input | Runtime payload |
| --- | --- |
| `title` | `props$titleHtml` |
| `description` | `props$descriptionHtml` |
| `...` | `props$contentHtml` |
| `icon` | `props$iconHtml` |
| `variant` | `props$variant` |
| `class` | `className` |

Title and description tags carrying `data-sb-child="alert-title"` /
`data-sb-child="alert-description"` are reused in place; bare strings
get wrapped automatically.

## Accessibility

- `title` is required so screen readers always announce a heading.
- The runtime emits `role="alert"` so updates are surfaced through
  assistive tech.

## Token contract

| Visual role | Token |
| --- | --- |
| Surface | `--card` |
| Text | `--card-foreground` |
| Border | `--border` |
| Destructive foreground | `--destructive` |
| Destructive border | `--destructive` |

## Deliberate divergences from shadcn

- `block_alert()` uses explicit wrapper nodes for icon and content
  instead of relying on nested `[&>svg]` selectors.
- The layout is always a two-column grid shell even when the icon is
  omitted; content still reads correctly but does not fully collapse
  to shadcn's single-column shape.

## Reference screenshot

![Alert](_screenshots/alert.png)

Captured from <https://ui.shadcn.com/docs/components/alert> on 2026-05-11.
Refresh and update the date whenever shadcn updates the canonical look.
