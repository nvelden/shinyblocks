"use client";

import { useMemo, useState } from "react";
import { Search } from "lucide-react";
import { ComponentPreview } from "@/components/component-preview";

interface GridItem {
  slug: string;
  name: string;
  description: string;
  html: string;
}

// Client-side filter over the (small, build-time) component manifest. The
// full grid is server-rendered on first paint; filtering only kicks in once
// the user types, so SEO and no-JS rendering keep the complete list.
export function ComponentsGrid({ items }: { items: GridItem[] }) {
  const [query, setQuery] = useState("");

  const filtered = useMemo(() => {
    const q = query.trim().toLowerCase();
    if (!q) return items;
    return items.filter(
      (c) =>
        c.name.toLowerCase().includes(q) ||
        c.description.toLowerCase().includes(q)
    );
  }, [items, query]);

  return (
    <div className="flex flex-col gap-6">
      <div className="relative max-w-sm">
        <Search
          aria-hidden
          className="pointer-events-none absolute left-3 top-1/2 h-4 w-4 -translate-y-1/2 text-muted-foreground"
        />
        <input
          type="search"
          value={query}
          onChange={(e) => setQuery(e.target.value)}
          placeholder={`Search ${items.length} components…`}
          aria-label="Search components"
          className="h-10 w-full rounded-lg border border-border bg-background pl-9 pr-3 text-sm text-foreground shadow-sm transition-colors placeholder:text-muted-foreground focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-ring"
        />
      </div>

      <p aria-live="polite" className="sr-only">
        {filtered.length} of {items.length} components shown
      </p>

      {filtered.length > 0 ? (
        <div className="grid grid-cols-1 gap-6 sm:grid-cols-2 xl:grid-cols-3">
          {filtered.map((component) => (
            <ComponentPreview
              key={component.slug}
              slug={component.slug}
              name={component.name}
              href={`/components/${component.slug}/`}
              html={component.html}
            />
          ))}
        </div>
      ) : (
        <div className="rounded-xl border border-dashed border-border bg-muted/30 px-6 py-16 text-center">
          <p className="text-sm font-medium text-foreground">
            No components match “{query}”
          </p>
          <p className="mt-1 text-sm text-muted-foreground">
            Try a different term, or browse the full list in the sidebar.
          </p>
        </div>
      )}
    </div>
  );
}
