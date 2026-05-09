# Shadcn Fidelity Audit (2026-05-09)

## Goal

Take every exported `block_*()` and verify it matches its shadcn
counterpart at the level of tokens, classes, states, and hover/focus
treatment — not just "looks roughly right".

Per [ADR 0015](../decisions/0015-component-specs.md), the long-term
mechanism is one spec doc per component plus a captured reference
screenshot. This audit is the first systematic pass *building toward*
those specs and surfacing the drift backlog.

## Method

For each component, fetch the canonical shadcn source from the
`apps/v4/registry/new-york-v4/ui/<name>.tsx` path of
[`shadcn-ui/ui`](https://github.com/shadcn-ui/ui) (the `new-york-v4`
registry is the current default). Compare:

1. Base classes — geometry, typography, transition, focus.
2. Variant strings — fill, foreground, hover, dark-mode.
3. Size strings — height, padding, gap.
4. State coverage — hover, focus-visible, disabled, aria-invalid,
   data-[state=...], data-[orientation=...].
5. SVG sizing — both nested-selector and explicit-class forms.

Then walk each state on the live showcase
(`http://127.0.0.1:4321`) against the shadcn docs page in light and
dark mode.

## 2026-05-09 findings

### Button

**Drifts found:**

| Drift | shadcn | shinyblocks (before) | Fix |
| --- | --- | --- | --- |
| Link variant has no colour | `text-primary underline-offset-4` | `underline-offset-4` only | **Fixed**: added `text-primary` |
| Outline variant flat | `border bg-background shadow-xs ...` | `border border-input bg-background` | **Fixed**: added `shadow-xs` |
| Destructive label colour | `text-white` | `text-destructive-foreground` | **Fixed**: now `text-white` |
| Destructive dark mode | `dark:bg-destructive/60` | unchanged | **Fixed**: `[data-theme="dark"]` rule dims to 60% |
| Secondary hover ratio | `hover:bg-secondary/80` | 85% mix | **Fixed**: now 80% |

**Pending (deferred — bigger surface):**

| Drift | Why deferred |
| --- | --- |
| Focus-visible uses `outline 2px` not shadcn's 3px ring | Global rule in `.sb-app *:focus-visible` affects every component; switching to per-component `border-ring + ring-[3px] + ring-ring/50` requires removing the global rule and re-adding per-component focus styles. Own slice. |
| `aria-invalid:border-destructive aria-invalid:ring-destructive/20` | New state across every interactive component. Pair with the focus-ring redesign so both ship together. |
| `transition-colors` vs `transition-all` | Cosmetic; matters once the focus-ring animates. Pair with above. |
| `has-[>svg]:px-3` size-aware padding | Tailwind v4 has-selector; needs verification that compiled output matches. Low priority. |

### Badge

**Drifts fixed in this commit:**

| Drift | shadcn | shinyblocks (before) |
| --- | --- | --- |
| **Shape** | `rounded-full` | `rounded-md` |
| **Font size** | `text-xs` | `text-sm` |
| Gap | `gap-1` | none (no SVG support) |
| `w-fit` for shrink-wrap | yes | no |
| `overflow-hidden` | yes | no |
| Border on base | `border border-transparent` | per-variant `border-transparent` |
| Destructive label | `text-white` + `dark:bg-destructive/60` | `text-destructive-foreground` |

The shape change is the most visible — pill vs rectangle — and is
the headline regression that needed fixing first.

**Pending:**

- `[a&]:hover:bg-primary/90` — only hover when wrapped in an anchor.
  shinyblocks badges aren't anchor-wrapped today; revisit when nav
  badges land.
- aria-invalid + focus-visible ring (same as button).

### Alert

shadcn moved alerts to a CSS-grid layout driven by `has-[>svg]`
selectors:

```
relative grid w-full grid-cols-[0_1fr] items-start gap-y-0.5
rounded-lg border px-4 py-3 text-sm
has-[>svg]:grid-cols-[calc(var(--spacing)*4)_1fr]
has-[>svg]:gap-x-3
[&>svg]:size-4 [&>svg]:translate-y-0.5 [&>svg]:text-current
```

shinyblocks alert uses `grid-template-columns: auto minmax(0, 1fr)`
unconditionally — visually similar but doesn't collapse to a single
column when there's no icon, and the icon offset is a separate
`pt-0.5` instead of `translate-y-0.5`. Cosmetic; not a parity bug.

**Pending:**

- Destructive variant: shadcn applies
  `*:data-[slot=alert-description]:text-destructive/90` to soften the
  description. shinyblocks doesn't differentiate.

### Tabs

**Major drift.** shadcn ships a data-attribute-driven Tabs that
supports two `data-variant` values (`default`, `line`), two
`data-orientation` values (`horizontal`, `vertical`), and an
`after:` pseudo-element for the line-variant active indicator.
shinyblocks tabs is built on top of Bootstrap's `.nav-link.active` /
`.tab-pane` model with CSS overrides — visually close to the default
shadcn variant, but the line variant, vertical orientation, and
focus-ring story are not present.

**Pending (own slice):**

- Migrate to data-attribute-driven markup (`data-state=active`,
  `data-orientation=...`, `data-variant=...`) so the CSS contract
  matches shadcn's.
- Add the line variant + vertical orientation.
- Replace the current Bootstrap-class-leaning hover treatment with
  shadcn's `hover:text-foreground` flat treatment.

### Select / textarea / checkbox / switch

Per [ADR 0014](../decisions/0014-wrap-by-default-form-inputs.md),
these are wrappers around native Shiny inputs. The visible "shadcn
look" comes from CSS that overrides Shiny's defaults. The current
implementation tracks shadcn's structural shape (custom checkbox
indicator div, sr-only native input, etc.) but has not been audited
state-by-state against shadcn's source. Pending — own slice.

## Plan from here

The audit is incremental. Each component gets its own slice that:

1. Pulls the shadcn source from the `apps/v4/registry/new-york-v4`
   path.
2. Lists every drift in this doc (or a follow-up dated audit doc).
3. Applies the safe drifts in CSS source.
4. Captures the reference screenshot from
   <https://ui.shadcn.com/docs/components/<name>> and commits it under
   `docs/component-specs/_screenshots/<slug>.png`.
5. Writes the spec doc per [ADR 0015](../decisions/0015-component-specs.md)
   and removes the entry from `backfill_pending_specs` in
   `tests/testthat/test-doc-coverage.R`.

### Cross-cutting follow-ups

These touch every interactive component and should ship as one slice
before tagging Phase 5:

- **Focus-visible redesign.** Drop the global
  `.sb-app *:focus-visible { outline: 2px solid var(--ring); }` rule.
  Add per-component
  `focus-visible:border-ring focus-visible:ring-[3px] focus-visible:ring-ring/50 outline-none`.
  Affects: button, badge (link/anchor), nav-item, tabs trigger,
  select trigger, checkbox/switch shells.
- **`aria-invalid` styling.** Add
  `aria-invalid:border-destructive aria-invalid:ring-destructive/20 dark:aria-invalid:ring-destructive/40`
  to every interactive base. Hooks into `block_field_invalid()`.
- **`transition-all` over `transition-colors`** so the new ring
  animates.

### Snapshot capture

Until shadcn exposes a stable static-asset URL per component, capture
manually:

1. Open `https://ui.shadcn.com/docs/components/<name>` in a clean
   browser window (default light theme, default zoom).
2. Render the canonical example shadcn shows above the fold —
   typically the default state plus a small variant grid.
3. Crop tight to the component, no surrounding chrome.
4. Save as `docs/component-specs/_screenshots/<slug>.png`.
5. Note the capture date in the spec doc.

The same flow works for dark-mode capture — toggle the shadcn site to
dark, capture, save as `_screenshots/<slug>-dark.png`.
