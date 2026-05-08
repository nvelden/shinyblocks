# ADR 0005: Testing R Packages Skill

## Status

Accepted

## Context

`shinyshadcn` needs focused, idiomatic tests as its public R API and UI helpers grow. The broader R package development skill covers package mechanics, while test design needs more specific guidance for `testthat` 3, fixtures, snapshots, mocking, cleanup, and test organization.

The Posit `testing-r-packages` skill provides these testing-specific conventions.

## Decision

Install the Posit `testing-r-packages` skill into:

- `.agents/skills/testing-r-packages`
- `.claude/skills/testing-r-packages`

Keep it project-local so Codex and Claude use the same testing guidance while working in this repository.

## Consequences

- Agents should use this skill when writing, organizing, or improving tests.
- The R package development skill remains the source for package-level workflow and checks.
- Testing changes should favor self-sufficient `testthat` 3 tests with explicit setup and cleanup.
