# Developer Notes

Postmortems and lessons learned during development. Each note
captures a real problem encountered while building shinyshadcn so the
next person (or the next AI agent session) doesn't repeat the same
investigation.

These are **not** ADRs — ADRs are forward-looking decisions ("we
will do X"). Notes here are retrospective ("we hit X, the fix is Y,
don't try Z again").

## When to write a note

Write a note when you spent more than ~30 minutes diagnosing a
problem whose root cause is not obvious from the resulting code. If
the fix is a one-liner with an obvious cause, a commit message is
enough. If the fix is small but the *reason* is non-obvious, write a
note.

Triggers:

- A test was failing for a reason unrelated to the test's subject.
- A Shiny / htmltools / bslib internal behavior surprised you.
- A Tailwind v4 directive interacted unexpectedly with a token.
- A pkgdown / shinytest2 / R CMD check tool produced a confusing
  diagnostic that took time to decode.
- You implemented something the obvious way, it broke, and the
  not-obvious way is what shipped.

Do **not** write a note when:

- The fix is the obvious one and the cause is in the code.
- The lesson belongs in CONTRIBUTING.md as a rule (write the rule
  there instead).
- The decision is forward-looking (write an ADR instead).

## How to write a note

1. Copy `TEMPLATE.md` to a new file:
   `YYYY-MM-DD-short-slug.md` under `docs/dev-notes/`.
2. Fill in the sections. Keep it short — one screen.
3. Link relevant commits, files, or upstream issues by URL.
4. Add an entry to the index below.
5. Commit with the relevant code change.

## Index

(Empty — populated as development proceeds.)

<!-- Format:
- [YYYY-MM-DD slug](YYYY-MM-DD-slug.md) — one-line summary.
-->
