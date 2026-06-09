import assert from "node:assert/strict";
import { spawn } from "node:child_process";
import fs from "node:fs";
import os from "node:os";
import path from "node:path";
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

  await assertText(page, "#runtime_slider_value", "50");
  await page.click("#set_slider_75");
  await assertText(page, "#runtime_slider_value", "75");
  assert.equal(
    await page.evaluate(() => document.querySelector("#runtime_slider")?.value),
    "75",
    "runtime slider should keep the hidden native value"
  );
  await page.click("#disable_slider");
  await page.waitForFunction(() => {
    return document.querySelector("#runtime_slider")?.disabled === true &&
      document.querySelector("[data-sb-component='slider'] [data-slot='slider-thumb']")?.disabled === true;
  });
  await page.click("#enable_slider");
  await page.waitForFunction(() => {
    return document.querySelector("#runtime_slider")?.disabled === false &&
      document.querySelector("[data-sb-component='slider'] [data-slot='slider-thumb']")?.disabled === false;
  });
  const sliderThumb = await page.locator("[data-sb-component='slider'] [data-slot='slider-thumb']").boundingBox();
  const sliderTrack = await page.locator("[data-sb-component='slider'] [data-slot='slider-track']").boundingBox();
  assert(sliderThumb, "runtime slider thumb should be measurable");
  assert(sliderTrack, "runtime slider track should be measurable");
  await page.mouse.move(sliderThumb.x + sliderThumb.width / 2, sliderThumb.y + sliderThumb.height / 2);
  await page.mouse.down();
  await page.mouse.move(sliderTrack.x + sliderTrack.width * 0.2, sliderTrack.y - 40, { steps: 2 });
  await page.mouse.up();
  if (await page.evaluate(() => document.querySelector("#runtime_slider")?.value !== "20")) {
    const retryThumb = await page.locator("[data-sb-component='slider'] [data-slot='slider-thumb']").boundingBox();
    assert(retryThumb, "runtime slider thumb should be measurable for retry");
    await page.mouse.move(retryThumb.x + retryThumb.width / 2, retryThumb.y + retryThumb.height / 2);
    await page.mouse.down();
    await page.mouse.move(sliderTrack.x + sliderTrack.width * 0.2, sliderTrack.y - 40, { steps: 4 });
    await page.mouse.up();
  }
  await assertText(page, "#runtime_slider_value", "20");
  assert.equal(
    await page.evaluate(() => document.querySelector("#runtime_slider")?.value),
    "20",
    "runtime slider thumb drag should keep updating after the pointer leaves the track"
  );

  await assertText(page, "#runtime_button_value", "0");
  await assertText(page, "#runtime_button_class", "shinyActionButtonValue,shiny.actionButton,integer");
  await page.click("[data-sb-component='button'][data-sb-input-id='runtime_button'] [data-slot='button']");
  await assertText(page, "#runtime_button_value", "1");
  await page.click("#disable_button");
  await page.waitForFunction(() => {
    return document.querySelector(
      "[data-sb-component='button'][data-sb-input-id='runtime_button'] [data-slot='button']"
    )?.disabled === true;
  });
  await page.locator("[data-sb-component='button'][data-sb-input-id='runtime_button'] [data-slot='button']").evaluate((node) => {
    node.click();
  });
  await assertText(page, "#runtime_button_value", "1");
  await page.click("#enable_button");
  await page.waitForFunction(() => {
    return document.querySelector(
      "[data-sb-component='button'][data-sb-input-id='runtime_button'] [data-slot='button']"
    )?.disabled === false;
  });

  const uploadPath = path.join(os.tmpdir(), "shinyblocks-runtime-upload.txt");
  fs.writeFileSync(uploadPath, "runtime upload fixture\n");
  await assertText(page, "#runtime_file_input_value", "<NULL>");
  await page.setInputFiles("#runtime_file_input", uploadPath);
  await assertText(
    page,
    "#runtime_file_input_value",
    "name=shinyblocks-runtime-upload.txt cols=name,size,type,datapath rows=1"
  );
  await assertText(
    page,
    "[data-sb-component='file-input'] [data-slot='file-input-text']",
    "shinyblocks-runtime-upload.txt"
  );
  assert.equal(
    await page.evaluate(() => document.querySelector("#runtime_file_disabled")?.disabled),
    true,
    "disabled file input should disable the native file input"
  );
  assert.equal(
    await page.evaluate(() =>
      document.querySelector(".runtime-file-disabled-fixture [data-slot='file-input-button']")?.disabled
    ),
    true,
    "disabled file input should disable the visible trigger"
  );

  // Dropzone variant: a synthetic drop builds a DataTransfer, assigns
  // native.files, and dispatches `change` so Shiny's upload binding fires.
  const dropFiles = (selector, files) =>
    page.evaluate(
      ({ selector, files }) => {
        const el = document.querySelector(selector);
        if (!el) throw new Error(`drop target not found: ${selector}`);
        const dt = new DataTransfer();
        files.forEach((f) => dt.items.add(new File([f.content], f.name, { type: f.type })));
        el.dispatchEvent(new DragEvent("drop", { bubbles: true, cancelable: true, dataTransfer: dt }));
      },
      { selector, files }
    );

  await assertText(page, "#runtime_file_dropzone_value", "<NULL>");
  await dropFiles(".runtime-file-dropzone-fixture", [
    { name: "dropped.txt", type: "text/plain", content: "dropzone fixture\n" }
  ]);
  await assertText(
    page,
    "#runtime_file_dropzone_value",
    "name=dropped.txt cols=name,size,type,datapath rows=1"
  );
  await assertText(
    page,
    ".runtime-file-dropzone-fixture [data-slot='file-input-text']",
    "dropped.txt"
  );

  // Rejected drop (accept mismatch) leaves the prior value unchanged and pulses
  // the reject state instead of dispatching a new upload.
  await dropFiles(".runtime-file-dropzone-fixture", [
    { name: "nope.png", type: "image/png", content: "x" }
  ]);
  assert.equal(
    await page.evaluate(
      () => document.querySelector(".runtime-file-dropzone-fixture")?.getAttribute("data-reject")
    ),
    "true",
    "rejected drop should flash the reject state"
  );
  await assertText(
    page,
    "#runtime_file_dropzone_value",
    "name=dropped.txt cols=name,size,type,datapath rows=1"
  );

  // Disabled dropzone ignores drops entirely (no native file assignment).
  await dropFiles(".runtime-file-dropzone-disabled-fixture", [
    { name: "ignored.txt", type: "text/plain", content: "y" }
  ]);
  assert.equal(
    await page.evaluate(
      () => document.querySelector("#runtime_file_dropzone_disabled")?.files?.length ?? -1
    ),
    0,
    "disabled dropzone drop should be a no-op"
  );

  await assertText(
    page,
    "[data-sb-component='table'][data-sb-input-id='runtime_table'] tbody td",
    "alpha"
  );
  await page.click("#update_table");
  await assertText(
    page,
    "[data-sb-component='table'][data-sb-input-id='runtime_table'] tbody td",
    "beta"
  );

  // DT-style row selection: clicking rows reports bare id, _rows_selected, and
  // _row_last_clicked; clicking a selected row toggles it off (multiple mode).
  const selTable =
    "[data-sb-component='table'][data-sb-input-id='runtime_table_sel'] tbody tr";
  await assertText(page, "#runtime_table_sel_value", "rows=- bare=- last=-");
  await page.click(`${selTable}:nth-child(1) td`);
  await assertText(page, "#runtime_table_sel_value", "rows=1 bare=1 last=1");
  await page.click(`${selTable}:nth-child(2) td`);
  await assertText(page, "#runtime_table_sel_value", "rows=1,2 bare=1,2 last=2");
  await page.click(`${selTable}:nth-child(1) td`);
  await assertText(page, "#runtime_table_sel_value", "rows=2 bare=2 last=1");
  assert.equal(
    await page.evaluate(() =>
      document
        .querySelector(
          "[data-sb-input-id='runtime_table_sel'] tbody tr:nth-child(2)"
        )
        ?.getAttribute("aria-selected")
    ),
    "true",
    "selected row should expose aria-selected"
  );

  // Stale-selection reconciliation: row 2 is selected, then the server pushes a
  // single-row data update WITHOUT a `selected` field. The dropped row must not
  // linger in component state or keep reporting through the Shiny input.
  await page.click("#shrink_select_table");
  // `_rows_selected`/bare clear; `_row_last_clicked` is historical (last set to 1)
  // and the binding never resets it, so it stays put.
  await assertText(page, "#runtime_table_sel_value", "rows=- bare=- last=1");
  assert.equal(
    await page.evaluate(
      () =>
        document.querySelectorAll(
          "[data-sb-input-id='runtime_table_sel'] tbody tr"
        ).length
    ),
    1,
    "shrunk selection table should render a single row"
  );
  assert.equal(
    await page.evaluate(() =>
      document
        .querySelector("[data-sb-input-id='runtime_table_sel'] tbody tr:nth-child(1)")
        ?.getAttribute("aria-selected")
    ),
    "false",
    "no stale row should remain selected after the data shrinks"
  );

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
  await assertText(page, "#mod-upload_value", "<NULL>");
  await page.setInputFiles("#mod-upload", uploadPath);
  await assertText(page, "#mod-upload_value", "shinyblocks-runtime-upload.txt");

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
