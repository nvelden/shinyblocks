import Link from "next/link";
import { ComponentPreview } from "@/components/component-preview";
import manifest from "@/lib/preview-manifest.json";

export default function ComponentsIndexPage() {
  return (
    <div className="mx-auto w-full max-w-screen-2xl px-6 py-12">
      <div className="flex flex-col lg:flex-row gap-10">
        
        {/* Sidebar Nav (Desktop only) */}
        <aside className="hidden lg:block w-48 shrink-0">
          <div className="sticky top-20 flex flex-col gap-2">
            <div className="font-semibold text-xs uppercase tracking-wider text-muted-foreground mb-2 px-2">Components</div>
            <nav className="flex flex-col gap-1">
              {manifest.map((component) => (
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

          <div className="grid grid-cols-1 gap-6 sm:grid-cols-2 xl:grid-cols-3">
            {manifest.map((component) => (
              <ComponentPreview
                key={component.slug}
                slug={component.slug}
                name={component.name}
                href={`/components/${component.slug}/`}
                html={component.html}
              />
            ))}
          </div>
        </main>
      </div>
    </div>
  );
}
