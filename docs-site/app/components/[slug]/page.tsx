import Link from "next/link";
import { notFound } from "next/navigation";
import manifestData from "@/lib/preview-manifest.json";
import { API_REFERENCE_DATABASE } from "@/lib/api-reference";
import { SITE_URL } from "@/lib/site";
import { PlaygroundFrame } from "@/components/playground-frame";
import { PreviewSurface } from "@/components/preview-surface";

interface ManifestEntry {
  name: string;
  slug: string;
  description: string;
  featured: boolean;
  code: string;
  codeHtml: string;
  html: string;
  hasPlayground?: boolean;
  playgroundHeight?: number;
}

const manifest = manifestData as ManifestEntry[];

interface PageProps {
  params: Promise<{ slug: string }>;
}

export async function generateStaticParams() {
  return manifest.map((c) => ({ slug: c.slug }));
}

export async function generateMetadata({ params }: PageProps) {
  const { slug } = await params;
  const component = manifest.find((c) => c.slug === slug);
  if (!component) return {};
  return {
    title: component.name,
    description: component.description,
    openGraph: {
      title: `${component.name} — shinyblocks`,
      description: component.description,
      url: `${SITE_URL}/components/${slug}/`,
    },
  };
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
              {manifest
                .filter((c) => c.slug !== "gallery")
                .map((c) => {
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
        <main className="flex-1 min-w-0">
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
              <h2 className="text-xl font-bold tracking-tight text-foreground">
                {component.hasPlayground ? "Interactive Playground" : "Preview"}
              </h2>
              {component.hasPlayground ? (
                <div className="rounded-xl border border-border bg-card shadow-sm overflow-hidden">
                  <PlaygroundFrame
                    src={`/shinyblocks/playgrounds/${slug}/`}
                    title={`${component.name} playground`}
                    loading="lazy"
                    className="w-full block bg-background"
                    style={{ height: `${component.playgroundHeight ?? 720}px`, border: 0 }}
                  />
                </div>
              ) : (
                <div className="rounded-xl border border-border bg-card p-10 shadow-sm relative overflow-hidden transition-colors duration-200">
                  <PreviewSurface
                    html={component.html}
                    className="pointer-events-none select-none w-full flex items-center justify-center min-h-[220px] rounded-lg bg-muted/40 p-8 border border-dashed border-border/80"
                  />
                </div>
              )}
            </section>

            {/* Section 2: Code Recipe */}
            <section className="flex flex-col gap-4">
              <h2 className="text-xl font-bold tracking-tight text-foreground">R Code</h2>
              <div
                className="component-code-block"
                dangerouslySetInnerHTML={{
                  __html: component.codeHtml,
                }}
              />
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
                      <div
                        data-slot="table-container"
                        className="relative w-full overflow-x-auto rounded-xl border border-border bg-card shadow-sm"
                      >
                        <table
                          data-slot="table"
                          className="w-full caption-bottom border-collapse text-sm text-foreground"
                        >
                          <thead data-slot="table-header">
                            <tr
                              data-slot="table-row"
                              className="border-b border-border transition-colors hover:bg-muted/50 data-[state=selected]:bg-muted"
                            >
                              <th
                                data-slot="table-head"
                                className="h-10 whitespace-nowrap px-2 py-2 text-left align-middle font-medium text-muted-foreground"
                              >
                                Argument
                              </th>
                              <th
                                data-slot="table-head"
                                className="h-10 whitespace-nowrap px-2 py-2 text-left align-middle font-medium text-muted-foreground"
                              >
                                Type
                              </th>
                              <th
                                data-slot="table-head"
                                className="h-10 whitespace-nowrap px-2 py-2 text-left align-middle font-medium text-muted-foreground"
                              >
                                Default
                              </th>
                              <th
                                data-slot="table-head"
                                className="h-10 whitespace-nowrap px-2 py-2 text-left align-middle font-medium text-muted-foreground"
                              >
                                Description
                              </th>
                            </tr>
                          </thead>
                          <tbody data-slot="table-body">
                            {fn.arguments.map((arg) => (
                              <tr
                                key={arg.argument}
                                data-slot="table-row"
                                className="border-b border-border transition-colors last:border-b-0 hover:bg-muted/50 data-[state=selected]:bg-muted"
                              >
                                <td
                                  data-slot="table-cell"
                                  className="whitespace-nowrap px-2 py-2 align-middle font-mono font-bold text-foreground"
                                >
                                  {arg.argument}
                                </td>
                                <td
                                  data-slot="table-cell"
                                  className="whitespace-nowrap px-2 py-2 align-middle font-mono text-xs text-muted-foreground"
                                >
                                  {arg.type}
                                </td>
                                <td
                                  data-slot="table-cell"
                                  className="whitespace-nowrap px-2 py-2 align-middle font-mono text-xs"
                                >
                                  {arg.defaultVal === "required" ? (
                                    <span className="rounded bg-destructive/10 px-1.5 py-0.5 text-[10px] font-semibold uppercase text-destructive">required</span>
                                  ) : (
                                    <code className="text-muted-foreground">{arg.defaultVal}</code>
                                  )}
                                </td>
                                <td
                                  data-slot="table-cell"
                                  className="whitespace-normal px-2 py-2 align-middle leading-relaxed text-muted-foreground"
                                >
                                  {arg.description}
                                </td>
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
