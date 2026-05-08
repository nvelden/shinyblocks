# ADR 0009: Upstream Sync

## Status

Accepted (2026-05-08)

## Context

shinyshadcn ports shadcn/ui's design system into idiomatic R, but
shadcn upstream evolves continuously: token refinements, component
variant tweaks, accessibility improvements, and occasional larger
restyles. Without a deliberate sync process, the package either:

- Drifts behind upstream silently, leaving users with stale visuals,
  or
- Re-syncs at the wrong granularity (full rewrite of internals on
  every upstream change).

The plan needs an explicit sync ritual that captures what was
reviewed, what was adopted, and what was deliberately skipped, so
future contributors don't relitigate decisions.

## Decision

### Layer responsibilities

shadcn upstream changes affect only the internal HTML/CSS/JS layer.
The public R API is the user-facing contract and changes only with
deprecation paths. This was already established in the strategy
doc; the sync process operationalizes it.

### Pinned reference

`components.json` records the upstream variant: `style: new-york`,
`base: radix`, `iconLibrary: lucide`, `tailwindVersion: v4`. All
sync activity references this configuration. If the upstream variant
changes, that requires its own ADR.

### Sync log

`docs/upstream/shadcn-sync.md` is a living log. Each entry records:

```markdown
## 2026-05-08 — initial token sync

- shadcn/ui commit: <hash>
- Reviewed components: button, card, alert, badge, separator,
  skeleton, spinner, tabs, field, input-group, sidebar, value-box
- Tokens: copied verbatim from
  `apps/v4/registry/styles/new-york/index.css` into
  `inst/www/src/tokens.css`
- Adopted: full token set (oklch, including sidebar and chart
  tokens)
- Skipped: `@theme inline` block — Tailwind-specific; replaced by
  our `@theme` mapping in `inst/www/src/shinyshadcn.css`
- Open follow-ups: none
- shinyshadcn version released after sync: 0.0.0.9001
```

### Review cadence

- **Every minor release** of shinyshadcn: scan recent shadcn commits
  since the last sync, log the review, decide adopt/skip per change.
- **On major shadcn refresh**: trigger an unscheduled sync regardless
  of shinyshadcn release schedule.

### Review questionnaire

For each upstream change relevant to a component shinyshadcn ships,
answer in the sync log:

1. Did tokens change? If yes, update vendored block; document in
   NEWS.md as a theming change.
2. Did variants/sizes/slots change? Decide adopt/skip per
   component; ADR if breaking.
3. Did accessibility behavior improve? Adopt where compatible.
4. Did markup change? Update internal HTML; preserve public R API.
5. Is a public R API change required? If yes, deprecation cycle.

### Token deprecation policy

- **Adding a token** is a minor-release change.
- **Renaming a token** is a major-release change. The old name is
  kept as an alias for one minor cycle, with `lifecycle` deprecation
  warnings in `shadcn_theme()` if it's overridden.
- **Removing a token** requires a major-release bump and a NEWS
  entry under "Breaking changes".

### Component deprecation policy

- **Adding a component** is a minor-release change.
- **Renaming an exported function** is a major-release change with
  a one-cycle deprecation alias.
- **Removing a component** requires a major-release bump.
- **Changing a component's HTML structure** that user CSS could
  reasonably depend on is a major-release change. Internal classes
  (`ssc-*` only used by package CSS) can change in minor releases.

### What is NOT in the sync log

- shadcn upstream activity unrelated to components shinyshadcn
  ships.
- Speculative changes that weren't adopted (these go in NEWS only
  if a user might notice; otherwise discard).
- Build-tooling changes (Tailwind v4 minor versions, Lucide
  releases) unless they affect output.

## Consequences

- The sync log is the answer to "why does shinyshadcn look slightly
  different from current shadcn?". Future maintainers can read it
  and know.
- A maintainer can reconstruct what was true at any past minor
  release by reading the sync log entries up to that release.
- Token names are stable until a major release. Users can write
  custom CSS targeting `var(--card)` etc. with confidence.

## Operational note

The first sync log entry is written as part of Phase 1 when the
token block is first vendored. That entry pins the initial upstream
commit and is the baseline for all future review cadences.

## References

- [strategy: Upstream sync](../agent-plans/2026-05-08-port-strategy.md#upstream-sync)
- [strategy: Release Policy](../agent-plans/2026-05-08-port-strategy.md#release-policy)
- [docs/upstream/shadcn-sync.md](../upstream/shadcn-sync.md) — the
  sync log itself.
