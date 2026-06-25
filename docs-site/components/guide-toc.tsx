"use client";

import { useEffect, useState } from "react";
import type { TocEntry } from "@/content/guides/get-started";

interface GuideTocProps {
  entries: TocEntry[];
  /** Desktop = bordered rail with an active marker; mobile = plain list. */
  variant: "desktop" | "mobile";
}

// Renders the "On this page" list and highlights the section currently in view.
//
// A single IntersectionObserver watches every section. Sections become active
// inside a band just below the sticky header (top) down to ~55% of the viewport
// (bottom), so the highlight tracks the heading you are reading rather than
// whatever is merely on screen. The DOM-order-first visible section wins, and a
// bottom-of-page guard activates the final (often short) section that can never
// reach the activation band on its own.
export function GuideToc({ entries, variant }: GuideTocProps) {
  const [activeId, setActiveId] = useState<string>(entries[0]?.id ?? "");

  useEffect(() => {
    const sections = entries
      .map((entry) => document.getElementById(entry.id))
      .filter((el): el is HTMLElement => el !== null);
    if (sections.length === 0) return;

    const visible = new Set<string>();

    const resolveActive = () => {
      // Bottom of the page: short trailing sections never cross the activation
      // band, so pin the last entry once the page is scrolled to the end.
      const atBottom =
        window.innerHeight + window.scrollY >=
        document.documentElement.scrollHeight - 2;
      if (atBottom) {
        setActiveId(entries[entries.length - 1].id);
        return;
      }
      const firstVisible = entries.find((entry) => visible.has(entry.id));
      if (firstVisible) setActiveId(firstVisible.id);
    };

    const observer = new IntersectionObserver(
      (observed) => {
        for (const entry of observed) {
          if (entry.isIntersecting) visible.add(entry.target.id);
          else visible.delete(entry.target.id);
        }
        resolveActive();
      },
      // Activation band: below the sticky header (top-20 ≈ 80px) to ~45% up.
      { rootMargin: "-88px 0px -55% 0px", threshold: 0 },
    );

    sections.forEach((section) => observer.observe(section));
    window.addEventListener("scroll", resolveActive, { passive: true });

    return () => {
      observer.disconnect();
      window.removeEventListener("scroll", resolveActive);
    };
  }, [entries]);

  if (variant === "mobile") {
    return (
      <ol className="flex flex-col gap-1.5 text-sm">
        {entries.map((entry) => {
          const active = entry.id === activeId;
          return (
            <li key={entry.id}>
              <a
                href={`#${entry.id}`}
                aria-current={active ? "true" : undefined}
                className={`transition-colors focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-ring ${
                  active
                    ? "font-medium text-foreground"
                    : "text-muted-foreground hover:text-foreground"
                }`}
              >
                {entry.title}
              </a>
            </li>
          );
        })}
      </ol>
    );
  }

  return (
    <ol className="flex flex-col gap-1.5 border-l border-border text-sm">
      {entries.map((entry) => {
        const active = entry.id === activeId;
        return (
          <li key={entry.id}>
            <a
              href={`#${entry.id}`}
              aria-current={active ? "true" : undefined}
              className={`-ml-px block border-l py-0.5 pl-4 transition-colors focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-ring ${
                active
                  ? "border-foreground font-medium text-foreground"
                  : "border-transparent text-muted-foreground hover:border-foreground hover:text-foreground"
              }`}
            >
              {entry.title}
            </a>
          </li>
        );
      })}
    </ol>
  );
}
