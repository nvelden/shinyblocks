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
  await page.locator("#nested_plot img").waitFor({ state: "visible" });
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
  await assertCustomProperty(page, "#host-token-probe", "--background", "rgb(7, 8, 9)");
  await assertCustomProperty(page, "#runtime-choice", "--background", "oklch(100% 0 0)");
  await assertCustomProperty(page, "[data-shinyblocks-portal-root]", "--background", "oklch(100% 0 0)");

  await page.fill("#nested", "from-browser");
  await assertText(page, "#nested_value", "from-browser");

  await assertText(page, "#runtime_select_value", "free");
  await assertComputedStyle(
    page,
    "#runtime_select-trigger",
    "height",
    "25px"
  );
  await page.click("#runtime_select-trigger");
  await page.locator("[data-shinyblocks-portal-root] [data-slot='select-item']").filter({ hasText: "Pro" }).click();
  assert.equal(
    await page.locator("#runtime_select").inputValue(),
    "pro",
    "runtime select should keep the hidden native value"
  );
  await assertText(page, "#runtime_select_value", "pro");
  await page.click("#clear_select");
  await assertText(page, "#runtime_select_value", "<EMPTY>");
  await page.click("#set_select_pro");
  await assertText(page, "#runtime_select_value", "pro");
  await page.click("#disable_select");
  await page.waitForFunction(() => {
    return document.querySelector("#runtime_select")?.disabled === true &&
      document.querySelector("#runtime_select-trigger")?.disabled === true;
  });
  await page.click("#enable_select");
  await page.waitForFunction(() => {
    return document.querySelector("#runtime_select")?.disabled === false &&
      document.querySelector("#runtime_select-trigger")?.disabled === false;
  });

  await assertText(page, "#runtime_checkbox_value", "FALSE");
  await page.locator("[data-sb-component='checkbox'] [data-slot='checkbox-control']").evaluate((node) => {
    node.click();
  });
  await assertText(page, "#runtime_checkbox_value", "TRUE");
  assert.equal(
    await page.evaluate(() => document.querySelector("#runtime_checkbox")?.checked),
    true,
    "runtime checkbox should keep the hidden native value"
  );
  await page.locator("[data-sb-component='checkbox'] [data-slot='checkbox-control']").evaluate((node) => {
    node.click();
  });
  await assertText(page, "#runtime_checkbox_value", "FALSE");
  assert.equal(
    await page.evaluate(() => document.querySelector("#runtime_checkbox")?.checked),
    false,
    "runtime checkbox should toggle hidden native value back to false"
  );

  await assertText(page, "#runtime_switch_value", "FALSE");
  await page.locator("[data-sb-component='switch'] [data-slot='switch-control']").evaluate((node) => {
    node.click();
  });
  await assertText(page, "#runtime_switch_value", "TRUE");
  assert.equal(
    await page.evaluate(() => document.querySelector("#runtime_switch")?.checked),
    true,
    "runtime switch should keep the hidden native value"
  );
  await page.click("#set_switch_off");
  await assertText(page, "#runtime_switch_value", "FALSE");
  await page.click("#set_switch_on");
  await assertText(page, "#runtime_switch_value", "TRUE");
  await page.click("#disable_switch");
  await page.waitForFunction(() => {
    return document.querySelector("#runtime_switch")?.disabled === true &&
      document.querySelector("[data-sb-component='switch'] [data-slot='switch-control']")?.disabled === true;
  });
  await page.click("#enable_switch");
  await page.waitForFunction(() => {
    return document.querySelector("#runtime_switch")?.disabled === false &&
      document.querySelector("[data-sb-component='switch'] [data-slot='switch-control']")?.disabled === false;
  });

  await assertText(page, "#runtime_popover_value", "FALSE");
  await page.click("[data-sb-component='popover'] [data-slot='popover-trigger']");
  await page.locator("[data-shinyblocks-portal-root] [data-slot='popover-content']").waitFor({
    state: "visible"
  });
  await assertText(page, "#runtime_popover_value", "TRUE");
  await page.click("#runtime_popover_inner");
  assert.equal(
    await page.evaluate(() => document.activeElement?.id),
    "runtime_popover_inner",
    "inner popover control should be focusable when open"
  );
  await page.keyboard.press("Escape");
  await page.waitForFunction(() => {
    return !document.querySelector("[data-shinyblocks-portal-root] [data-slot='popover-content']");
  });
  await assertText(page, "#runtime_popover_value", "FALSE");
  assert.equal(
    await page.evaluate(() => document.activeElement?.getAttribute("data-slot")),
    "popover-trigger",
    "closing popover should return focus to the trigger"
  );

  await page.click("[data-sb-component='popover'] [data-slot='popover-trigger']");
  await page.locator("[data-shinyblocks-portal-root] [data-slot='popover-content']").waitFor({
    state: "visible"
  });
  await page.click("#host-button");
  await page.waitForFunction(() => {
    return !document.querySelector("[data-shinyblocks-portal-root] [data-slot='popover-content']");
  });
  await assertText(page, "#runtime_popover_value", "FALSE");

  await page.click("#open_popover");
  await page.locator("[data-shinyblocks-portal-root] [data-slot='popover-content']").waitFor({
    state: "visible"
  });
  await assertText(page, "#runtime_popover_value", "TRUE");
  await page.click("#update_popover_body");
  await page.waitForFunction(() => {
    const content = document.querySelector(
      "[data-shinyblocks-portal-root] [data-slot='popover-content']"
    );
    return content && content.textContent && content.textContent.includes("Updated from server");
  });
  await page.click("#close_popover");
  await page.waitForFunction(() => {
    return !document.querySelector("[data-shinyblocks-portal-root] [data-slot='popover-content']");
  });
  await assertText(page, "#runtime_popover_value", "FALSE");

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

async function assertCustomProperty(page, selector, property, expected) {
  const actual = await page.locator(selector).evaluate((node, prop) => {
    return window.getComputedStyle(node).getPropertyValue(prop).trim();
  }, property);

  assert.equal(actual, expected, `${selector} ${property}`);
}
