/*
 * Visual-parity proof of concept for `block_slider()`.
 * ADR 0016. Run as: node tools/parity/slider-poc.mjs
 *
 * shadcn Slider is Radix-based: <span data-slot="slider"> wraps
 * <span data-slot="slider-track"> (rail), which wraps
 * <span data-slot="slider-range"> (filled portion), with one or two
 * <span data-slot="slider-thumb"> handles outside the track.
 *
 * shinyblocks block_slider() wraps shiny::sliderInput(), which
 * renders ion.rangeSlider: `.irs-line` (rail), `.irs-bar` (range),
 * `.irs-handle` (thumb). The visual contract has to match even
 * though the DOM does not.
 *
 * Prerequisites:
 *   - playwright already installed (`npm i -D playwright`)
 *   - chromium downloaded (`npx playwright install chromium`)
 *   - shinyblocks showcase running on :4321 with the slider section.
 */

import { chromium } from "playwright";

const SHADCN_URL = "https://ui.shadcn.com/docs/components/slider";
const SHOWCASE_URL = "http://127.0.0.1:4321/#slider";
const SECTION = "slider";

// Properties to diff on each visual role.
const RAIL_PROPS = [
  "backgroundColor",
  "borderRadius",
  "borderTopLeftRadius",
  "height",
  "width",
];

const RANGE_PROPS = ["backgroundColor", "borderRadius", "height"];

const THUMB_PROPS = [
  "backgroundColor",
  "borderRadius",
  "borderTopWidth",
  "borderTopStyle",
  "borderTopColor",
  "boxShadow",
  "width",
  "height",
  "display",
];

function styleOf(selector, props) {
  const el = document.querySelector(selector);
  if (!el) return { __missing: selector };
  const s = window.getComputedStyle(el);
  const out = {};
  for (const p of props) {
    out[p] = s.getPropertyValue(
      p.replace(/[A-Z]/g, (m) => `-${m.toLowerCase()}`),
    );
  }
  return out;
}

async function captureShadcn(page) {
  await page.goto(SHADCN_URL, { waitUntil: "networkidle" });
  await page.waitForSelector('[data-slot="slider-track"]', {
    state: "visible",
    timeout: 10000,
  });

  return await page.evaluate(
    ([railProps, rangeProps, thumbProps]) => {
      const grab = (selector, props) => {
        const el = document.querySelector(selector);
        if (!el) return { __missing: selector };
        const s = window.getComputedStyle(el);
        const out = {};
        for (const p of props) {
          out[p] = s.getPropertyValue(
            p.replace(/[A-Z]/g, (m) => `-${m.toLowerCase()}`),
          );
        }
        return out;
      };

      return {
        rail: grab('[data-slot="slider-track"]', railProps),
        range: grab('[data-slot="slider-range"]', rangeProps),
        thumb: grab('[data-slot="slider-thumb"]', thumbProps),
      };
    },
    [RAIL_PROPS, RANGE_PROPS, THUMB_PROPS],
  );
}

async function captureShinyblocks(page) {
  await page.goto(SHOWCASE_URL, { waitUntil: "networkidle" });
  await page.waitForSelector(`[data-sb-section="${SECTION}"]:not([hidden])`, {
    state: "attached",
    timeout: 5000,
  });
  await page.waitForSelector(
    `[data-sb-section="${SECTION}"] .sb-slider .irs--shiny .irs-handle`,
    { state: "visible", timeout: 10000 },
  );

  const closed = await page.evaluate(
    ([section, railProps, rangeProps, thumbProps]) => {
      const grab = (selector, props) => {
        const el = document.querySelector(selector);
        if (!el) return { __missing: selector };
        const s = window.getComputedStyle(el);
        const out = {};
        for (const p of props) {
          out[p] = s.getPropertyValue(
            p.replace(/[A-Z]/g, (m) => `-${m.toLowerCase()}`),
          );
        }
        return out;
      };

      const root = `[data-sb-section="${section}"] .sb-slider .irs--shiny`;
      return {
        rail: grab(`${root} .irs-line`, railProps),
        range: grab(`${root} .irs-bar`, rangeProps),
        thumb: grab(`${root} .irs-handle`, thumbProps),
      };
    },
    [SECTION, RAIL_PROPS, RANGE_PROPS, THUMB_PROPS],
  );

  // Hover state on the thumb — shadcn shows a 4px --ring/50 ring.
  const thumbSelector = `[data-sb-section="${SECTION}"] .sb-slider .irs--shiny .irs-handle`;
  await page.locator(thumbSelector).first().hover();
  await page.waitForTimeout(150);
  const hoverThumb = await page.evaluate(
    ([selector, props]) => {
      const el = document.querySelector(selector);
      if (!el) return { __missing: selector };
      const s = window.getComputedStyle(el);
      const out = {};
      for (const p of props) {
        out[p] = s.getPropertyValue(
          p.replace(/[A-Z]/g, (m) => `-${m.toLowerCase()}`),
        );
      }
      return out;
    },
    [thumbSelector, [...THUMB_PROPS, "boxShadow"]],
  );

  // Visibility audit: make sure ion.rangeSlider's edge labels and
  // value bubbles really are hidden.
  const labels = await page.evaluate(
    ([section]) => {
      const labels = [
        ".irs-min",
        ".irs-max",
        ".irs-single",
        ".irs-from",
        ".irs-to",
        ".irs-grid",
      ];
      return labels.map((cls) => {
        const el = document.querySelector(
          `[data-sb-section="${section}"] .sb-slider ${cls}`,
        );
        return {
          selector: cls,
          display: el ? window.getComputedStyle(el).display : "absent",
        };
      });
    },
    [SECTION],
  );

  return { ...closed, hoverThumb, labels };
}

function diffRole(label, shadcn, sb, props) {
  console.log(`\n== ${label} ==`);
  let drifts = 0;
  for (const p of props) {
    const a = shadcn[p];
    const b = sb[p];
    if (a === b) {
      console.log(`  ${p.padEnd(22)} match  ${a}`);
    } else {
      drifts++;
      console.log(
        `  ${p.padEnd(22)} drift  shadcn=${a}  shinyblocks=${b}`,
      );
    }
  }
  return drifts;
}

async function main() {
  const browser = await chromium.launch();
  const ctx = await browser.newContext({
    viewport: { width: 1280, height: 800 },
    deviceScaleFactor: 1,
  });
  const page = await ctx.newPage();

  console.log("Capturing shadcn slider from", SHADCN_URL);
  const shadcn = await captureShadcn(page);

  console.log("Capturing shinyblocks slider from", SHOWCASE_URL);
  const sb = await captureShinyblocks(page);

  let drifts = 0;
  drifts += diffRole("rail (track)", shadcn.rail, sb.rail, RAIL_PROPS);
  drifts += diffRole("range (filled)", shadcn.range, sb.range, RANGE_PROPS);
  drifts += diffRole("thumb (handle)", shadcn.thumb, sb.thumb, THUMB_PROPS);

  console.log("\n== thumb hover ring ==");
  console.log(`  shadcn  (hover triggers ring-4 ring-ring/50)`);
  console.log(`  shinyblocks boxShadow on hover: ${sb.hoverThumb.boxShadow}`);

  console.log("\n== hidden labels audit ==");
  let visibleLabels = 0;
  for (const row of sb.labels) {
    const ok = row.display === "none" || row.display === "absent";
    if (!ok) visibleLabels++;
    console.log(
      `  ${row.selector.padEnd(14)} ${ok ? "✓ hidden" : "✗ visible"}  (display: ${row.display})`,
    );
  }

  await browser.close();

  console.log(`\n${drifts} computed-style drifts across rail+range+thumb.`);
  if (visibleLabels > 0) {
    console.log(`${visibleLabels} ion.rangeSlider labels are visible — should be hidden.`);
  }

  if (drifts > 0 || visibleLabels > 0) {
    process.exit(1);
  }
}

main().catch((err) => {
  console.error(err);
  process.exit(2);
});
