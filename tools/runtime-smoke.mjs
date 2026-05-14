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

const browser = await chromium.launch();
const page = await browser.newPage();

try {
  await page.setContent(`
    <!doctype html>
    <html>
      <head>
        <style>${runtimeCss}</style>
        <script>
          window.__inputs = [];
          window.__handler = null;
          window.Shiny = {
            setInputValue: function(id, value, options) {
              window.__inputs.push({ id: id, value: value, priority: options.priority });
            },
            addCustomMessageHandler: function(type, handler) {
              if (type === "sb:update") window.__handler = handler;
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

  await page.evaluate(() => {
    window.__handler({
      id: "choice",
      component: "fixture",
      updates: { value: "b", disabled: true },
      notify: true,
      revision: 2
    });
  });

  assert.equal(
    await page.locator("#root").getAttribute("data-disabled"),
    "",
    "disabled update should mark the root"
  );
  assert.deepEqual(
    await page.evaluate(() => window.__inputs.map((event) => event.value)),
    ["a", "b"],
    "notify=true should echo value updates to Shiny"
  );

  await page.evaluate(() => {
    window.__handler({
      id: "choice",
      component: "fixture",
      updates: { value: "stale" },
      notify: true,
      revision: 1
    });
  });

  assert.deepEqual(
    await page.evaluate(() => window.__inputs.map((event) => event.value)),
    ["a", "b"],
    "stale revisions should be ignored"
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
