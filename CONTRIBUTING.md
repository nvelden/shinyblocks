# Contributing to shinyblocks

Thanks for considering a contribution. shinyblocks is an R package that
brings shadcn/ui-inspired design to Shiny. The conventions below keep
the package coherent with shadcn upstream and idiomatic for R.

## Local setup

Install development dependencies, then run:

```r
devtools::load_all()
devtools::test()
```

Before opening a pull request, run:

```r
devtools::document()
devtools::check()
```

If `devtools` is unavailable, use `R CMD check .`.

## R API conventions

- Public functions return `htmltools::tag` or
  `htmltools::tagList` objects. They never have side effects beyond
  emitting HTML.
- Function names are `block_*`, snake_case.
- Every exported function accepts `class = NULL` and merges via
  `merge_classes()` — package classes are appended, never overwritten
  by user input.
- `htmltools::htmlDependency()` is always wrapped in a function
  (e.g. `shinyblocks_dependency()`), never bound to a top-level
  variable. Top-level bindings bake the install path into the
  binary build and break across machines.
- Components with internal regions expose every region as its own
  primitive: `block_card_header()`, `block_card_title()`, etc. A
  flat-argument convenience form may exist but composes into the
  same primitives internally.
- Group/Item composition is validated at call time via
  `validate_children()`. `block_nav_item()` outside `block_nav()`
  must produce a clear R error, not silent broken markup.
- Variants and sizes are validated R arguments
  (`match.arg()`-style), not free-form strings.
- Required accessibility arguments (`title`, `label`) have no
  defaults and error if missing.
- `block_button()` has no `loading=` or `pending=` argument.
  Loading state is composed: pass `block_spinner()` as `icon`,
  set `disabled = TRUE`. This matches shadcn upstream.

## CSS authoring conventions

Package CSS lives under `inst/www/` and is shipped with the package.

- **Use semantic tokens, never raw colors.** `bg-primary`,
  `text-muted-foreground`, `border-border`. Never `bg-emerald-600`,
  `text-zinc-700`, or hex values inline.
- **Use `gap-*`, never `space-x-*` or `space-y-*`.** For vertical
  stacks: `flex flex-col gap-4`.
- **Use `size-*` when width and height are equal.** `size-10`, not
  `w-10 h-10`.
- **Use `truncate`** for single-line ellipsis, not the long-form
  `overflow-hidden text-ellipsis whitespace-nowrap`.
- **No manual `dark:` color overrides.** The token system handles
  light/dark via the `:root` and `[data-theme="dark"]` blocks; if a
  dark variant is wrong, fix the token, not the component rule.
- **No manual `z-index`** on overlay components. Their stacking is
  handled centrally so layered overlays don't conflict.
- **`className` is for layout, not styling.** Components own their
  colors and typography. A user passing `class = "bg-blue-500"`
  should not be able to override `bg-card` on a card.

## Icon conventions

- `block_icon()` accepts a Lucide icon name (string) validated
  against the vendored sprite, or an `htmltools::tag` to inject a
  custom SVG.
- Icons inside components emit `data-icon="inline-start"` or
  `data-icon="inline-end"`.
- Icon helpers and component CSS never emit `size-*` classes on
  icons. Each component sizes its own icons in CSS.

## Roxygen conventions

Every exported function has:

- `@param` for every argument, including `...` and `class`.
- `@return` describing the returned tag shape.
- `@export`.
- At least one runnable `@examples` block. Use `\dontrun{}` only
  when the example genuinely cannot run (e.g., requires a session).
- A `@family` tag grouping related components so pkgdown's "see
  also" links generate correctly.
- `@seealso` to point at related Shiny primitives where useful.

Internal helpers use `@noRd`.

## Tests

- Self-sufficient tests; use `withr` for cleanup where needed.
- Snapshot tests sparingly — prefer attribute and class assertions
  over snapshot diffs when the HTML is small.
- Every exported function gets:
  - a tag-shape test,
  - an argument-validation test,
  - an ARIA-attribute test (where relevant),
  - a `class =` merge test.

## Commit and PR conventions

- One logical change per commit. Use a tidy commit on `main` rather
  than a stream of fixups.
- `devtools::document()` and `devtools::check()` should pass before
  opening a PR.

## Component scope

If you're proposing a new component, include the intended R API, the
HTML structure, accessibility behavior, tests, and a small runnable
example.

## Asking for help

Open an issue with the `question` label.
