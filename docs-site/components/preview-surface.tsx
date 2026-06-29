import { cn } from "@/lib/utils";

interface PreviewSurfaceProps {
  /** Rendered shinyblocks HTML fragment (from the preview manifest). */
  html: string;
  className?: string;
  /** Hide from the a11y tree (e.g. decorative grid thumbnails). */
  ariaHidden?: boolean;
  /** Forwarded to the wrapper (used by the grid to key preview slots). */
  slug?: string;
}

/**
 * Single scope for every static (non-playground) preview fragment.
 *
 * shinyblocks app-facing styles and design tokens (`--sb-surface-gap`,
 * `--sb-surface-padding`, ...) are scoped to `.sb-app` for embeddability.
 * Injecting card/block markup without that class leaves the tokens
 * undefined, so `gap: var(--sb-surface-gap)` collapses to 0 and the preview
 * loses its spacing. Playgrounds get the scope for free via `block_page()`;
 * static fragments must opt in here. Funnel all preview injection through
 * this component so no surface can forget the `.sb-app` scope again.
 */
export function PreviewSurface({
  html,
  className,
  ariaHidden,
  slug,
}: PreviewSurfaceProps) {
  return (
    <div
      className={cn("sb-app", className)}
      data-component-preview={slug}
      aria-hidden={ariaHidden ? "true" : undefined}
      dangerouslySetInnerHTML={{ __html: html }}
    />
  );
}
