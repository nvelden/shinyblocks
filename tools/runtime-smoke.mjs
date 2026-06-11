import { readFile } from "node:fs/promises";
import assert from "node:assert/strict";
import { chromium } from "playwright";

const runtime = await readFile("inst/www/shinyblocks-runtime.js", "utf8");
const runtimeCss = await readFile("inst/www/shinyblocks-runtime.css", "utf8");
const payload = JSON.stringify({
  schemaVersion: 1,
  component: "fixture",
  id: "choice",
  props: {},
  slots: {},
  children: [],
  state: { value: "a" },
  binding: { input: true },
  className: null
});
const buttonPayload = JSON.stringify({
  schemaVersion: 1,
  component: "button",
  id: null,
  props: {
    labelHtml: "Runtime button",
    variant: "outline",
    size: "sm",
    iconName: "search",
    iconHtml: null,
    iconPosition: "inline-start",
    spriteHref: "shinyblocks-0.0.0.9000/icons/sprite.svg",
    attrs: {
      "aria-invalid": "true",
      style: { color: "rgb(255, 0, 0)" }
    },
    disabled: false
  },
  slots: {},
  children: [],
  state: {},
  binding: {},
  className: "custom-button"
});
const badgePayload = JSON.stringify({
  schemaVersion: 1,
  component: "badge",
  id: null,
  props: {
    labelHtml: "Runtime badge",
    variant: "destructive"
  },
  slots: {},
  children: [],
  state: {},
  binding: {},
  className: "custom-badge"
});
const selectPayload = JSON.stringify({
  schemaVersion: 1,
  component: "select",
  id: "runtime_select",
  props: {
    choices: [
      { label: "None", value: "none" },
      { label: "Shadow large", value: "shadow-lg" },
      { label: "Border dashed", value: "border-dashed" }
    ],
    placeholder: "Choose a class",
    disabled: false,
    invalid: false,
    size: "sm",
    width: "280px",
    style: {},
    spriteHref: "shinyblocks-0.0.0.9000/icons/sprite.svg"
  },
  slots: {},
  children: [],
  state: { value: "shadow-lg" },
  binding: { input: true },
  className: null
});
const datePickerPayload = JSON.stringify({
  schemaVersion: 1,
  component: "date-picker",
  id: "runtime_date",
  props: {
    placeholder: "Pick a date",
    format: "yyyy-mm-dd",
    weekstart: 0,
    min: "2026-06-10",
    max: "2026-06-20",
    disabled: false,
    invalid: false,
    style: {},
    spriteHref: "shinyblocks-0.0.0.9000/icons/sprite.svg"
  },
  slots: {},
  children: [],
  state: { value: "2026-06-15" },
  binding: { input: true, type: "shinyblocks.date-picker" },
  className: null
});

const browser = await chromium.launch();
const page = await browser.newPage({ viewport: { width: 640, height: 220 } });

try {
  await page.setContent(`
    <!doctype html>
    <html>
      <head>
        <style>${runtimeCss}</style>
        <script>
          window.__inputs = [];
          window.Shiny = {
            setInputValue: function(id, value, options) {
              window.__inputs.push({ id: id, value: value, priority: options.priority });
            },
            bindAll: function(root) {
              root.setAttribute("data-bound", "true");
            },
            unbindAll: function(root) {
              root.setAttribute("data-unbound", "true");
            }
          };
        </script>
      </head>
      <body>
        <div id="root" data-shinyblocks-root data-shinyblocks-runtime="true">
          <script type="application/json" data-shinyblocks-payload>${payload}</script>
          <span>Child</span>
        </div>
        <div id="runtime-button" data-shinyblocks-root data-shinyblocks-runtime="true">
          <script type="application/json" data-shinyblocks-payload>${buttonPayload}</script>
          <div data-shinyblocks-react></div>
          <div data-shinyblocks-children></div>
        </div>
        <div id="runtime-badge" data-shinyblocks-root data-shinyblocks-runtime="true">
          <script type="application/json" data-shinyblocks-payload>${badgePayload}</script>
          <div data-shinyblocks-react></div>
          <div data-shinyblocks-children></div>
        </div>
        <div style="height: 120px;"></div>
        <div id="runtime-select" data-shinyblocks-root data-shinyblocks-runtime="true">
          <script type="application/json" data-shinyblocks-payload>${selectPayload}</script>
          <div data-shinyblocks-react></div>
          <div data-shinyblocks-children></div>
        </div>
        <div id="runtime-date" data-shinyblocks-root data-shinyblocks-runtime="true" data-sb-component="date-picker" data-sb-input-id="runtime_date">
          <script type="application/json" data-shinyblocks-payload>${datePickerPayload}</script>
          <div data-shinyblocks-react></div>
          <div data-shinyblocks-children><input type="text" class="sb-date-picker-native" id="runtime_date" value="2026-06-15" /></div>
        </div>
        <script>${runtime}</script>
      </body>
    </html>
  `);

  await page.waitForFunction(() => {
    return document.querySelector("#root")?.dataset.sbMounted === "true";
  });

  assert.equal(
    await page.locator("[data-shinyblocks-portal-root]").count(),
    1,
    "portal root should be created"
  );

  assert.deepEqual(
    await page.evaluate(() => window.__inputs),
    [{ id: "choice", value: "a", priority: "event" }],
    "mount should initialize the Shiny input value"
  );

  assert.equal(
    await page.locator("#runtime-button button").textContent(),
    "Runtime button",
    "button runtime should render its label"
  );
  assert.equal(
    await page.locator("#runtime-button button").getAttribute("data-variant"),
    "outline",
    "button runtime should render the variant"
  );
  assert.equal(
    await page.locator("#runtime-button button").getAttribute("aria-invalid"),
    "true",
    "button runtime should pass through attrs"
  );
  assert.equal(
    await page.locator("#runtime-button button").evaluate((node) => {
      return getComputedStyle(node).color;
    }),
    "rgb(255, 0, 0)",
    "button runtime should apply normalized style attrs"
  );
  assert.equal(
    await page.locator("#runtime-button svg use").getAttribute("href"),
    "shinyblocks-0.0.0.9000/icons/sprite.svg#sb-icon-search",
    "button runtime should render sprite icons"
  );
  assert.equal(
    await page.locator("#runtime-badge [data-slot='badge']").textContent(),
    "Runtime badge",
    "badge runtime should render its label"
  );
  await page.locator("#runtime-select [data-slot='select-trigger']").click();
  await page.waitForSelector("[data-slot='select-content'][data-state='open']");
  const selectPosition = await page.locator("[data-slot='select-content'][data-state='open']").evaluate((node) => {
    const rect = node.getBoundingClientRect();
    return {
      side: node.getAttribute("data-side"),
      top: rect.top,
      bottom: rect.bottom,
      viewportHeight: window.innerHeight
    };
  });
  assert.equal(
    selectPosition.side,
    "top",
    "select content should flip upward when the trigger is near the viewport bottom"
  );
  assert.ok(
    selectPosition.top >= 0 && selectPosition.bottom <= selectPosition.viewportHeight,
    "select content should stay visible inside a short embedded viewport"
  );
  await page.keyboard.press("Escape");

  // Date picker: trigger renders the formatted value, calendar opens, out-of-
  // bounds days are disabled, and selecting a day writes the single-writer
  // expando + hidden native input. Grow the viewport so the portaled calendar
  // (fixed-positioned below the trigger) is on-screen and clickable.
  await page.setViewportSize({ width: 640, height: 800 });
  assert.equal(
    await page.locator("#runtime-date .sb-date-picker-value").textContent(),
    "2026-06-15",
    "date picker should render the formatted trigger label"
  );
  await page.locator("#runtime-date .sb-date-picker-trigger").click();
  await page.waitForSelector("[data-slot='date-picker-content']");
  assert.equal(
    await page.locator("[data-slot='date-picker-content'] .sb-date-picker-day", { hasText: "9" }).first().isDisabled(),
    true,
    "days before min should be disabled"
  );
  await page.locator("[data-slot='date-picker-content'] .sb-date-picker-day", { hasText: "12" }).first().click();
  await page.waitForSelector("[data-slot='date-picker-content']", { state: "detached" });
  assert.equal(
    await page.locator("#runtime-date").evaluate((node) => node.__sbDatePickerValue),
    "2026-06-12",
    "selecting a day should write the date-picker value expando"
  );
  assert.equal(
    await page.locator("#runtime-date input.sb-date-picker-native").inputValue(),
    "2026-06-12",
    "selecting a day should update the hidden native input"
  );
  assert.equal(
    await page.locator("#runtime-date .sb-date-picker-value").textContent(),
    "2026-06-12",
    "selecting a day should update the trigger label"
  );

  await page.evaluate((payloadText) => {
    const inserted = document.createElement("div");
    inserted.id = "inserted";
    inserted.setAttribute("data-shinyblocks-root", "");
    inserted.setAttribute("data-shinyblocks-runtime", "true");
    inserted.innerHTML = `<script type="application/json" data-shinyblocks-payload>${payloadText}</script>`;
    document.body.appendChild(inserted);
  }, payload);

  await page.waitForFunction(() => {
    return document.querySelector("#inserted")?.dataset.sbMounted === "true";
  });

  await page.locator("#root").evaluate((node) => node.remove());
  await page.waitForFunction(() => !document.querySelector("#root"));

  console.log("Runtime smoke test passed.");
} finally {
  await browser.close();
}
