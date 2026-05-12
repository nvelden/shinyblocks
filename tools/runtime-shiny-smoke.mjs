import assert from "node:assert/strict";
import { spawn } from "node:child_process";
import { chromium } from "playwright";

const port = Number(process.env.PORT_RUNTIME_SHINY || 4325);
const url = `http://127.0.0.1:${port}`;

function delay(ms) {
  return new Promise((resolve) => setTimeout(resolve, ms));
}

async function waitForServer(process) {
  const deadline = Date.now() + 20000;
  while (Date.now() < deadline) {
    if (process.exitCode !== null) {
      throw new Error(`Shiny fixture exited early with code ${process.exitCode}`);
    }
    try {
      const response = await fetch(url);
      if (response.ok) return;
    } catch {
      await delay(250);
    }
  }

  throw new Error(`Timed out waiting for ${url}`);
}

const shiny = spawn("Rscript", ["tools/runtime-shiny-fixture.R", String(port)], {
  stdio: ["ignore", "pipe", "pipe"]
});

let stdout = "";
let stderr = "";
shiny.stdout.on("data", (chunk) => {
  stdout += chunk;
});
shiny.stderr.on("data", (chunk) => {
  stderr += chunk;
});

let browser;
let page;

try {
  await waitForServer(shiny);

  browser = await chromium.launch({ headless: true });
  page = await browser.newPage();
  await page.goto(url);

  await page.waitForFunction(() => {
    return document.querySelector("#runtime-choice")?.dataset.sbMounted === "true";
  });

  await page.locator("#child_text").waitFor({ state: "visible" });
  await assertText(page, "#child_text", "child-ready");
  await assertText(page, "#choice_value", "a");
  await page.waitForFunction(() => {
    return document.querySelector("#fixture-widget")?.dataset.runtimeFixtureReady === "true";
  });
  await assertText(page, "#fixture-widget", "widget-ready");
  await assertComputedStyle(page, "#fixture-widget", "boxSizing", "content-box");
  await assertText(page, "#nested_table table tbody td", "table-ready");

  await assertComputedStyle(page, "#host-button", "borderRadius", "13px");
  await assertComputedStyle(page, "#host-button", "boxSizing", "content-box");
  await assertComputedStyle(page, "#host-button", "color", "rgb(1, 2, 3)");
  await assertComputedStyle(page, "#host-nav", "color", "rgb(4, 5, 6)");
  await assertComputedStyle(page, "#host-selectize", "boxSizing", "content-box");
  await assertComputedStyle(page, "#host-bslib-card", "boxSizing", "content-box");
  await assertComputedStyle(page, "#host-bslib-card", "borderRadius", "19px");
  await assertComputedStyle(page, "#host-plotly", "boxSizing", "content-box");
  await assertComputedStyle(page, "#host-plotly", "position", "relative");
  await assertComputedStyle(page, "#portal-host-button", "boxSizing", "content-box");
  await assertComputedStyle(page, "#portal-host-button", "borderRadius", "17px");

  await page.fill("#nested", "from-browser");
  await assertText(page, "#nested_value", "from-browser");

  await page.click("#set_b");
  await assertText(page, "#choice_value", "b");

  await page.click("#clear_choice");
  await assertText(page, "#choice_value", "<NULL>");

  await page.click("#set_b");
  await assertText(page, "#choice_value", "b");

  await page.click("#disable_choice");
  await page.waitForFunction(() => {
    return document.querySelector("#runtime-choice")?.hasAttribute("data-disabled");
  });

  await page.evaluate(() => {
    window.shinyblocksRuntime.applyUpdate({
      id: "choice",
      component: "fixture",
      updates: { disabled: false },
      notify: false,
      revision: 0
    });
  });
  await page.waitForFunction(() => {
    return document.querySelector("#runtime-choice")?.hasAttribute("data-disabled");
  });

  await page.click("#enable_choice");
  await page.waitForFunction(() => {
    return !document.querySelector("#runtime-choice")?.hasAttribute("data-disabled");
  });

  await page.click("#toggle_dynamic");
  await page.waitForFunction(() => {
    return document.querySelector("#runtime-dynamic")?.dataset.sbMounted === "true";
  });
  await assertText(page, "#dynamic_value", "x");
  await assertText(page, "#dynamic_child", "dynamic-child-ready");

  await page.click("#toggle_dynamic");
  await page.waitForFunction(() => !document.querySelector("#runtime-dynamic"));

  await page.click("#toggle_dynamic");
  await page.waitForFunction(() => {
    return document.querySelector("#runtime-dynamic")?.dataset.sbMounted === "true";
  });
  await assertText(page, "#dynamic_value", "x");

  await page.click("#insert_runtime");
  await page.waitForFunction(() => {
    return document.querySelector("#runtime-inserted")?.dataset.sbMounted === "true";
  });
  await assertText(page, "#inserted_value", "y");
  await assertText(page, "#inserted_child", "inserted-child-ready");

  await page.click("#remove_runtime");
  await page.waitForFunction(() => !document.querySelector("#runtime-inserted"));

  await page.click("#insert_runtime");
  await page.waitForFunction(() => {
    return document.querySelector("#runtime-inserted")?.dataset.sbMounted === "true";
  });
  await assertText(page, "#inserted_value", "y");

  assert.equal(
    await page.locator("[data-shinyblocks-portal-root]").count(),
    1,
    "page should include one portal root"
  );

  await assertText(page, "#mod-value", "m0");
  await page.click("#mod-set");
  await assertText(page, "#mod-value", "m1");

  console.log("Runtime Shiny smoke test passed.");
} catch (error) {
  if (page) {
    console.error(await page.evaluate(() => ({
      choiceText: document.querySelector("#choice_value")?.textContent,
      rootDataset: { ...document.querySelector("#runtime-choice")?.dataset },
      pending: document.querySelector("#runtime-choice")?.hasAttribute("data-sb-pending-input"),
      shinyExists: Boolean(window.Shiny),
      hasSetInputValue: Boolean(window.Shiny?.setInputValue),
      hasShinyApp: Boolean(window.Shiny?.shinyapp),
      socketReadyState: window.Shiny?.shinyapp?.$socket?.readyState ?? null
    })));
  }
  console.error(stdout);
  console.error(stderr);
  throw error;
} finally {
  if (browser) await browser.close();
  shiny.kill("SIGTERM");
}

async function assertText(page, selector, expected) {
  await page.waitForFunction(
    ([target, value]) => document.querySelector(target)?.textContent?.trim() === value,
    [selector, expected]
  );
}

async function assertComputedStyle(page, selector, property, expected) {
  const actual = await page.locator(selector).evaluate((node, prop) => {
    return window.getComputedStyle(node)[prop];
  }, property);

  assert.equal(actual, expected, `${selector} ${property}`);
}
