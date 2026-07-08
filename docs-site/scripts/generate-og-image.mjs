// Renders public/og.png (1200x630 Open Graph card) with Playwright chromium.
// The image is a committed static asset — rerun this script only when the
// card design or tagline changes:
//
//   node scripts/generate-og-image.mjs
import { chromium } from "@playwright/test";
import path from "node:path";
import { fileURLToPath } from "node:url";

const outPath = path.join(
  path.dirname(fileURLToPath(import.meta.url)),
  "..",
  "public",
  "og.png"
);

const html = `<!doctype html>
<html>
<head>
<meta charset="utf-8">
<style>
  * { margin: 0; box-sizing: border-box; }
  body {
    width: 1200px; height: 630px;
    display: flex; flex-direction: column; justify-content: center;
    padding: 80px;
    background-color: #09090b;
    background-image: radial-gradient(circle at 25% 25%, #18181b 0%, #09090b 60%);
    color: #fafafa;
    font-family: -apple-system, "Segoe UI", Helvetica, Arial, sans-serif;
  }
  .brand { display: flex; align-items: center; gap: 16px; margin-bottom: 32px; }
  .glyph { display: flex; flex-wrap: wrap; width: 58px; gap: 6px; }
  .glyph span { width: 26px; height: 26px; border-radius: 6px; background: #52525b; }
  .glyph span:first-child, .glyph span:last-child { background: #fafafa; }
  .brand-name { font-size: 44px; font-weight: 700; letter-spacing: -1px; }
  h1 { font-size: 64px; font-weight: 800; letter-spacing: -2px; line-height: 1.1; max-width: 900px; }
  p { margin-top: 28px; font-size: 30px; color: #a1a1aa; max-width: 820px; line-height: 1.4; }
  .url { margin-top: 48px; font-size: 24px; color: #71717a; }
</style>
</head>
<body>
  <div class="brand">
    <div class="glyph"><span></span><span></span><span></span><span></span></div>
    <div class="brand-name">shinyblocks</div>
  </div>
  <h1>shadcn-inspired components for Shiny</h1>
  <p>Beautifully designed, composable UI blocks. Pure R &mdash; no Node, no build step. Open source.</p>
  <div class="url">nvelden.github.io/shinyblocks</div>
</body>
</html>`;

const browser = await chromium.launch();
const page = await browser.newPage({
  viewport: { width: 1200, height: 630 },
  deviceScaleFactor: 1,
});
await page.setContent(html, { waitUntil: "networkidle" });
await page.screenshot({ path: outPath, type: "png" });
await browser.close();
console.log(`Wrote ${outPath}`);
