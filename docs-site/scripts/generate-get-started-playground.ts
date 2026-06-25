// Derive the Get Started Shinylive playground from the canonical guide source.
//
// The complete `app.R` shown on /get-started/ is the single source of truth
// (content/guides/get-started.ts -> CODE_COMPLETE). The embedded live preview
// must run that exact app, so we GENERATE the playground app.R from it instead
// of hand-maintaining a second copy. Run as part of `npm run prebuild`, before
// generate-playgrounds.R exports every playgrounds/<slug>/app.R to Shinylive.
//
// Output: docs-site/playgrounds/get-started/app.R (checked in; regenerated in
// CI so it can never drift from the guide).

import { mkdirSync, writeFileSync } from "node:fs";
import { dirname, join } from "node:path";
import { fileURLToPath } from "node:url";
import { CODE_COMPLETE } from "../content/guides/get-started";

const here = dirname(fileURLToPath(import.meta.url));
const outPath = join(here, "..", "playgrounds", "get-started", "app.R");

// Mount the bundled shinyblocks WASM filesystem image before loading the
// package — identical bootstrap to the component playgrounds, so the live
// preview uses the package built from this same commit. See
// scripts/generate-playgrounds.R for how the image is staged.
const BOOTSTRAP = `if (!"shinyblocks" %in% installed.packages()[, "Package"]) {
  dir.create("/packages", recursive = TRUE, showWarnings = FALSE)

  mounted <- FALSE
  for (path in c("../../library.data.gz", "../library.data.gz")) {
    tryCatch(
      {
        webr::mount("/packages", path)
        if ("shinyblocks" %in% installed.packages(lib.loc = "/packages")[, "Package"]) {
          mounted <- TRUE
          break
        }
      },
      error = function(e) {
        # Try the next path; Shinylive resolves mount URLs differently by host.
      }
    )
  }

  if (!mounted) {
    tryCatch(
      {
        webr::mount("/packages", "/shinyblocks/playgrounds/library.data.gz")
      },
      error = function(e) {
        stop("Failed to mount shinyblocks WASM package library: ", e$message)
      }
    )
  }

  .libPaths(c("/packages", .libPaths()))
}`;

const HEADER = `# AUTO-GENERATED — do not edit.
# Source: docs-site/content/guides/get-started.ts (CODE_COMPLETE)
# Regenerate: npm run prebuild
#            (or: npx tsx scripts/generate-get-started-playground.ts)
#
# This is the exact canonical app from the Get Started guide, wrapped with the
# Shinylive WASM bootstrap so it runs as the guide's embedded live preview.`;

const app = `${HEADER}\n\n${BOOTSTRAP}\n\n${CODE_COMPLETE}\n`;

mkdirSync(dirname(outPath), { recursive: true });
writeFileSync(outPath, app, "utf8");

console.log(`Wrote ${outPath} (${app.split("\n").length} lines) from CODE_COMPLETE.`);
