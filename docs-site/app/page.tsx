import Link from "next/link";

// Landing page — placeholder hero for Phase 1.
// Phase 3 replaces this with the full gallery. See:
//   docs/agent-plans/2026-05-19-docs-site-build-plan.md  (Phase 3)
//   docs/agent-plans/2026-05-19-custom-docs-site.md      (Landing wireframe)
export default function HomePage() {
  return (
    <section className="mx-auto flex max-w-3xl flex-col items-center px-6 py-24 text-center">
      <div className="mb-6 inline-flex items-center rounded-full border border-border bg-secondary px-3 py-1 text-xs font-medium text-secondary-foreground">
        v0 · scaffolding
      </div>
      <h1 className="text-5xl font-bold tracking-tight">
        The Foundation for your Shiny App
      </h1>
      <p className="mt-6 max-w-2xl text-lg text-muted-foreground">
        A set of beautifully designed shadcn-inspired components for Shiny. Pure
        R. Open source. Open code.
      </p>
      <div className="mt-8 flex flex-wrap items-center justify-center gap-3">
        <Link
          href="/components"
          className="inline-flex h-9 items-center justify-center rounded-md bg-primary px-4 text-sm font-medium text-primary-foreground transition-colors hover:bg-primary/90 focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-ring"
        >
          Get started
        </Link>
        <Link
          href="/components"
          className="inline-flex h-9 items-center justify-center rounded-md border border-border bg-background px-4 text-sm font-medium transition-colors hover:bg-accent hover:text-accent-foreground focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-ring"
        >
          View Components
        </Link>
      </div>
    </section>
  );
}
