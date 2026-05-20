# Phase 2 — Static UI Prerender Pipeline

## Goal
Implement a static UI prerender pipeline to convert Shiny UI definitions in R (`block_*()` components) into static HTML fragments during the build step.

## Assumptions
- The R runtime environment has R dependencies installed (like `htmltools`, `devtools`, and the `shinyblocks` package itself).
- Tailwind CSS variable tokens will be correctly processed when `public/runtime/shinyblocks.css` is loaded in the Next.js `layout.tsx`.

## Proposed API
The pipeline is run at build time via `Rscript scripts/generate-previews.R`. It:
1. Sources `docs-site/content/previews/_registry.R`.
2. Resolves HTML fragments for each preview R script.
3. Generates a JSON manifest file `docs-site/lib/preview-manifest.json` containing each component's metadata and generated raw HTML fragment.
4. Generates static `.html` fragments under `docs-site/content/previews/`.
5. Copies all runtime assets to `docs-site/public/runtime/`.

## Files to Edit/Create
- `docs-site/content/previews/_registry.R` [NEW]
- `docs-site/content/previews/button.R` [NEW]
- `docs-site/content/previews/card.R` [NEW]
- `docs-site/scripts/generate-previews.R` [NEW]
- `docs-site/components/component-preview.tsx` [NEW]
- `docs-site/tests/e2e/prerender.spec.ts` [NEW]
- `docs-site/app/layout.tsx` [MODIFY]
- `docs-site/package.json` [MODIFY]

## Tests/Checks
- `npm run prebuild` executes without errors.
- `npm run test:e2e` is completely green.

## Open Questions
- None.
