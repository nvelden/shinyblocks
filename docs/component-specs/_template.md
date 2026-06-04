# <Component name>

> Shinyblocks function: `block_<name>()`
> Shadcn reference: <https://ui.shadcn.com/docs/components/<slug>>
>
> Every exported `block_*()` has a spec at this shape. Keep it tight — five
> sections, ~30 lines. Verbosity defeats the purpose.

## States

The visual states this component must render correctly. Quality Gate
item 15 walks each one against the showcase.

- **default** — …
- **hover** — …
- **focus-visible** — …
- *(other states as applicable: active, disabled, selected, open, invalid)*

## Token contract

Map visual roles to the semantic CSS variables that drive them. If a
role uses a hard-coded value rather than a token, that's a divergence
and goes in the next section.

| Visual role | Token |
| --- | --- |
| Surface | `--…` |
| Foreground | `--…` |
| Border | `--…` |
| Focus ring | `--ring` |

## Deliberate divergences from shadcn

Anywhere shinyblocks knowingly differs from the shadcn reference, with
reasoning. Empty list = "matches shadcn".

- *(none)*

## Reference screenshot

![<component>](_screenshots/<slug>.png)

Captured from the shadcn docs page on YYYY-MM-DD. Refresh and update
the date when shadcn updates the canonical look.
