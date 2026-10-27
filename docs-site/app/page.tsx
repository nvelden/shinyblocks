import Link from "next/link";
import { Sparkles } from "lucide-react";
import manifest from "@/lib/preview-manifest.json";
import { PlaygroundFrame } from "@/components/playground-frame";
import { PreviewSurface } from "@/components/preview-surface";

export default function HomePage() {
  const gallery = manifest.find((c) => c.slug === "gallery");

  return (
    <main className="flex flex-col gap-12 py-10 sm:gap-14 sm:py-12">
      <section className="mx-auto flex max-w-4xl flex-col items-center px-6 text-center">
        <div className="mb-5 inline-flex items-center gap-2 rounded-full border border-border bg-secondary/80 px-4 py-1.5 text-xs font-semibold text-secondary-foreground shadow-sm backdrop-blur-md">
          <Sparkles className="size-3.5 animate-pulse text-primary" />
          <span>Shadcn-inspired components for Shiny</span>
        </div>
        <h1 className="bg-gradient-to-r from-foreground via-foreground/90 to-foreground/75 bg-clip-text text-4xl font-extrabold tracking-tight text-transparent sm:text-6xl">
          Build beautiful Shiny apps. In pure R.
        </h1>
        <p className="mt-5 max-w-2xl text-base leading-relaxed text-muted-foreground sm:text-lg">
          Composable, accessible components with no Node or build step for app
          authors. Explore the live component gallery below.
        </p>
        <div className="mt-7 flex flex-wrap items-center justify-center gap-3">
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
            Browse components
          </Link>
        </div>
        <div className="mt-5 flex items-center justify-center gap-2 text-xs text-muted-foreground sm:gap-3">
          <span>Pure R</span>
          <span aria-hidden>·</span>
          <span>Open source</span>
          <span aria-hidden>·</span>
          <span>Interactive below</span>
        </div>
      </section>

      <section className="mx-auto w-full max-w-screen-2xl px-4 sm:px-6">
        <div className="mb-6 flex flex-col gap-4 sm:flex-row sm:items-end sm:justify-between">
          <div className="flex max-w-2xl flex-col gap-2">
            <h2 className="text-2xl font-bold tracking-tight sm:text-3xl">
              Try shinyblocks live
            </h2>
            <p className="text-sm text-muted-foreground">
              Change the theme, edit controls, open dialogs, and see Shiny
              reactivity in the browser.
            </p>
          </div>
          <div className="inline-flex w-fit items-center gap-2 rounded-full border border-border bg-secondary/70 px-3 py-1.5 text-xs font-semibold text-secondary-foreground">
            <span className="size-2 rounded-full bg-primary" aria-hidden />
            <span>Live R playground</span>
          </div>
        </div>

        {gallery && (
          gallery.hasPlayground ? (
            <div className="relative overflow-hidden rounded-xl border border-border bg-card shadow-sm">
              <PlaygroundFrame
                src="/shinyblocks/playgrounds/gallery/"
                title="Interactive components gallery"
                loading="eager"
                showLoadingState
                className="block w-full bg-background"
                style={{ height: `${gallery.playgroundHeight ?? 980}px`, border: 0 }}
              />
            </div>
          ) : (
            <PreviewSurface className="w-full" html={gallery.html} />
          )
        )}
      </section>

      <section className="mx-auto w-full max-w-screen-2xl px-4 sm:px-6">
        <div className="flex flex-col gap-6 rounded-xl border border-border bg-muted/40 p-6 sm:flex-row sm:items-center sm:justify-between sm:p-8">
          <div className="flex max-w-2xl flex-col gap-2">
            <h2 className="text-2xl font-bold tracking-tight">
              Ready to build your own?
            </h2>
            <p className="text-sm text-muted-foreground">
              Install shinyblocks and create your first runnable app with the
              step-by-step guide.
            </p>
          </div>
          <Link
            href="/get-started"
            className="inline-flex h-10 shrink-0 items-center justify-center rounded-lg bg-primary px-6 text-sm font-semibold text-primary-foreground shadow-sm transition-colors hover:bg-primary/90 focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-ring"
          >
            Read Get Started
          </Link>
        </div>
      </section>
    </main>
  );
}
