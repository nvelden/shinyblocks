# ADR 0003: R Package Development Skill

## Status

Accepted

## Context

`shinyblocks` is an R package. Agent work should follow R package conventions for exported APIs, tests, documentation, and checks. The Posit `r-package-development` skill provides focused guidance for `devtools`, `testthat`, `roxygen2`, formatting, `NEWS.md`, and package infrastructure.

## Decision

Install the Posit `r-package-development` skill into:

- `.agents/skills/r-package-development`
- `.claude/skills/r-package-development`

Keep it project-local so Codex and Claude can use the same R package development rules while working in this repository.

## Consequences

- Agents should use the R package skill for package structure, roxygen docs, tests, and checks.
- Agents should use the shadcn skill for UI component inspiration and conventions.
- When both skills apply, the R package skill governs package mechanics, while the shadcn skill informs component semantics and visual design patterns.
