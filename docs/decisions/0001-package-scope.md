# ADR 0001: Package Scope

## Status

Draft

## Context

The package should feel like a modern alternative to `shinydashboard`, with visual inspiration from shadcn/ui.

shadcn/ui is not a conventional dependency. It is a set of React/Tailwind/Radix component recipes. Shiny apps are usually authored in R and rendered with HTML dependencies. A direct port would pull in a frontend runtime and likely make the package harder to install and use.

## Decision

Start with R-first `htmltools` components and bundled CSS/JS assets.

Do not require React, Tailwind, Vite, or Node for package users in the first version.

## Consequences

- The package can be installed and used like a normal Shiny package.
- The implementation can reuse shadcn design tokens and interaction patterns without copying React internals.
- Some complex shadcn components may need simpler Shiny-specific equivalents.
- If a frontend build step becomes useful, it should be introduced through a later ADR.
