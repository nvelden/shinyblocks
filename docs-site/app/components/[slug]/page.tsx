import Link from "next/link";
import { notFound } from "next/navigation";
import manifest from "@/lib/preview-manifest.json";
import { API_REFERENCE_DATABASE } from "@/lib/api-reference";

interface PageProps {
  params: Promise<{ slug: string }>;
}

export async function generateStaticParams() {
  return manifest.map((c) => ({ slug: c.slug }));
}

export default async function ComponentDetailPage({ params }: PageProps) {
  const { slug } = await params;
  const component = manifest.find((c) => c.slug === slug);

  if (!component) {
    notFound();
  }

  const apiFunctions = API_REFERENCE_DATABASE[slug];

  return (
    <div className="mx-auto w-full max-w-screen-2xl px-6 py-12">
      <div className="flex flex-col lg:flex-row gap-10">
        
        {/* Sidebar Nav (Desktop only) */}
        <aside className="hidden lg:block w-48 shrink-0">
          <div className="sticky top-20 flex flex-col gap-2">
            <div className="font-semibold text-xs uppercase tracking-wider text-muted-foreground mb-2 px-2">Components</div>
            <nav className="flex flex-col gap-1">
              {manifest.map((c) => {
                const isActive = c.slug === slug;
                return (
                  <Link
                    key={c.slug}
                    href={`/components/${c.slug}/`}
                    className={`rounded-md px-2 py-1.5 text-sm font-medium transition-colors ${
                      isActive 
                        ? "bg-accent text-accent-foreground font-semibold" 
                        : "text-muted-foreground hover:bg-accent hover:text-accent-foreground"
                    }`}
                  >
                    {c.name}
                  </Link>
                );
              })}
            </nav>
          </div>
        </aside>

        {/* Main Content Area */}
        <main className="flex-1">
          <div className="flex flex-col gap-10">
            
            {/* Header Navigation */}
            <div className="flex flex-col gap-4 border-b border-border/60 pb-8">
              <Link
                href="/components/"
                className="inline-flex items-center text-sm font-medium text-muted-foreground hover:text-foreground transition-colors group"
              >
                <span className="mr-1 group-hover:-translate-x-0.5 transition-transform duration-200">←</span> Back to Components
              </Link>
              <div className="flex flex-col gap-2 mt-2">
                <h1 className="text-4xl font-extrabold tracking-tight text-foreground">{component.name}</h1>
                <p className="text-muted-foreground text-lg leading-relaxed max-w-3xl">{component.description}</p>
              </div>
            </div>

            {/* Section 1: Preview Canvas */}
            <section className="flex flex-col gap-4">
              <h2 className="text-xl font-bold tracking-tight text-foreground">Preview</h2>
              <div className="rounded-xl border border-border bg-card p-10 shadow-sm relative overflow-hidden transition-colors duration-200">
                <div
                  className="pointer-events-none select-none w-full flex items-center justify-center min-h-[220px] rounded-lg bg-muted/40 p-8 border border-dashed border-border/80"
                  dangerouslySetInnerHTML={{ __html: component.html }}
                />
              </div>
            </section>

            {/* Section 2: Code Recipe */}
            <section className="flex flex-col gap-4">
              <h2 className="text-xl font-bold tracking-tight text-foreground">R Code</h2>
              <div className="relative overflow-hidden rounded-xl border border-border bg-muted/40 font-mono text-sm leading-relaxed p-6 shadow-inner transition-colors duration-200">
                <pre className="overflow-x-auto whitespace-pre font-mono text-muted-foreground">
                  <code>{component.code}</code>
                </pre>
              </div>
            </section>

            {/* Section 3: API Reference */}
            {apiFunctions && apiFunctions.length > 0 && (
              <section className="flex flex-col gap-6">
                <h2 className="text-xl font-bold tracking-tight text-foreground border-b border-border pb-2">API Reference</h2>
                <div className="flex flex-col gap-10">
                  {apiFunctions.map((fn) => (
                    <div key={fn.name} className="flex flex-col gap-4">
                      <div className="flex flex-col gap-1">
                        <h3 className="font-mono text-base font-bold text-foreground">{fn.name}()</h3>
                        <p className="text-muted-foreground text-sm">{fn.description}</p>
                      </div>
                      <div className="overflow-x-auto rounded-xl border border-border bg-card shadow-sm">
                        <table className="w-full text-left border-collapse text-sm">
                          <thead>
                            <tr className="border-b border-border bg-muted/40 text-xs font-semibold uppercase tracking-wider text-muted-foreground">
                              <th className="px-4 py-3 font-medium">Argument</th>
                              <th className="px-4 py-3 font-medium">Type</th>
                              <th className="px-4 py-3 font-medium">Default</th>
                              <th className="px-4 py-3 font-medium">Description</th>
                            </tr>
                          </thead>
                          <tbody className="divide-y divide-border/60">
                            {fn.arguments.map((arg) => (
                              <tr key={arg.argument} className="hover:bg-muted/10 transition-colors">
                                <td className="px-4 py-3 font-mono font-bold text-foreground">{arg.argument}</td>
                                <td className="px-4 py-3 font-mono text-muted-foreground text-xs">{arg.type}</td>
                                <td className="px-4 py-3 font-mono text-xs">
                                  {arg.defaultVal === "required" ? (
                                    <span className="font-semibold text-rose-500 bg-rose-50 dark:bg-rose-950/20 dark:text-rose-400 px-1.5 py-0.5 rounded text-[10px] uppercase tracking-wider">required</span>
                                  ) : (
                                    <code className="text-muted-foreground">{arg.defaultVal}</code>
                                  )}
                                </td>
                                <td className="px-4 py-3 text-muted-foreground leading-relaxed">{arg.description}</td>
                              </tr>
                            ))}
                          </tbody>
                        </table>
                      </div>
                    </div>
                  ))}
                </div>
              </section>
            )}
            
          </div>
        </main>

      </div>
    </div>
  );
}

