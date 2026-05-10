# Body

> Shinyblocks function: `block_body()`
> Shadcn reference: <https://ui.shadcn.com/blocks>

## States

- **default** — main content landmark for the page shell.
- **with-sidebar-layout** — sits inside `.sb-page-main` beside the
  optional sidebar/header shell.

## Token contract

| Visual role | Token |
| --- | --- |
| Surface | `--background` |
| Foreground | `--foreground` |

## Deliberate divergences from shadcn

- `block_body()` is a semantic layout helper; shadcn block examples use
  plain container markup instead of a named primitive.

## Reference screenshot

![Body](_screenshots/body.png)

Capture pending — use a representative shadcn block content area once
the reference screenshot pass resumes.
