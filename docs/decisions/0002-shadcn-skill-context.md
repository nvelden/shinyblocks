# ADR 0002: shadcn Skill Context

## Status

Accepted

## Context

The official shadcn/ui skill gives AI agents detailed knowledge of shadcn component APIs, composition rules, CLI commands, theming, registry authoring, and accessibility conventions. The skill activates when it sees a `components.json` file and can run `shadcn info --json` for project context.

`shinyshadcn` is not a React project. It is an R package that should translate shadcn-inspired patterns into Shiny and `htmltools`.

## Decision

Install the official `shadcn` skill into:

- `.agents/skills/shadcn`
- `.claude/skills/shadcn`

Add minimal `components.json` and `package.json` files at the repository root so Codex, Claude, and the shadcn CLI can read project context.

Exclude those files from the R package build with `.Rbuildignore`.

## Consequences

- Agents can use current shadcn rules and docs while working in this repo.
- The package remains R-first and does not gain a required Node or React runtime.
- Agents must not run `shadcn add` into implementation directories unless a later ADR approves generated React source as reference material.
- The shadcn CLI may still be useful for `info`, `docs`, `search`, and `view` while designing Shiny equivalents.
