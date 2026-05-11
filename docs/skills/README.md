# Project-local agent skills

Skill files authored in this repo and intended for use by AI agents
working on `shinyblocks`. Each `.md` here is the **canonical** copy
that travels with the repo via git.

## Available skills

- [`shinyblocks-component.md`](shinyblocks-component.md) — end-to-end
  recipe for adding (or refactoring) a `block_*()` component:
  per-gate sync rule, shadcn-fidelity workflow, visual-parity
  harness template, common pitfalls, and pre-commit checklist.

## How to install

Skill discovery depends on the agent runtime. The repo's convention
(see `.gitignore`) keeps `.claude/`, `.agents/`, `CLAUDE.md`,
and `AGENTS.md` out of git — they're maintainer-local. To register a
skill from this directory into your local Claude Code / Codex /
similar agent, mirror it into the locations the runtime expects:

```bash
# Claude Code (current convention)
mkdir -p .claude/skills/shinyblocks-component
cp docs/skills/shinyblocks-component.md \
   .claude/skills/shinyblocks-component/SKILL.md

# Codex equivalent
mkdir -p .agents/skills/shinyblocks-component
cp docs/skills/shinyblocks-component.md \
   .agents/skills/shinyblocks-component/SKILL.md
```

After mirroring, the agent should pick the skill up automatically on
the next launch and trigger it on matching prompts ("add a
component", "port shadcn X to shinyblocks", etc. — see the skill's
description for the full trigger list).

If one mirror path is not writable in your local runtime, the other is
still useful. The repo's `make skills-install` target treats the
mirrors as best-effort rather than failing the whole setup.

## When to edit

Edit `docs/skills/<name>.md` (the tracked file). If you have local
mirrors under `.claude/skills/` and `.agents/skills/`, re-copy after
each edit, or run `make skills-install`.

## Why not commit `.claude/skills/` directly?

The `.claude/` and `.agents/` directories also hold agent runtime
caches, machine-local settings, and skills installed from upstream
(`r-package-development`, `critical-code-reviewer`, etc., tracked
via `skills-lock.json`). Mixing project-authored skills into those
trees confuses the install/refresh story. Keeping the canonical copy
under `docs/skills/` and treating `.claude/skills/<name>/` as a
local mirror is the simplest separation.
