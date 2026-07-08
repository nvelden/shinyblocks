import Link from "next/link";
import { Sparkles } from "lucide-react";
import manifest from "@/lib/preview-manifest.json";
import { GuideCodeBlock } from "@/components/guide-code-block";
import { PlaygroundFrame } from "@/components/playground-frame";
import { PreviewSurface } from "@/components/preview-surface";

// Shown verbatim on the landing page — keep it a real, runnable app.R so the
// copy button hands visitors something that works on first paste.
const HERO_APP = `library(shiny)
library(shinyblocks)

ui <- block_page(
  title = "Dashboard",
  theme = block_theme(preset = "zinc"),
  sidebar = block_sidebar(
    title = "Acme Analytics",
    block_nav(
      id = "page",
      block_nav_item("Overview", value = "overview",
                     icon = "layout-dashboard", selected = TRUE)
    )
  ),
  header = block_header(block_dark_mode_toggle()),
  block_card(
    title = "Monthly revenue",
    description = "A live Shiny output inside a card.",
    block_plot_output("sales")
  )
)

server <- function(input, output) {
  output$sales <- renderPlot(plot(pressure, type = "b"))
}

shinyApp(ui, server)`;

export default function HomePage() {
  const gallery = manifest.find((c) => c.slug === "gallery");

  return (
    <div className="flex flex-col gap-16 py-12">
      {/* Hero Section */}
      <section className="mx-auto flex max-w-3xl flex-col items-center px-6 text-center">
        <div className="mb-6 inline-flex items-center gap-2 rounded-full border border-border bg-secondary/80 px-4 py-1.5 text-xs font-semibold text-secondary-foreground shadow-sm backdrop-blur-md">
          <Sparkles className="h-3.5 w-3.5 text-primary animate-pulse" />
          <span>Runtime preview · shadcn-inspired Shiny components</span>
        </div>
        <h1 className="text-4xl font-extrabold tracking-tight sm:text-6xl bg-gradient-to-r from-foreground via-foreground/90 to-foreground/75 bg-clip-text text-transparent">
          The Foundation for your Shiny App
        </h1>
        <p className="mt-6 max-w-2xl text-base sm:text-lg text-muted-foreground leading-relaxed">
          A set of beautifully designed, shadcn-inspired components for Shiny. Pure R. Open source. Open code. Explore our interactive playground gallery below.
        </p>
        <div className="mt-8 flex flex-wrap items-center justify-center gap-4">
          <Link
            href="/get-started"
            className="inline-flex h-10 items-center justify-center rounded-lg bg-primary px-6 text-sm font-semibold text-primary-foreground shadow-sm transition-all hover:bg-primary/90 hover:scale-[1.02] active:scale-[0.98] focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-ring"
          >
            Get started
          </Link>
          <Link
            href="/components"
            className="inline-flex h-10 items-center justify-center rounded-lg border border-border bg-background/80 px-6 text-sm font-semibold transition-all hover:bg-accent hover:text-accent-foreground backdrop-blur-sm focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-ring"
          >
            View Documentation
          </Link>
        </div>
      </section>

      {/* Hero code sample: the "this is all it takes" moment */}
      <section className="mx-auto w-full max-w-3xl px-6">
        <div className="flex flex-col gap-3 mb-6 text-center">
          <h2 className="text-2xl sm:text-3xl font-bold tracking-tight">
            No Node. No build step. Just R.
          </h2>
          <p className="text-muted-foreground text-sm mx-auto max-w-xl">
            A complete dashboard shell — sidebar, header, dark mode, and a live
            plot — in one <code className="font-mono text-foreground">app.R</code>.
          </p>
        </div>
        <div className="overflow-hidden rounded-xl border border-border bg-card shadow-sm">
          <div className="flex items-center gap-2 border-b border-border bg-muted/40 px-4 py-2">
            <span className="h-2.5 w-2.5 rounded-full bg-border" aria-hidden />
            <span className="h-2.5 w-2.5 rounded-full bg-border" aria-hidden />
            <span className="h-2.5 w-2.5 rounded-full bg-border" aria-hidden />
            <span className="ml-2 font-mono text-xs text-muted-foreground">app.R</span>
          </div>
          <div className="[&_.guide-code-pre]:rounded-none [&_.guide-code-pre]:border-0">
            <GuideCodeBlock code={HERO_APP} label="Minimal shinyblocks app" />
          </div>
        </div>
      </section>

      {/* Main Interactive Grid Gallery */}
      <section className="mx-auto w-full max-w-screen-2xl px-4 sm:px-6">
        <div className="flex flex-col gap-3 mb-10 text-center sm:text-left">
          <h2 className="text-2xl sm:text-3xl font-bold tracking-tight">Interactive Components Playground</h2>
          <p className="text-muted-foreground text-sm max-w-xl">
            A visual directory of our premium blocks, integrated together in a high-fidelity dashboard layout, pre-rendered directly from R!
          </p>
        </div>

        {/* Live R dashboard with the generated HTML retained as a build fallback. */}
        {gallery && (
          gallery.hasPlayground ? (
            <div className="overflow-hidden rounded-lg border border-border bg-card">
              <PlaygroundFrame
                src="/shinyblocks/playgrounds/gallery/"
                title="Interactive components gallery"
                loading="lazy"
                className="block w-full bg-background"
                style={{ height: `${gallery.playgroundHeight ?? 980}px`, border: 0 }}
              />
            </div>
          ) : (
            <PreviewSurface className="w-full" html={gallery.html} />
          )
        )}
      </section>
    </div>
  );
}
