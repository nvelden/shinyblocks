import { readFile } from "node:fs/promises";
import assert from "node:assert/strict";
import { chromium } from "playwright";

const runtime = await readFile("inst/www/shinyblocks-runtime.js", "utf8");
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

const browser = await chromium.launch();
const page = await browser.newPage();

try {
  await page.setContent(`
    <!doctype html>
    <html>
      <head>
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
