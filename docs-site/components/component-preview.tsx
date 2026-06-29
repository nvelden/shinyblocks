import Link from "next/link";
import { cn } from "@/lib/utils";
import { PreviewSurface } from "@/components/preview-surface";

interface ComponentPreviewProps {
  slug: string;
  name: string;
  href: string;
  html: string;
  className?: string;
}

export function ComponentPreview({
  slug,
  name,
  href,
  html,
  className,
}: ComponentPreviewProps) {
  return (
    <Link
      href={href}
      prefetch={false}
      className="group block relative overflow-hidden rounded-xl border border-border bg-card p-6 text-card-foreground shadow-sm transition-all duration-200 hover:border-foreground/20 hover:shadow-md focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-ring focus-visible:ring-offset-2"
    >
      <div className="flex flex-col gap-4">
        <div className="flex items-center justify-between">
          <span className="font-semibold text-sm tracking-tight text-foreground">
            {name}
          </span>
          <span className="text-xs text-muted-foreground group-hover:text-foreground transition-colors duration-200">
            View →
          </span>
        </div>
        
        {/* Render R HTML fragment inside inert wrapper. Fixed height + clip so
            every card in a row matches, regardless of preview content length
            (e.g. the long Code sample no longer stretches its whole row). */}
        <PreviewSurface
          slug={slug}
          ariaHidden
          html={html}
          className={cn(
            "pointer-events-none select-none w-full h-64 overflow-hidden flex items-center justify-center rounded-lg bg-muted/50 p-4 border border-dashed border-border/60 transition-colors duration-200 group-hover:bg-muted/70",
            className
          )}
        />
      </div>
    </Link>
  );
}
