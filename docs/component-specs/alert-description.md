# Alert Description

> Shinyblocks function: `block_alert_description()`
> Shadcn reference: <https://ui.shadcn.com/docs/components/alert>
> Status: R-side composition primitive; Phase 7 spec refreshed around
> the `data-sb-child="alert-description"` marker used by `block_alert()`
> for region detection.

## States

- **default** — compact supporting text rendered as
  `<div class="sb-alert-description">` beneath the alert title.
- **destructive** — inherits the destructive context from the parent
  alert.
- **composed** — intended to be passed as `block_alert(description = ...)`
  either as a prebuilt tag or as a bare string.

## R API

| Argument | Purpose |
| --- | --- |
| `...` | Description content. |
| `class` | Extra classes merged onto the `.sb-alert-description` element. |

## Composition contract

Stamps `data-sb-child="alert-description"`. `block_alert()` reuses
prebuilt description tags carrying this marker; bare strings get
wrapped automatically.

## Token contract

| Visual role | Token |
| --- | --- |
| Description text | `--muted-foreground` |
| Destructive text | inherits parent destructive treatment |

## Deliberate divergences from shadcn

- shadcn does not expose a standalone AlertDescription docs page; this
  is a composition helper around the alert content contract.

## Reference screenshot

![Alert description](_screenshots/alert-description.png)

Captured from <https://ui.shadcn.com/docs/components/alert> on 2026-05-11.
Refresh and update the date whenever shadcn updates the canonical look.
