# Dark Mode Toggle

> Shinyblocks function: `block_dark_mode_toggle()`
> Shadcn reference: dark-mode toggle pattern built from Button +
> theme switching conventions

## States

- **default** — outline button with sun icon and label.
- **dark** — moon icon becomes visible when the document theme resolves
  to dark.
- **hover** — follows outline button hover treatment.
- **focus-visible** — follows the shared `--ring` outline contract.
- **pressed** — `aria-pressed` reflects whether dark mode is active.

## Token contract

| Visual role | Token |
| --- | --- |
| Surface | `--background` |
| Border | `--input` |
| Hover fill | `--accent` |
| Hover text | `--accent-foreground` |
| Focus ring | `--ring` |

## Deliberate divergences from shadcn

- shadcn does not ship a canonical standalone dark-mode-toggle
  component; this is a shinyblocks convenience wrapper built from the
  same button + theme conventions.

## Reference screenshot

![Dark mode toggle](_screenshots/dark-mode-toggle.png)

Capture pending — use the canonical shadcn button styling paired with a
theme toggle treatment, then refresh when the look changes.
