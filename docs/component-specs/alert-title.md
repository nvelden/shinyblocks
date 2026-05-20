# Alert Title

> Shinyblocks function: `block_alert_title()`
> Shadcn reference: <https://ui.shadcn.com/docs/components/alert>
> Status: R-side composition primitive; Phase 7 spec refreshed around
> the `data-sb-child="alert-title"` marker used by `block_alert()` for
> region detection.

## States

- **default** — medium-weight compact title text rendered as
  `<h5 class="sb-alert-title">` inside the alert.
- **composed** — intended to be passed as `block_alert(title = ...)`
  either as a prebuilt tag or as a bare string (which is auto-wrapped).

## R API

| Argument | Purpose |
| --- | --- |
| `...` | Title content. |
| `class` | Extra classes merged onto the `.sb-alert-title` element. |

## Composition contract

Stamps `data-sb-child="alert-title"`. `block_alert()` reuses prebuilt
title tags carrying this marker; bare strings get wrapped
automatically.

## Token contract

| Visual role | Token |
| --- | --- |
| Title text | inherits alert foreground |

## Deliberate divergences from shadcn

- shadcn does not expose a standalone AlertTitle docs page; this is a
  composition helper around the alert content contract.

## Reference screenshot

![Alert title](_screenshots/alert-title.png)

Captured from <https://ui.shadcn.com/docs/components/alert> on 2026-05-11.
Refresh and update the date whenever shadcn updates the canonical look.
