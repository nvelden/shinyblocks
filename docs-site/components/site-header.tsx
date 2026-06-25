import Link from "next/link";
import { Github } from "lucide-react";
import { ThemeToggle } from "@/components/theme-toggle";

// Top nav. Used on every page via app/layout.tsx.
// Keep this thin — a few nav links + GitHub + theme toggle, that's it.
export function SiteHeader() {
  return (
    <header className="sticky top-0 z-40 w-full border-b border-border bg-background/95 backdrop-blur supports-[backdrop-filter]:bg-background/60">
      <div className="mx-auto flex h-14 max-w-screen-2xl items-center gap-4 px-6 sm:gap-6">
        <Link
          href="/"
          className="shrink-0 text-sm font-semibold tracking-tight"
          aria-label="shinyblocks home"
        >
          shinyblocks
        </Link>
        {/* min-w-0 + overflow-x-auto lets the links scroll instead of widening
            the page on narrow viewports. */}
        <nav className="flex min-w-0 flex-1 items-center gap-4 overflow-x-auto text-sm font-medium">
          <Link
            href="/get-started"
            className="whitespace-nowrap text-muted-foreground transition-colors hover:text-foreground"
          >
            Get Started
          </Link>
          <Link
            href="/components"
            className="whitespace-nowrap text-muted-foreground transition-colors hover:text-foreground"
          >
            Components
          </Link>
          <Link
            href="/changelog"
            className="whitespace-nowrap text-muted-foreground transition-colors hover:text-foreground"
          >
            Changelog
          </Link>
        </nav>
        <div className="flex shrink-0 items-center gap-2">
          <a
            href="https://github.com/nvelden/shinyblocks"
            target="_blank"
            rel="noreferrer"
            aria-label="GitHub repository"
            className="inline-flex h-8 w-8 items-center justify-center rounded-md text-muted-foreground transition-colors hover:bg-accent hover:text-accent-foreground"
          >
            <Github className="h-4 w-4" />
          </a>
          <ThemeToggle />
        </div>
      </div>
    </header>
  );
}
