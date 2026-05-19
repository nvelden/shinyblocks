// Serves the static export at http://localhost:<PORT>/shinyblocks/
//
// WHY this wrapper exists:
//   `next.config.ts` sets `basePath: "/shinyblocks"`. Next bakes that prefix
//   into every internal link and asset URL. When we deploy to GH Pages the
//   site lives at `https://nvelden.github.io/shinyblocks/`, so the prefix
//   resolves correctly.
//
//   Locally, `npx serve out/` would expose `out/index.html` at the root
//   (`/`) and all the `/shinyblocks/...` links inside would 404.
//
//   Fix: copy `out/` into a wrapper directory at `.preview/shinyblocks/`
//   and serve `.preview/`. Now `/shinyblocks/index.html` resolves
//   correctly, matching the production URL shape exactly.
//
// Env vars:
//   PORT — port to serve on (default 4173 for local preview, 3000 in tests)

import { spawn } from "node:child_process";
import { cpSync, mkdirSync, rmSync } from "node:fs";
import { dirname, resolve } from "node:path";
import { fileURLToPath } from "node:url";

const __dirname = dirname(fileURLToPath(import.meta.url));
const root = resolve(__dirname, "..");
const out = resolve(root, "out");
const preview = resolve(root, ".preview");
const wrapped = resolve(preview, "shinyblocks");
const port = process.env.PORT ?? "4173";

rmSync(preview, { recursive: true, force: true });
mkdirSync(preview, { recursive: true });
cpSync(out, wrapped, { recursive: true });

console.log(`Serving ${wrapped} at http://localhost:${port}/shinyblocks/`);
const child = spawn(
  "npx",
  [
    "--yes",
    "serve",
    preview,
    "--listen",
    port,
    "--no-clipboard",
    "--no-port-switching",
  ],
  { stdio: "inherit", cwd: root },
);
child.on("exit", (code) => process.exit(code ?? 0));
