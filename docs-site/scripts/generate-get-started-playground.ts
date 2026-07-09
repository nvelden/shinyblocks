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

// Install the shinyblocks WebAssembly binary from r-universe before loading
// the package — identical bootstrap to the component playgrounds. r-universe
// rebuilds the binary from main on every push, so live previews track the
// latest package without bundling a filesystem image.
const BOOTSTRAP = `# Install shinyblocks (pre-built WebAssembly binary) from r-universe.
# NOTE: must be installed.packages(), not requireNamespace() - webR shims
# requireNamespace() and it returns NULL (not FALSE) for packages missing
# from the default webR repo, so negating its result errors.
if (!"shinyblocks" %in% rownames(installed.packages())) {
  install.packages(
    "shinyblocks",
    repos = c("https://nvelden.r-universe.dev", "https://repo.r-wasm.org")
  )
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
