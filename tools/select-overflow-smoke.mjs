// Regression guard: the runtime select popover must keep every option
// reachable under any style profile. The `luma` profile's roomier item
// spacing used to overflow the popover's fixed per-item height estimate, so
// the last option was clipped behind `.sb-select-content { overflow: hidden }`
// (visible bug: the final theme in the docs gallery dropdown disappeared).
//
// The popover is positioned from a measured content height and scrolls inside
// the available space, so this exercises a short, embedded viewport with the
// trigger near the bottom and asserts the last option scrolls into the clip
// box rather than vanishing.
import { readFile } from "node:fs/promises";
import assert from "node:assert/strict";
import { chromium } from "playwright";

const runtime = await readFile("inst/www/shinyblocks-runtime.js", "utf8");
const runtimeCss = await readFile("inst/www/shinyblocks-runtime.css", "utf8");

const choices = ["default", "slate", "stone", "rose", "olive", "mist"].map((value) => ({
  label: value,
  value
}));
const selectPayload = JSON.stringify({
  schemaVersion: 1,
  component: "select",
  id: "theme_select",
  props: {
    choices,
    placeholder: "Choose a theme",
    disabled: false,
    invalid: false,
    size: "sm",
    width: "200px",
    style: {},
    spriteHref: "shinyblocks-0.0.0.9000/icons/sprite.svg"
  },
  slots: {},
  children: [],
  state: { value: "default" },
  binding: { input: true },
  className: null
});

async function checkProfile(page, style) {
  await page.setContent(`
    <!doctype html>
    <html>
      <head>
        <style>${runtimeCss}</style>
        <script>window.Shiny={setInputValue(){},bindAll(){},unbindAll(){}};</script>
      </head>
      <body style="margin:0">
        <div style="height: 120px"></div>
        <div class="sb-app"${style ? ` data-sb-style="${style}"` : ""} id="runtime-select"
             data-shinyblocks-root data-shinyblocks-runtime="true">
          <script type="application/json" data-shinyblocks-payload>${selectPayload}</script>
          <div data-shinyblocks-react></div>
          <div data-shinyblocks-children></div>
        </div>
        <script>${runtime}</script>
      </body>
    </html>
  `);

  await page.locator("[data-slot='select-trigger']").click();
  await page.waitForSelector("[data-slot='select-content'][data-state='open']");

  const result = await page.evaluate(() => {
    const content = document.querySelector("[data-slot='select-content'][data-state='open']");
    const viewport = content.querySelector("[data-slot='select-viewport']");
    const items = [...viewport.querySelectorAll("[data-slot='select-item']")];
    const last = items[items.length - 1];
    // Scroll the scroll container to the bottom, as a user reaching the final
    // option would. `.sb-select-content` clips with `overflow: hidden`, so the
    // item is only reachable if it lands inside the content's clip box.
    viewport.scrollTop = viewport.scrollHeight;
    const cRect = content.getBoundingClientRect();
    const lRect = last.getBoundingClientRect();
    return {
      label: last.querySelector(".sb-select-item-text").textContent,
      reachable: lRect.top >= cRect.top - 1 && lRect.bottom <= cRect.bottom + 1,
      inViewport: cRect.top >= -1 && cRect.bottom <= window.innerHeight + 1
    };
  });

  assert.equal(result.label, "mist", `[${style || "default"}] should render every choice`);
  assert.ok(
    result.reachable,
    `[${style || "default"}] last option must scroll into the popover clip box, not be hidden by overflow`
  );
  assert.ok(
    result.inViewport,
    `[${style || "default"}] popover must stay inside the short embedded viewport`
  );

  await page.keyboard.press("Escape");
}

// Companion guard: when the whole list fits in the available space the popover
// must NOT show a scrollbar. Pinning the border-box to the exact measured
// content height left the scrolling viewport a fraction short (scrollHeight is
// integer rounded), so `overflow-y: auto` painted a permanent, unnecessary
// scrollbar. The box now caps to available space and the flex column shrinks
// to its content, so a roomy viewport leaves the viewport un-scrollable.
async function checkNoSpuriousScrollbar(page, style) {
  await page.setContent(`
    <!doctype html>
    <html>
      <head>
        <style>${runtimeCss}</style>
        <script>window.Shiny={setInputValue(){},bindAll(){},unbindAll(){}};</script>
      </head>
      <body style="margin:0">
        <div style="height: 40px"></div>
        <div class="sb-app"${style ? ` data-sb-style="${style}"` : ""} id="runtime-select"
             data-shinyblocks-root data-shinyblocks-runtime="true">
          <script type="application/json" data-shinyblocks-payload>${selectPayload}</script>
          <div data-shinyblocks-react></div>
          <div data-shinyblocks-children></div>
        </div>
        <script>${runtime}</script>
      </body>
    </html>
  `);

  await page.locator("[data-slot='select-trigger']").click();
  await page.waitForSelector("[data-slot='select-content'][data-state='open']");

  const scrollable = await page.evaluate(() => {
    const content = document.querySelector("[data-slot='select-content'][data-state='open']");
    const viewport = content.querySelector("[data-slot='select-viewport']");
    // Allow 1px for sub-pixel rounding; anything more is a real scrollbar.
    return viewport.scrollHeight - viewport.clientHeight > 1;
  });

  assert.ok(
    !scrollable,
    `[${style || "default"}] popover must not scroll when every option fits`
  );

  await page.keyboard.press("Escape");
}

const browser = await chromium.launch();
const page = await browser.newPage({ viewport: { width: 320, height: 220 } });
try {
  await checkProfile(page, null);
  await checkProfile(page, "luma");
} finally {
  await browser.close();
}

// Tall viewport so the full list fits with room to spare.
const roomyBrowser = await chromium.launch();
const roomyPage = await roomyBrowser.newPage({ viewport: { width: 320, height: 600 } });
try {
  await checkNoSpuriousScrollbar(roomyPage, null);
  await checkNoSpuriousScrollbar(roomyPage, "luma");
  console.log("Select overflow smoke test passed.");
} finally {
  await roomyBrowser.close();
}
