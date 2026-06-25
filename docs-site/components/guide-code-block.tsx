"use client";

import { useId, useRef, useState } from "react";
import { Check, Copy } from "lucide-react";

interface GuideCodeBlockProps {
  /** The exact source to render and copy. */
  code: string;
  /** Highlight hint — `text` for diagrams, `r` for R source. */
  language?: "r" | "text";
  /** Accessible name for the code region and copy button context. */
  label?: string;
}

// Self-contained, accessible code block for the Get Started guide.
//
// Deliberately NOT rendered through the shinyblocks R runtime: the guide shell
// is a Next.js concern and must stay usable before or without the Shiny runtime
// script. Copy uses navigator.clipboard with a graceful no-op when unavailable.
export function GuideCodeBlock({ code, language = "r", label }: GuideCodeBlockProps) {
  const [copied, setCopied] = useState(false);
  const timer = useRef<ReturnType<typeof setTimeout> | null>(null);
  const statusId = useId();
  const accessibleName = label ?? "Code example";

  async function handleCopy() {
    try {
      // Clipboard may be unavailable (insecure context / blocked). In that
      // case leave the source visible for manual selection rather than error.
      if (!navigator.clipboard) return;
      await navigator.clipboard.writeText(code);
      setCopied(true);
      if (timer.current) clearTimeout(timer.current);
      timer.current = setTimeout(() => setCopied(false), 2000);
    } catch {
      // Swallow — manual selection remains available.
    }
  }

  return (
    <figure className="guide-code-block group relative my-0">
      {/* Always rendered so server and client markup match (no hydration
          mismatch); the handler no-ops when clipboard is unavailable. */}
      <button
        type="button"
        onClick={handleCopy}
        aria-label={copied ? `${accessibleName} copied` : `Copy ${accessibleName.toLowerCase()}`}
        className="absolute right-2 top-2 z-10 inline-flex h-8 w-8 items-center justify-center rounded-md border border-border bg-background/80 text-muted-foreground shadow-sm backdrop-blur transition-colors hover:bg-accent hover:text-accent-foreground focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-ring"
      >
        {copied ? (
          <Check className="h-4 w-4 text-primary" />
        ) : (
          <Copy className="h-4 w-4" />
        )}
      </button>
      <pre
        className="guide-code-pre overflow-x-auto rounded-lg border border-border bg-muted/40 p-4 text-sm leading-relaxed"
        tabIndex={0}
        role="region"
        aria-label={accessibleName}
      >
        <code className={`language-${language} font-mono`}>{code}</code>
      </pre>
      <span id={statusId} aria-live="polite" className="sr-only">
        {copied ? `${accessibleName} copied to clipboard` : ""}
      </span>
    </figure>
  );
}
