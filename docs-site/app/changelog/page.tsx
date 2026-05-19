// Changelog — placeholder for Phase 6.
// See docs/agent-plans/2026-05-19-docs-site-build-plan.md (Phase 6).
// Phase 6 task: write scripts/generate-changelog.ts to read ../NEWS.md
// and render it here as MDX (or just dangerouslySetInnerHTML for v1).
export default function ChangelogPage() {
  return (
    <section className="mx-auto max-w-3xl px-6 py-16">
      <h1 className="text-3xl font-semibold tracking-tight">Changelog</h1>
      <p className="mt-3 text-muted-foreground">
        TODO (Phase 6): render <code>../NEWS.md</code> here.
      </p>
    </section>
  );
}
