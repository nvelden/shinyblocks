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
  // Positioning props were missing in the first pass — that's how the
  // off-centre-thumb bug shipped past the harness. Listed here now
  // and cross-checked against the rail via getBoundingClientRect()
  // below.
  "position",
  "top",
  "marginTop",
  "transform",
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

async function setShadcnTheme(page, mode) {
  // shadcn's docs site toggles dark via `class="dark"` on <html>.
  await page.evaluate((m) => {
    const html = document.documentElement;
    html.classList.remove("dark", "light");
    if (m === "dark") html.classList.add("dark");
    else html.classList.add("light");
  }, mode);
  await page.waitForTimeout(150);
}

async function captureShadcnOnce(page, railProps, rangeProps, thumbProps) {
  return await page.evaluate(
    ([rp, rgP, tp]) => {
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
        rail: grab('[data-slot="slider-track"]', rp),
        range: grab('[data-slot="slider-range"]', rgP),
        thumb: grab('[data-slot="slider-thumb"]', tp),
      };
    },
    [railProps, rangeProps, thumbProps],
  );
}

async function captureShadcn(page) {
  await page.goto(SHADCN_URL, { waitUntil: "networkidle" });
  await page.waitForSelector('[data-slot="slider-track"]', {
    state: "visible",
    timeout: 10000,
  });

  await setShadcnTheme(page, "light");
  const light = await captureShadcnOnce(
    page,
    RAIL_PROPS,
    RANGE_PROPS,
    THUMB_PROPS,
  );

  await setShadcnTheme(page, "dark");
  const dark = await captureShadcnOnce(
    page,
    RAIL_PROPS,
    RANGE_PROPS,
    THUMB_PROPS,
  );

  return { light, dark };
}

async function setShinyblocksTheme(page, mode) {
  // shinyblocks toggles dark via data-theme="dark" on <html>.
  await page.evaluate((m) => {
    document.documentElement.dataset.theme = m;
  }, mode);
  await page.waitForTimeout(150);
}

async function captureShinyblocksOnce(page, railProps, rangeProps, thumbProps) {
  return await page.evaluate(
    ([section, rp, rgP, tp]) => {
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
        rail: grab(`${root} .irs-line`, rp),
        range: grab(`${root} .irs-bar`, rgP),
        thumb: grab(`${root} .irs-handle`, tp),
      };
    },
    [SECTION, railProps, rangeProps, thumbProps],
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

  await setShinyblocksTheme(page, "light");
  const lightClosed = await captureShinyblocksOnce(
    page,
    RAIL_PROPS,
    RANGE_PROPS,
    THUMB_PROPS,
  );
  await setShinyblocksTheme(page, "dark");
  const darkClosed = await captureShinyblocksOnce(
    page,
    RAIL_PROPS,
    RANGE_PROPS,
    THUMB_PROPS,
  );
  await setShinyblocksTheme(page, "light");
  const closed = lightClosed;

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

  // Geometry cross-check: compare the vertical centre of the rail
  // and the thumb. They must coincide (within sub-pixel rounding)
  // or the thumb visually floats off the track. Property-level diffs
  // miss this because each element's top/height looks fine in
  // isolation — only the *relative* geometry matters.
  const geometry = await page.evaluate(
    ([section]) => {
      const root = `[data-sb-section="${section}"] .sb-slider .irs--shiny`;
      const rail = document.querySelector(`${root} .irs-line`);
      const thumb = document.querySelector(`${root} .irs-handle`);
      if (!rail || !thumb) return null;
      const r = rail.getBoundingClientRect();
      const t = thumb.getBoundingClientRect();
      return {
        railCenterY: r.top + r.height / 2,
        thumbCenterY: t.top + t.height / 2,
        delta: Math.abs(r.top + r.height / 2 - (t.top + t.height / 2)),
        railRect: { top: r.top, height: r.height },
        thumbRect: { top: t.top, height: t.height },
      };
    },
    [SECTION],
  );

  return { ...closed, hoverThumb, labels, geometry, dark: darkClosed };
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
  console.log("\n# LIGHT MODE");
  drifts += diffRole("rail (track)", shadcn.light.rail, sb.rail, RAIL_PROPS);
  drifts += diffRole(
    "range (filled)",
    shadcn.light.range,
    sb.range,
    RANGE_PROPS,
  );
  drifts += diffRole(
    "thumb (handle)",
    shadcn.light.thumb,
    sb.thumb,
    THUMB_PROPS,
  );

  console.log("\n# DARK MODE");
  drifts += diffRole(
    "rail (track)",
    shadcn.dark.rail,
    sb.dark.rail,
    RAIL_PROPS,
  );
  drifts += diffRole(
    "range (filled)",
    shadcn.dark.range,
    sb.dark.range,
    RANGE_PROPS,
  );
  drifts += diffRole(
    "thumb (handle)",
    shadcn.dark.thumb,
    sb.dark.thumb,
    THUMB_PROPS,
  );

  console.log("\n== geometry: thumb centred on rail? ==");
  if (sb.geometry) {
    console.log(`  rail center Y   = ${sb.geometry.railCenterY.toFixed(2)}`);
    console.log(`  thumb center Y  = ${sb.geometry.thumbCenterY.toFixed(2)}`);
    console.log(`  vertical delta  = ${sb.geometry.delta.toFixed(2)} px`);
    if (sb.geometry.delta > 1.5) {
      console.log(
        `  ✗ thumb is not vertically centred on the rail (delta > 1.5px)`,
      );
      drifts++;
    } else {
      console.log(`  ✓ thumb centred on rail`);
    }
  }

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
