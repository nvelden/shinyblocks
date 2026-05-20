# Code

> Shinyblocks function: `block_code()`
> Shadcn reference: <https://ui.shadcn.com/docs/components/code>
>
> Per [ADR 0015](../decisions/0015-component-specs.md), every exported
> `block_*()` has a spec at this shape. Keep it tight — five sections,
> ~30 lines. Verbosity defeats the purpose.

## States

The visual states this component must render correctly. Quality Gate
item 15 walks each one against the showcase.

- **default** — Monospace pre-formatted text block. Variant "default" uses `--muted` background, variant "outline" uses transparent background with `--border`.
- **line numbers** — Vertical column of margins on the left of each code line displaying dynamic sequential indices via CSS counters.
- **absolute copy button** — Positioned absolutely in the top-right corner of the code pre-formatted display. Toggles outline on hover and scales slightly down on active click.
- **copied feedback** — Icon changes from standard copy to checkmark SVG with active color transition.
- **header (optional)** — Optional upper terminal bar containing macOS editor dots on the left, uppercase language label, and inline copy button.

## Token contract

Map visual roles to the semantic CSS variables that drive them. If a
role uses a hard-coded value rather than a token, that's a divergence
and goes in the next section.

| Visual role | Token |
| --- | --- |
| Container BG (default) | `var(--muted)` |
| Container BG (outline) | `transparent` |
| Border | `var(--border)` |
| Absolute Copy Button BG | `var(--background)` |
| Absolute Copy Button Hover BG | `var(--accent)` |
| Absolute Copy Button Hover text | `var(--accent-foreground)` |
| Line number text | `var(--muted-foreground)` |
| Text foreground | `var(--foreground)` |
| Language Label | `var(--muted-foreground)` |

## Deliberate divergences from shadcn

Anywhere shinyblocks knowingly differs from the shadcn reference, with
reasoning. Empty list = "matches shadcn".

- **Standard Purity Layout** — Matches the canonical look of the shadcn/ui documentation system featuring the precise `rehype-pretty-code` markup and copy behaviors natively.
- **Interactive Optional Terminal Window Layout** — Retains optional macOS editor dots and language badges as an aesthetic extension under `header = TRUE` to support richer developer dashboard UI use cases.

## Reference screenshot

![code](_screenshots/code.png)

Captured from the shadcn docs page on 2026-05-20. Refresh and update
the date when shadcn updates the canonical look.
