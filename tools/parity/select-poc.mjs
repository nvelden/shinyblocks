/*
 * Visual-parity proof-of-concept for `block_select()`.
 * ADR 0016. Run as: node tools/parity/select-poc.mjs
 *
 * Loads the canonical shadcn Select page and the shinyblocks
 * showcase in the same Chromium, captures computed styles for the
 * trigger element in each, and diffs the two property-by-property.
 * Reports drift to stdout and exits non-zero when drift is present.
 *
 * Prerequisites:
 *   - `npm i -D playwright` already run
 *   - `npx playwright install chromium` already run
 *   - shinyblocks showcase running on http://127.0.0.1:4321
 *     (e.g. `make showcase`)
 */

import { chromium } from "playwright";

const SHADCN_SELECT_URL =
  "https://ui.shadcn.com/docs/components/radix/select";
// `block_select()` lives inside the `field` showcase section; no
// dedicated `select` section exists in the showcase today.
const SHOWCASE_URL = "http://127.0.0.1:4321/#field";
const SHOWCASE_SECTION = "field";

// Property set worth diffing on the trigger. Geometry + colour + radius
// + shadow + typography + state-bearing properties.
const TRIGGER_PROPS = [
  "borderRadius",
  "borderTopLeftRadius",
  "borderTopRightRadius",
  "borderBottomLeftRadius",
  "borderBottomRightRadius",
  "borderTopStyle",
  "borderTopWidth",
  "borderTopColor",
  "backgroundColor",
  "color",
  "fontSize",
  "fontWeight",
  "lineHeight",
  "letterSpacing",
  "paddingTop",
  "paddingRight",
  "paddingBottom",
  "paddingLeft",
  "boxShadow",
  "outlineStyle",
  "outlineWidth",
  "outlineColor",
  "height",
  "minHeight",
  "display",
  "alignItems",
  "justifyContent",
  "gap",
];

function snapshotStyles(selector, props) {
  const el = document.querySelector(selector);
  if (!el) {
    return { __missing: selector };
  }
  const s = window.getComputedStyle(el);
  return Object.fromEntries(props.map((p) => [p, s.getPropertyValue(
    // CSS property names are kebab-case; the JS DOM camelCase form
    // is accepted by getComputedStyle on most engines but kebab-case
    // is the spec form.
    p.replace(/[A-Z]/g, (m) => `-${m.toLowerCase()}`)
  )]));
}

async function captureShadcn(page) {
  await page.goto(SHADCN_SELECT_URL, { waitUntil: "networkidle" });
  // The first interactive SelectTrigger on the page.
  const sel = '[data-slot="select-trigger"]';
  await page.waitForSelector(sel, { state: "visible", timeout: 10000 });

  const closed = await page.evaluate(
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
    [sel, TRIGGER_PROPS],
  );

  return { closed };
}

async function captureShinyblocks(page) {
  await page.goto(SHOWCASE_URL, { waitUntil: "networkidle" });
  // The showcase filters sections by URL hash; make sure the select
  // section is actually the active one before measuring.
  await page.waitForSelector('[data-sb-section="field"]:not([hidden])', {
    state: "attached",
    timeout: 5000,
  });

  // Selectize wraps the native select with `.selectize-input` as the
  // visible trigger. Narrow to the select section so we don't grab
  // an instance hiding in another section.
  const sel =
    '[data-sb-section="field"] .sb-select .selectize-control.single .selectize-input';
  await page.waitForSelector(sel, { state: "visible", timeout: 10000 });

  const closed = await page.evaluate(
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
    [sel, TRIGGER_PROPS],
  );

  // Also capture the arrow ::after pseudo if any, plus any visible
  // ::before pseudo from Selectize. Pseudo-element styles are
  // queried with getComputedStyle(el, '::after').
  const arrows = await page.evaluate(
    ([selector]) => {
      const els = document.querySelectorAll(selector);
      const el = els[els.length - 1] || els[0]; // last visible one
      if (!el) return null;
      const after = window.getComputedStyle(el, "::after");
      const before = window.getComputedStyle(el, "::before");
      return {
        afterContent: after.content,
        afterWidth: after.width,
        afterHeight: after.height,
        afterDisplay: after.display,
        afterBackgroundColor: after.backgroundColor,
        beforeContent: before.content,
        beforeDisplay: before.display,
        beforeBorderTopWidth: before.borderTopWidth,
        beforeBorderLeftWidth: before.borderLeftWidth,
        beforeBorderRightWidth: before.borderRightWidth,
        beforeWidth: before.width,
      };
    },
    [sel],
  );

  // Dropdown / double-hover check: open Selectize, hover over a
  // non-selected option, and query computed background-color of each
  // row. With drift, the previously-selected row AND the
  // mouse-hovered row both have an accent fill simultaneously.
  await page.click(sel);
  await page.waitForSelector(
    '[data-sb-section="field"] .sb-select .selectize-dropdown .option',
    { state: "visible", timeout: 5000 },
  );

  // Move the mouse onto a row that isn't the currently-selected one.
  // Selectize emits options in order; Free (index 0) is the default
  // selected, so hover over Pro (index 1).
  const proOption = page.locator(
    '[data-sb-section="field"] .sb-select .selectize-dropdown .option',
  ).nth(1);
  await proOption.hover();
  await page.waitForTimeout(150); // let any transition settle

  const optionBgs = await page.evaluate(() => {
    const opts = Array.from(
      document.querySelectorAll(
        '[data-sb-section="field"] .sb-select .selectize-dropdown .option',
      ),
    );
    return opts.map((el) => ({
      text: el.textContent.trim(),
      backgroundColor: window.getComputedStyle(el).backgroundColor,
      classes: el.className,
    }));
  });

  return { closed, arrows, optionBgs };
}

function diff(label, shadcn, shinyblocks, props) {
  console.log(`\n== ${label} ==`);
  let drifts = 0;
  for (const p of props) {
    const a = shadcn[p];
    const b = shinyblocks[p];
    if (a === b) {
      console.log(`  ${p.padEnd(28)} match  ${a}`);
    } else {
      drifts++;
      console.log(`  ${p.padEnd(28)} drift  shadcn=${a}  shinyblocks=${b}`);
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

  console.log("Capturing shadcn trigger from", SHADCN_SELECT_URL);
  const shadcn = await captureShadcn(page);

  console.log("Capturing shinyblocks trigger from", SHOWCASE_URL);
  const sb = await captureShinyblocks(page);

  let drifts = 0;
  drifts += diff(
    "block_select trigger (default state, light theme)",
    shadcn.closed,
    sb.closed,
    TRIGGER_PROPS,
  );

  console.log("\n== block_select Selectize pseudo-element arrows ==");
  console.log(JSON.stringify(sb.arrows, null, 2));

  console.log("\n== block_select dropdown options (open state) ==");
  console.log(
    "Number of options highlighted (.active or hovered, non-transparent bg):",
  );
  const litRows = sb.optionBgs.filter((o) => {
    return (
      o.backgroundColor !== "rgba(0, 0, 0, 0)" &&
      o.backgroundColor !== "transparent" &&
      o.backgroundColor !== ""
    );
  });
  console.log(`  ${litRows.length} of ${sb.optionBgs.length} rows lit`);
  litRows.forEach((o) =>
    console.log(`    "${o.text}" -> ${o.backgroundColor}  (${o.classes})`),
  );

  await browser.close();

  console.log(`\n${drifts} drifts on trigger.`);
  if (drifts > 0 || litRows.length > 1) {
    process.exit(1);
  }
}

main().catch((err) => {
  console.error(err);
  process.exit(2);
});
