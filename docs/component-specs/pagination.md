# Pagination

> Shinyblocks: `block_pagination()` / `update_block_pagination()`
> Shadcn: <https://ui.shadcn.com/docs/components/pagination>
> Status: Runtime form control (issue #94).

## States

- Default page links use a ghost button surface; the active page has an outline.
- Previous and next are disabled at their respective bounds.
- Ellipses replace hidden page ranges; disabled mode locks every button.
- Server updates can replace page count, selection, disabled state, class, and style.

## Runtime Mapping

| R argument | Runtime payload | Notes |
| --- | --- | --- |
| `input_id` | `id` | Drives `input$<id>`. |
| `pages` | `props.pages` | Positive integer; reductions clamp selection. |
| `selected` | `state.value` | Integer in `[1, pages]`. |
| `sibling_count` | `props.siblingCount` | Create-only page-window width. |
| `show_edges` | `props.showEdges` | Create-only first/last visibility. |
| `disabled` | `props.disabled` | Disables every page control. |

## Keyboard / A11y Contract

- Uses `nav[aria-label="pagination"]`, a list, and native buttons.
- The selected button carries `aria-current="page"`; all controls have names.
- Native tab, Enter, and Space behavior applies; disabled controls leave the tab order.

## Token Contract

- Text: `--foreground`; active border: `--border`; hover: `--accent` /
  `--accent-foreground`; ellipsis: `--muted-foreground`; focus: `--ring`.
- Radius follows the shared button-radius style token.

## Divergences From shadcn

- Page controls are buttons rather than anchors because the component reports a
  Shiny input value; URL routing remains app-owned.
- `pages`, selection, truncation, and disabled semantics are packaged into one
  opinionated control rather than exposed as low-level composition helpers.
