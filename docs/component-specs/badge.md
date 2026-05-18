# Badge

> Shinyblocks function: `block_badge()`
> Shadcn reference: <https://ui.shadcn.com/docs/components/badge>

## States

- **default** — compact pill with token-driven fill and text.
- **hover** — interactive-looking variants keep their token treatment
  without adding a button/link runtime.
- **destructive** — destructive surface with white text and dark-mode
  dimming aligned to the shadcn contract.
- **outline** — transparent surface with bordered treatment.

## Token contract

| Visual role | Token |
| --- | --- |
| Default surface | `--primary` |
| Default text | `--primary-foreground` |
| Secondary surface | `--secondary` |
| Secondary text | `--secondary-foreground` |
| Outline border | `--border` |
| Destructive surface | `--destructive` |
| Destructive text | `--destructive-foreground` |
| Focus ring | `--ring` |

## Deliberate divergences from shadcn

- `block_badge()` is a plain content primitive; if a consumer wants a
  clickable badge, they compose that outside the helper.

## Parity normalisation notes

The runtime CSS and the Tailwind v4 reference page produce visually
identical badges but differ in two computed-style idioms. Both are
normalised in `tools/parity/normalise.mjs`:

- **`border-radius`** — Tailwind v4 emits `rounded-full` as
  `calc(infinity * 1px)`, which Chromium computes to ~`3.35544e+07px`.
  The runtime uses an explicit `9999px`. Any `border-radius >= 9999px`
  collapses to the sentinel `"pill"` for diffing.
- **`display`** — Tailwind v4 emits `inline-flex` using the two-value
  syntax `display: inline flex`, which Chromium's `getComputedStyle`
  reports as `flex`. The runtime uses single-keyword `inline-flex`.
  Both yield an inline-level flex container; the normaliser collapses
  `flex`, `inline-flex`, and `inline flex` to canonical `inline-flex`.

The dark-mode destructive tint (`color-mix(... 60%, transparent)`) is
implemented in `frontend/src/styles/runtime.css` to match
`dark:bg-destructive/60` upstream.

## Reference screenshot

![Badge](_screenshots/badge.png)

Captured from <https://ui.shadcn.com/docs/components/badge> on 2026-05-11.
Refresh and update the date whenever shadcn updates the canonical look.
