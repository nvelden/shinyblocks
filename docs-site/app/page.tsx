import Link from "next/link";
import { Sparkles } from "lucide-react";
import manifest from "@/lib/preview-manifest.json";

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
            href="/components"
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

      {/* Main Interactive Grid Gallery */}
      <section className="mx-auto w-full max-w-screen-2xl px-4 sm:px-6">
        <div className="flex flex-col gap-3 mb-10 text-center sm:text-left">
          <h2 className="text-2xl sm:text-3xl font-bold tracking-tight">Interactive Components Playground</h2>
          <p className="text-muted-foreground text-sm max-w-xl">
            A visual directory of our premium blocks, integrated together in a high-fidelity dashboard layout, pre-rendered directly from R!
          </p>
        </div>

        {/* 4-Column High-Fidelity Dashboard Layout from pre-rendered R HTML */}
        {gallery && (
          <div 
            className="w-full"
            dangerouslySetInnerHTML={{ __html: gallery.html }} 
          />
        )}
      </section>
    </div>
  );
}
