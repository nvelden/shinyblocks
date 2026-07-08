import type { Metadata } from "next";
import Link from "next/link";
import { ComponentsGrid } from "@/components/components-grid";
import manifest from "@/lib/preview-manifest.json";

export const metadata: Metadata = {
  title: "Components",
  description:
    "Browse every shinyblocks component: layout primitives, form inputs, data display, feedback, and overlays — all rendered from pure R.",
};

export default function ComponentsIndexPage() {
  return (
    <div className="mx-auto w-full max-w-screen-2xl px-6 py-12">
      <div className="flex flex-col lg:flex-row gap-10">
        
        {/* Sidebar Nav (Desktop only) */}
        <aside className="hidden lg:block w-48 shrink-0">
          <div className="sticky top-20 flex flex-col gap-2">
            <div className="font-semibold text-xs uppercase tracking-wider text-muted-foreground mb-2 px-2">Components</div>
            <nav className="flex flex-col gap-1">
              {manifest
                .filter((c) => c.slug !== "gallery")
                .map((component) => (
                  <Link
                    key={component.slug}
                    href={`/components/${component.slug}/`}
                    className="rounded-md px-2 py-1.5 text-sm font-medium text-muted-foreground transition-colors hover:bg-accent hover:text-accent-foreground"
                  >
                    {component.name}
                  </Link>
                ))}
            </nav>
          </div>
        </aside>

        {/* Main Content Area */}
        <main className="flex-1 min-w-0">
          <div className="flex flex-col gap-4 mb-8">
            <h1 className="text-3xl font-bold tracking-tight">Components</h1>
            <p className="text-muted-foreground text-sm">
              Discover and preview all premium R components built for shinyblocks.
            </p>
          </div>

          <ComponentsGrid
            items={manifest
              .filter((c) => c.slug !== "gallery")
              .map(({ slug, name, description, html }) => ({
                slug,
                name,
                description,
                html,
              }))}
          />
        </main>
      </div>
    </div>
  );
}
