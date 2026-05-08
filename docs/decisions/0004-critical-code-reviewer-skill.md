# ADR 0004: Critical Code Reviewer Skill

## Status

Accepted

## Context

`shinyblocks` will be developed through iterative agent work. As the package grows, review tasks should be handled with a consistent standard that emphasizes correctness, regressions, tests, accessibility, package maintainability, and user-facing behavior.

The Posit `critical-code-reviewer` skill provides focused instructions for direct, evidence-based code review.

## Decision

Install the Posit `critical-code-reviewer` skill into:

- `.agents/skills/critical-code-reviewer`
- `.claude/skills/critical-code-reviewer`

Keep it project-local so Codex and Claude use the same review posture when reviewing package changes.

## Consequences

- Agents should use this skill when asked for code reviews, PR reviews, critiques, or risk-focused assessments.
- Review output should lead with concrete findings and file references.
- Routine implementation work should still use the shadcn and R package development skills as appropriate.
