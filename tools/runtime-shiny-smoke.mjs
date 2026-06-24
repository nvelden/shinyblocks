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
  // aria-activedescendant must live on the focused combobox trigger (the
  // listbox is portaled and never holds focus). Open, assert, then close.
  await page.click("#runtime_select-trigger");
  await page.waitForFunction(() => {
    const trigger = document.querySelector("#runtime_select-trigger");
    const listbox = document.querySelector(
      "[data-shinyblocks-portal-root] [data-slot='select-content']"
    );
    return (
      /^runtime_select-item-\d+$/.test(trigger?.getAttribute("aria-activedescendant") || "") &&
      listbox?.getAttribute("aria-activedescendant") === null
    );
  });
  await page.keyboard.press("Escape");
  // A vector `selected` reaching the single select collapses to its first
  // element ("free") rather than stringifying to "free,pro".
  await page.click("#set_select_vector");
  await assertText(page, "#runtime_select_value", "free");
  assert.equal(
    await page.locator("#runtime_select").inputValue(),
    "free",
    "vector update to a single select should collapse to the first element"
  );
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

  // Multiple-mode select: chips, a multiselectable listbox that stays open on
  // toggle, chip removal (pointer + keyboard), the `max_items` cap, server
  // update/clear, stale-choice reconciliation, and disabled state.
  const multiTrigger = "#runtime_multi_select-trigger";
  const multiItem = (label) =>
    page
      .locator("[data-shinyblocks-portal-root] [data-slot='select-item']")
      .filter({ hasText: label });
  const nativeMultiValues = () =>
    page.evaluate(() =>
      Array.from(document.querySelector("#runtime_multi_select").selectedOptions).map(
        (option) => option.value
      )
    );

  await assertText(page, "#runtime_multi_select_value", "one");
  await assertText(page, "#runtime_multi_select_length", "1");
  await page.click(multiTrigger);
  // aria-activedescendant lives on the focused combobox trigger, not the
  // portaled listbox.
  await page.waitForFunction(() => {
    const trigger = document.querySelector("#runtime_multi_select-trigger");
    const listbox = document.querySelector(
      "[data-shinyblocks-portal-root] [data-slot='select-content']"
    );
    return (
      /^runtime_multi_select-item-\d+$/.test(
        trigger?.getAttribute("aria-activedescendant") || ""
      ) && listbox?.getAttribute("aria-activedescendant") === null
    );
  });
  // Toggle "Two" on; the popup must stay open so a second pick needs no reopen.
  await multiItem("Two").click();
  assert.equal(
    await page
      .locator("[data-shinyblocks-portal-root] [data-slot='select-content']")
      .count(),
    1,
    "multi-select popup should stay open after toggling an item"
  );
  await assertText(page, "#runtime_multi_select_value", "one,two");
  await assertText(page, "#runtime_multi_select_length", "2");
  // max_items = 2: the unselected "Three" row is disabled and ignores toggle.
  assert.equal(
    await multiItem("Three").getAttribute("aria-disabled"),
    "true",
    "unselected rows should be disabled at the max_items cap"
  );
  // force: Playwright treats aria-disabled as un-clickable; bypass actionability
  // to prove the component itself ignores the toggle at the cap.
  await multiItem("Three").click({ force: true });
  await assertText(page, "#runtime_multi_select_value", "one,two");
  assert.deepEqual(
    await nativeMultiValues(),
    ["one", "two"],
    "hidden native <select multiple> should mirror the selection"
  );
  // Toggle "One" off inside the still-open popup, then close it.
  await multiItem("One").click();
  await assertText(page, "#runtime_multi_select_value", "two");
  await page.keyboard.press("Escape");
  // Remove the remaining chip via its x button.
  await page.locator(`${multiTrigger} .sb-select-chip-remove`).first().click();
  // An empty multiple select reports NULL (Shiny's `selectInput(multiple=TRUE)`
  // semantics for an empty selection), so the bare value goes <NULL>, length 0.
  await assertText(page, "#runtime_multi_select_value", "<NULL>");
  await assertText(page, "#runtime_multi_select_length", "0");
  // Server update sets two values; Backspace on the focused combobox pops the
  // last chip.
  await page.click("#set_multi_select");
  await assertText(page, "#runtime_multi_select_value", "two,three");
  await page.focus(multiTrigger);
  await page.keyboard.press("Backspace");
  await assertText(page, "#runtime_multi_select_value", "two");
  // Server clear (selected = character(0)) empties the selection → NULL.
  await page.click("#clear_multi_select");
  await assertText(page, "#runtime_multi_select_value", "<NULL>");
  // Stale-choice reconciliation: re-select two+three, then push choices that
  // drop "three" — the surviving "two" stays, the removed value is dropped.
  await page.click("#set_multi_select");
  await assertText(page, "#runtime_multi_select_value", "two,three");
  await page.click("#update_multi_choices");
  await assertText(page, "#runtime_multi_select_value", "two");
  // Disabled: native disabled + combobox aria-disabled and removed tab stop.
  await page.click("#disable_multi_select");
  await page.waitForFunction(() => {
    const trigger = document.querySelector("#runtime_multi_select-trigger");
    return document.querySelector("#runtime_multi_select")?.disabled === true &&
      trigger?.getAttribute("aria-disabled") === "true" &&
      trigger?.getAttribute("tabindex") === "-1";
  });
  await page.click("#enable_multi_select");
  await page.waitForFunction(() => {
    const trigger = document.querySelector("#runtime_multi_select-trigger");
    return document.querySelector("#runtime_multi_select")?.disabled === false &&
      trigger?.getAttribute("aria-disabled") === null &&
      trigger?.getAttribute("tabindex") === "0";
  });
  // Server overflow: a `selected` of three values (cap = 2) clamps to the
  // leading two in choice order rather than exceeding the visible cap.
  await page.click("#overflow_multi_select");
  await assertText(page, "#runtime_multi_select_value", "two,four");
  await assertText(page, "#runtime_multi_select_length", "2");
  assert.deepEqual(
    await nativeMultiValues(),
    ["two", "four"],
    "over-cap server selection should clamp the hidden native mirror too"
  );

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

  // Task button: action-button click count classed as a shinyActionButtonValue,
  // a synchronous click lock, automatic reset, the manual-suppression race, and
  // disabled preservation across a ready reset.
  const taskBtn =
    "[data-sb-component='task-button'][data-sb-input-id='runtime_task_button'] [data-slot='task-button']";
  await assertText(page, "#runtime_task_button_value", "0");
  await assertText(page, "#runtime_task_button_class", "shinyActionButtonValue,shiny.actionButton,numeric");

  // Author passthrough reaches the button (title), but reserved attributes
  // never override the runtime's controlled values: the spread sits before the
  // controlled props, so data-slot stays "task-button" (click detection), type
  // stays "button", and the author aria-labelledby is honored while ready.
  assert.equal(
    await page.evaluate((s) => document.querySelector(s)?.getAttribute("title"), taskBtn),
    "Run the task",
    "author title should pass through to the task button"
  );
  assert.equal(
    await page.evaluate((s) => document.querySelector(s)?.getAttribute("data-slot"), taskBtn),
    "task-button",
    "author data-slot must not override the runtime slot"
  );
  assert.equal(
    await page.evaluate((s) => document.querySelector(s)?.getAttribute("type"), taskBtn),
    "button",
    "author type must not override the runtime button type"
  );
  assert.equal(
    await page.evaluate((s) => document.querySelector(s)?.getAttribute("aria-labelledby"), taskBtn),
    "tb_extlabel",
    "ready task button should keep the author aria-labelledby"
  );

  // Hold busy on click: the click locks synchronously and the manual reset
  // suppresses the auto-reset, so it stays disabled+busy.
  //
  // Rapid double-click: dispatch TWO clicks inside a single evaluate, i.e. the
  // same task, before React (or any awaited round-trip) can reconcile. Only the
  // synchronous DOM lock installed by the first click can reject the second, so
  // the server count must be exactly 1. Removing the same-tick lock (and relying
  // on async React state) would let the second click through and report 2.
  await page.click("#tb_hold_on");
  await page.locator(taskBtn).evaluate((node) => {
    node.click();
    node.click();
  });
  await assertText(page, "#runtime_task_button_value", "1");
  await page.waitForFunction((sel) => {
    const b = document.querySelector(sel);
    return b?.disabled === true && b.getAttribute("data-state") === "busy";
  }, taskBtn);

  // While busy the button advertises aria-busy and takes the busy label as its
  // accessible name.
  assert.equal(
    await page.evaluate((s) => document.querySelector(s)?.getAttribute("aria-busy"), taskBtn),
    "true",
    "busy task button should set aria-busy"
  );
  assert.equal(
    await page.evaluate((s) => document.querySelector(s)?.getAttribute("aria-label"), taskBtn),
    "Working",
    "busy task button accessible name should be label_busy"
  );
  assert.equal(
    await page.evaluate((s) => document.querySelector(s)?.hasAttribute("aria-labelledby"), taskBtn),
    false,
    "busy task button should drop aria-labelledby so the busy label wins"
  );

  // Release returns it to ready (re-enabled) and drops the busy ARIA state.
  await page.click("#tb_ready");
  await page.waitForFunction((sel) => {
    const b = document.querySelector(sel);
    return b?.disabled === false && b.getAttribute("data-state") === "ready";
  }, taskBtn);
  assert.equal(
    await page.evaluate((s) => document.querySelector(s)?.hasAttribute("aria-busy"), taskBtn),
    false,
    "ready task button should not set aria-busy"
  );
  assert.equal(
    await page.evaluate((s) => document.querySelector(s)?.hasAttribute("aria-label"), taskBtn),
    false,
    "ready task button without an author label should not keep aria-label"
  );
  assert.equal(
    await page.evaluate((s) => document.querySelector(s)?.getAttribute("aria-labelledby"), taskBtn),
    "tb_extlabel",
    "ready task button should restore the author aria-labelledby"
  );

  // Automatic reset: without the hold, the click flushes and the button returns
  // to ready on its own.
  await page.click("#tb_hold_off");
  await page.click(taskBtn);
  await assertText(page, "#runtime_task_button_value", "2");
  await page.waitForFunction((sel) => {
    const b = document.querySelector(sel);
    return b?.disabled === false && b.getAttribute("data-state") === "ready";
  }, taskBtn);

  // Disabled preservation: an author-disabled button stays disabled across a
  // ready reset and rejects clicks.
  await page.click("#tb_disable");
  await page.waitForFunction((sel) => document.querySelector(sel)?.disabled === true, taskBtn);
  await page.locator(taskBtn).evaluate((node) => node.click());
  await assertText(page, "#runtime_task_button_value", "2");
  await page.click("#tb_ready");
  await page.waitForFunction((sel) => document.querySelector(sel)?.disabled === true, taskBtn);
  await page.click("#tb_enable");
  await page.waitForFunction((sel) => document.querySelector(sel)?.disabled === false, taskBtn);

  // Combined update {state:"busy", disabled:FALSE}: busy must win. A naive
  // field-by-field apply would re-enable using the stale ready state; the merged
  // next state keeps it disabled + busy.
  await page.click("#tb_combined");
  await page.waitForFunction((sel) => {
    const b = document.querySelector(sel);
    return b?.disabled === true && b.getAttribute("data-state") === "busy";
  }, taskBtn);
  await page.click("#tb_ready");
  await page.waitForFunction((sel) => document.querySelector(sel)?.disabled === false, taskBtn);

  // Busy icon honors icon_position: inline-start renders the icon before the
  // busy label, inline-end after it. `iconChildOffset` returns the icon index
  // minus the busy-label index among the button's children.
  const iconChildOffset = (sel) => {
    const b = document.querySelector(sel);
    const kids = Array.from(b.children);
    const iconIdx = kids.findIndex((n) => n.matches && n.matches("svg"));
    const labelIdx = kids.findIndex(
      (n) => n.tagName === "SPAN" && n.getAttribute("aria-hidden") === "true"
    );
    return iconIdx - labelIdx;
  };
  await page.click("#tb_busy_icon");
  await page.click("#tb_hold_on");
  await page.click(taskBtn); // go busy (held)
  await page.waitForFunction((sel) => document.querySelector(sel)?.getAttribute("data-state") === "busy", taskBtn);
  assert.ok(
    (await page.evaluate(iconChildOffset, taskBtn)) < 0,
    "inline-start busy icon should render before the busy label"
  );
  await page.click("#tb_icon_end");
  await page.waitForFunction(
    (sel) => (() => {
      const b = document.querySelector(sel);
      const kids = Array.from(b.children);
      const iconIdx = kids.findIndex((n) => n.matches && n.matches("svg"));
      const labelIdx = kids.findIndex((n) => n.tagName === "SPAN" && n.getAttribute("aria-hidden") === "true");
      return iconIdx > labelIdx;
    })(),
    taskBtn
  );
  // Reset fixture state for any later assertions.
  await page.click("#tb_icon_start");
  await page.click("#tb_hold_off");
  await page.click("#tb_ready");
  await page.waitForFunction((sel) => document.querySelector(sel)?.disabled === false, taskBtn);

  // Exactly one persistent status region — duplicate live regions would
  // double-announce the busy transition.
  const taskRoot =
    "[data-sb-component='task-button'][data-sb-input-id='runtime_task_button']";
  assert.equal(
    await page.evaluate(
      (s) => document.querySelectorAll(`${s} [role='status']`).length,
      taskRoot
    ),
    1,
    "task button should render exactly one status region"
  );

  // Full update coverage: label, variant, size, ready icon, style, and class.
  await page.click("#tb_set_label");
  await page.waitForFunction(
    (sel) => document.querySelector(sel)?.textContent.includes("Relabeled"),
    taskBtn
  );
  await page.click("#tb_set_variant");
  await page.waitForFunction(
    (sel) => document.querySelector(sel)?.getAttribute("data-variant") === "secondary",
    taskBtn
  );
  await page.click("#tb_set_size");
  await page.waitForFunction(
    (sel) => document.querySelector(sel)?.getAttribute("data-size") === "lg",
    taskBtn
  );
  await page.click("#tb_set_icon");
  await page.waitForFunction(
    (sel) => !!document.querySelector(sel)?.querySelector("svg"),
    taskBtn
  );
  await page.click("#tb_set_style");
  await page.waitForFunction(
    (sel) => /22rem/.test(document.querySelector(sel)?.getAttribute("style") || ""),
    taskBtn
  );
  await page.click("#tb_set_class");
  await page.waitForFunction(
    (sel) => document.querySelector(sel)?.classList.contains("tb-updated-class"),
    taskBtn
  );

  // label_busy update is reflected in the busy accessible name AND the live
  // status region the next time the button goes busy.
  await page.click("#tb_set_label_busy");
  await page.click("#tb_hold_on");
  await page.locator(taskBtn).evaluate((node) => node.click());
  await page.waitForFunction(
    (sel) => document.querySelector(sel)?.getAttribute("data-state") === "busy",
    taskBtn
  );
  assert.equal(
    await page.evaluate((s) => document.querySelector(s)?.getAttribute("aria-label"), taskBtn),
    "New busy label",
    "busy aria-label should reflect the updated label_busy"
  );
  assert.equal(
    await page.evaluate(
      (s) => document.querySelector(`${s} [role='status']`)?.textContent?.trim(),
      taskRoot
    ),
    "New busy label",
    "status region should announce the updated busy label"
  );
  await page.click("#tb_hold_off");
  await page.click("#tb_ready");
  await page.waitForFunction(
    (sel) => document.querySelector(sel)?.getAttribute("data-state") === "ready",
    taskBtn
  );

  // Clear semantics via NULL: ready icon, style, and class are removed.
  await page.click("#tb_clear_icon");
  await page.waitForFunction((sel) => !document.querySelector(sel)?.querySelector("svg"), taskBtn);
  await page.click("#tb_clear_style");
  await page.waitForFunction(
    (sel) => !/22rem/.test(document.querySelector(sel)?.getAttribute("style") || ""),
    taskBtn
  );
  await page.click("#tb_clear_class");
  await page.waitForFunction(
    (sel) => !document.querySelector(sel)?.classList.contains("tb-updated-class"),
    taskBtn
  );

  // Clearing the busy icon falls back to the decorative spinner.
  await page.click("#tb_clear_icon_busy");
  await page.click("#tb_hold_on");
  await page.locator(taskBtn).evaluate((node) => node.click());
  await page.waitForFunction(
    (sel) => !!document.querySelector(sel)?.querySelector("svg.sb-task-button-spinner"),
    taskBtn
  );
  await page.click("#tb_hold_off");
  await page.click("#tb_ready");
  await page.waitForFunction(
    (sel) => document.querySelector(sel)?.getAttribute("data-state") === "ready",
    taskBtn
  );

  // Two modules sharing the local id "task" stay independent: clicking module A
  // increments only A's count and locks only A busy (auto_reset = FALSE).
  const modA = "[data-sb-input-id='tbmodA-task'] [data-slot='task-button']";
  const modB = "[data-sb-input-id='tbmodB-task'] [data-slot='task-button']";
  await assertText(page, "#tbmodA-task_value", "0");
  await assertText(page, "#tbmodB-task_value", "0");
  await page.click(modA);
  await assertText(page, "#tbmodA-task_value", "1");
  await assertText(page, "#tbmodB-task_value", "0");
  await page.waitForFunction(
    (sel) => document.querySelector(sel)?.getAttribute("data-state") === "busy",
    modA
  );
  assert.equal(
    await page.evaluate((s) => document.querySelector(s)?.getAttribute("data-state"), modB),
    "ready",
    "second module instance must stay ready when the first is busy"
  );

  // Dynamic renderUI remount + rebind: toggle the mount off and on, then a click
  // on the fresh instance must still report and lock.
  const dynTask = "[data-sb-input-id='dyn_task'] [data-slot='task-button']";
  await page.click("#toggle_task_dynamic");
  await page.waitForSelector(dynTask);
  await page.click(dynTask);
  await assertText(page, "#task_dynamic_value", "1");
  await page.waitForFunction(
    (sel) => document.querySelector(sel)?.getAttribute("data-state") === "busy",
    dynTask
  );
  await page.click("#toggle_task_dynamic"); // unmount
  await page.waitForFunction(() => !document.querySelector("[data-sb-input-id='dyn_task']"));
  await page.click("#toggle_task_dynamic"); // remount
  await page.waitForSelector(dynTask);
  await page.waitForFunction(
    (sel) => document.querySelector(sel)?.getAttribute("data-state") === "ready",
    dynTask
  );
  await page.click(dynTask);
  await page.waitForFunction(
    (sel) => document.querySelector(sel)?.getAttribute("data-state") === "busy",
    dynTask
  );
  await assertText(page, "#task_dynamic_value", "1");

  // insertUI / removeUI remount + rebind: insert a task button, same-tick
  // double-click it (rebind + synchronous lock → server count 1), remove it,
  // then reinsert and confirm the fresh instance rebinds and locks again.
  const insTask = "[data-sb-input-id='inserted_task'] [data-slot='task-button']";
  await page.click("#insert_task");
  await page.waitForSelector(insTask);
  await page.locator(insTask).evaluate((node) => {
    node.click();
    node.click();
  });
  await assertText(page, "#task_inserted_value", "1");
  await page.waitForFunction(
    (sel) => document.querySelector(sel)?.getAttribute("data-state") === "busy",
    insTask
  );
  await page.click("#remove_task");
  await page.waitForFunction(() => !document.querySelector("[data-sb-input-id='inserted_task']"));
  await page.click("#insert_task"); // reinsert
  await page.waitForSelector(insTask);
  await page.waitForFunction(
    (sel) => document.querySelector(sel)?.getAttribute("data-state") === "ready",
    insTask
  );
  await page.locator(insTask).evaluate((node) => node.click());
  await page.waitForFunction(
    (sel) => document.querySelector(sel)?.getAttribute("data-state") === "busy",
    insTask
  );
  await assertText(page, "#task_inserted_value", "1");

  // Regression (#69 review): stale manual state must NOT survive a remount.
  // Set an auto_reset=TRUE button to manual busy, remove it, recreate a fresh
  // one with the same id, then click it — it must auto-reset to ready. A stale
  // manual flag would suppress the reset and leave it busy forever.
  const arTask = "[data-sb-input-id='ar_task'] [data-slot='task-button']";
  await page.click("#toggle_ar_task"); // show
  await page.waitForSelector(arTask);
  await page.click("#ar_task_busy"); // server takes manual control → busy
  await page.waitForFunction(
    (sel) => document.querySelector(sel)?.getAttribute("data-state") === "busy",
    arTask
  );
  await page.click("#toggle_ar_task"); // remove while manual-busy
  await page.waitForFunction(() => !document.querySelector("[data-sb-input-id='ar_task']"));
  await page.click("#toggle_ar_task"); // recreate a fresh ready instance
  await page.waitForSelector(arTask);
  await page.waitForFunction(
    (sel) => document.querySelector(sel)?.getAttribute("data-state") === "ready",
    arTask
  );
  await page.click(arTask);
  await assertText(page, "#ar_task_value", "1"); // click registered on the fresh bind
  // The automatic reset must fire despite the previous instance's manual flag.
  await page.waitForFunction(
    (sel) => {
      const b = document.querySelector(sel);
      return b?.getAttribute("data-state") === "ready" && b?.disabled === false;
    },
    arTask
  );

  // Date picker: the binding reports an ISO string typed `shiny.date`, so the
  // server value is a length-1 Date. Covers initial value, user selection,
  // server update, clear, and disabled state.
  const dateRoot = "[data-sb-component='date-picker'][data-sb-input-id='runtime_date']";
  await assertText(page, "#runtime_date_value", "2026-06-15");
  await assertText(page, "#runtime_date_class", "Date");
  await page.click(`${dateRoot} .sb-date-picker-trigger`);
  await page.waitForSelector("[data-slot='date-picker-content']");
  await page
    .locator("[data-slot='date-picker-content'] .sb-date-picker-day", { hasText: "12" })
    .first()
    .click();
  await assertText(page, "#runtime_date_value", "2026-06-12");
  await page.click("#set_date");
  await assertText(page, "#runtime_date_value", "2026-06-18");
  await page.click("#clear_date");
  await assertText(page, "#runtime_date_value", "<NULL>");
  await page.click("#set_date");
  await assertText(page, "#runtime_date_value", "2026-06-18");
  await page.click("#disable_date");
  await page.waitForFunction((root) => {
    return document.querySelector(`${root} .sb-date-picker-trigger`)?.disabled === true;
  }, dateRoot);
  await page.click("#enable_date");
  await page.waitForFunction((root) => {
    return document.querySelector(`${root} .sb-date-picker-trigger`)?.disabled === false;
  }, dateRoot);

  // Date range picker: the binding reports `[startIso, endIso]` typed
  // `shiny.date`, so the server value is a length-2 Date. Covers initial value,
  // two-click selection, server update, clear, and disabled state.
  const rangeRoot = "[data-sb-component='date-range-picker'][data-sb-input-id='runtime_range']";
  await assertText(page, "#runtime_range_value", "2026-06-12/2026-06-18");
  await assertText(page, "#runtime_range_class", "Date");
  await assertText(page, "#runtime_range_length", "2");
  await page.click(`${rangeRoot} .sb-date-range-picker-trigger`);
  await page.waitForSelector("[data-slot='date-range-picker-content']");
  await page
    .locator("[data-slot='date-range-picker-content'] .sb-date-range-picker-day", { hasText: "13" })
    .first()
    .click();
  await page
    .locator("[data-slot='date-range-picker-content'] .sb-date-range-picker-day", { hasText: "16" })
    .first()
    .click();
  await assertText(page, "#runtime_range_value", "2026-06-13/2026-06-16");
  await page.click("#set_range");
  await assertText(page, "#runtime_range_value", "2026-06-13/2026-06-17");
  await page.click("#clear_range");
  await assertText(page, "#runtime_range_value", "<NULL>");
  await page.click("#set_range");
  await assertText(page, "#runtime_range_value", "2026-06-13/2026-06-17");
  await page.click("#disable_range");
  await page.waitForFunction((root) => {
    return document.querySelector(`${root} .sb-date-range-picker-trigger`)?.disabled === true;
  }, rangeRoot);
  await page.click("#enable_range");
  await page.waitForFunction((root) => {
    return document.querySelector(`${root} .sb-date-range-picker-trigger`)?.disabled === false;
  }, rangeRoot);

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

  // dragover must always cancel the browser default — otherwise a real OS file
  // drop navigates the page instead of being safely ignored. The drop handler
  // bypasses this requirement, so assert it directly. A disabled dropzone still
  // cancels the default but does NOT enter the dragover (highlight) state.
  const dispatchDragOver = (selector) =>
    page.evaluate((selector) => {
      const el = document.querySelector(selector);
      if (!el) throw new Error(`dragover target not found: ${selector}`);
      const evt = new DragEvent("dragover", {
        bubbles: true,
        cancelable: true,
        dataTransfer: new DataTransfer()
      });
      // defaultPrevented is observable synchronously; the data-dragover
      // attribute lags a React render tick, so callers poll for it separately.
      return !el.dispatchEvent(evt);
    }, selector);

  assert.equal(
    await dispatchDragOver(".runtime-file-dropzone-fixture"),
    true,
    "enabled dropzone dragover should cancel default"
  );
  await page.waitForFunction(
    () =>
      document.querySelector(".runtime-file-dropzone-fixture")?.getAttribute("data-dragover") ===
      "true"
  );

  assert.equal(
    await dispatchDragOver(".runtime-file-dropzone-disabled-fixture"),
    true,
    "disabled dropzone dragover should still cancel default"
  );
  assert.equal(
    await page.evaluate(
      () =>
        document
          .querySelector(".runtime-file-dropzone-disabled-fixture")
          ?.getAttribute("data-dragover")
    ),
    null,
    "disabled dropzone dragover should not set data-dragover"
  );

  // Custom-content dropzone: the drop bridge still reaches input$<id> while the
  // surface is a drop region rather than a button.
  await assertText(page, "#runtime_file_dropzone_custom_value", "<NULL>");
  await dropFiles(".runtime-file-dropzone-custom-fixture", [
    { name: "custom.txt", type: "text/plain", content: "custom drop\n" }
  ]);
  await assertText(
    page,
    "#runtime_file_dropzone_custom_value",
    "name=custom.txt cols=name,size,type,datapath rows=1"
  );

  // Browse opens only from the explicit [data-dropzone-trigger]; a plain surface
  // click is inert (no nested-button double-trigger). Spy on native.click().
  const triggerClicks = await page.evaluate(() => {
    const native = document.querySelector("#runtime_file_dropzone_custom");
    let count = 0;
    native.click = () => {
      count += 1;
    };
    const surface = document.querySelector(".runtime-file-dropzone-custom-fixture");
    surface.querySelector("strong").click(); // non-trigger element -> inert
    const afterInert = count;
    document.querySelector("#runtime_file_dropzone_custom_trigger").click(); // trigger -> opens picker
    return { afterInert, afterTrigger: count };
  });
  assert.equal(triggerClicks.afterInert, 0, "non-trigger surface click should not open the picker");
  assert.equal(triggerClicks.afterTrigger, 1, "clicking [data-dropzone-trigger] should open the picker");

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

  // Toaster: server fires a toast, it renders in the portal and reports a
  // `{action, id, seq}` event (formatted "action:id:seq"); a second fire stacks;
  // the close button reports a dismiss event; dismiss-all clears the stack and
  // reports a dismiss with a null id. Toasts use duration:0 so the auto-dismiss
  // timer does not race the asserts. `seq` increments on every event.
  await assertText(page, "#runtime_toaster_value", "<NULL>");
  await page.click("#fire_toast");
  await page
    .locator("[data-shinyblocks-portal-root] [data-slot='toast']")
    .waitFor({ state: "visible" });
  await assertText(page, "#runtime_toaster_value", "show:smoke-1:1");
  assert.equal(
    await page.evaluate(() =>
      document
        .querySelector("[data-shinyblocks-portal-root] [data-slot='toast']")
        ?.hasAttribute("tabindex")
    ),
    false,
    "toast surface should not add a passive tab stop"
  );
  // Live reposition via update_block_toaster() — the region re-anchors without
  // re-mounting and without disturbing the visible toast.
  assert.equal(
    await page.getAttribute(
      "[data-shinyblocks-portal-root] [data-slot='toaster']",
      "data-position"
    ),
    "bottom-right",
    "toaster should start at its mounted position"
  );
  await page.click("#move_toaster");
  await page.waitForFunction(() => {
    const region = document.querySelector(
      "[data-shinyblocks-portal-root] [data-slot='toaster']"
    );
    return region && region.getAttribute("data-position") === "top-left";
  });
  await page.click("#fire_toast");
  await page.waitForFunction(() => {
    return (
      document.querySelectorAll(
        "[data-shinyblocks-portal-root] [data-slot='toast']"
      ).length === 2
    );
  });
  await assertText(page, "#runtime_toaster_value", "show:smoke-2:2");
  await page.click(
    "[data-shinyblocks-portal-root] [data-slot='toast']:last-child [data-slot='toast-close']"
  );
  await page.waitForFunction(() => {
    return (
      document.querySelectorAll(
        "[data-shinyblocks-portal-root] [data-slot='toast']"
      ).length === 1
    );
  });
  await assertText(page, "#runtime_toaster_value", "dismiss:smoke-2:3");
  await page.click("#dismiss_toasts");
  await page.waitForFunction(() => {
    return !document.querySelector(
      "[data-shinyblocks-portal-root] [data-slot='toast']"
    );
  });
  await assertText(page, "#runtime_toaster_value", "dismiss:-:4");

  await page.evaluate(() => {
    const root = document.querySelector(
      "[data-sb-component='toaster'][data-sb-input-id='runtime_toaster']"
    );
    if (typeof root?.__sbToasterReceive !== "function") {
      throw new Error("toaster receive handler is not installed");
    }
    root.__sbToasterReceive({
      notify: false,
      toast: {
        id: "client-a",
        variant: "default",
        titleHtml: "<div>Client A</div>",
        duration: 0,
        dismissible: true
      }
    });
    root.__sbToasterReceive({
      notify: false,
      toast: {
        id: "client-b",
        variant: "default",
        titleHtml: "<div>Client B</div>",
        duration: 0,
        dismissible: true
      }
    });
    root.__sbToasterReceive({
      notify: false,
      toast: {
        id: "client-a",
        variant: "default",
        titleHtml: "<div>Client A updated</div>",
        duration: 0,
        dismissible: true
      }
    });
  });
  await page.waitForFunction(() => {
    const texts = Array.from(
      document.querySelectorAll("[data-shinyblocks-portal-root] [data-slot='toast']")
    ).map((toast) => toast.textContent);
    return (
      texts.length === 2 &&
      texts[0].includes("Client A updated") &&
      texts[1].includes("Client B")
    );
  });
  await page.evaluate(() => {
    document
      .querySelector("[data-sb-component='toaster'][data-sb-input-id='runtime_toaster']")
      ?.__sbToasterReceive({ action: "dismiss", notify: false });
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

  // Progress: receive-only display block driven entirely by the server. The
  // bare input stays NULL while update/increment helpers move the bar; clearing
  // the message collapses its node; indeterminate drops the percent.
  const progressRoot = "[data-sb-component='progress'][data-sb-input-id='runtime_progress']";
  const progressValueAttr = (attr) => page.getAttribute(`${progressRoot} [data-slot='progress-track']`, attr);
  await assertText(page, "#runtime_progress_value", "<NULL>");
  await assertText(page, `${progressRoot} [data-slot='progress-value']`, "25%");
  await page.click("#set_progress_75");
  await assertText(page, `${progressRoot} [data-slot='progress-value']`, "75%");
  await assertText(page, `${progressRoot} [data-slot='progress-message']`, "Three quarters");
  assert.equal(await progressValueAttr("aria-valuenow"), "0.75", "server set should drive aria-valuenow");
  await assertText(page, "#runtime_progress_value", "<NULL>");
  await page.click("#inc_progress");
  await page.waitForFunction(
    (root) => document.querySelector(`${root} [data-slot='progress-value']`)?.textContent === "85%",
    progressRoot
  );
  await page.click("#reset_progress");
  await assertText(page, `${progressRoot} [data-slot='progress-value']`, "0%");
  assert.equal(
    await page.locator(`${progressRoot} [data-slot='progress-message']`).count(),
    0,
    "resetting with message = NULL should clear the message node"
  );
  await page.click("#indeterminate_progress");
  await page.waitForFunction(
    (root) => document.querySelector(`${root} [data-slot='progress-track']`)?.getAttribute("data-indeterminate") === "true",
    progressRoot
  );
  assert.equal(await progressValueAttr("aria-valuenow"), null, "indeterminate progress should drop aria-valuenow");
  assert.equal(
    await page.locator(`${progressRoot} [data-slot='progress-value']`).count(),
    0,
    "indeterminate progress should suppress the percent"
  );

  // Race regression: a fresh progress bar inserted and updated in the same flush
  // must show the update (60%), proving the binding queues messages that arrive
  // before the React mount effect installs the receive handler (not dropped).
  const lateProgress = "[data-sb-component='progress'][data-sb-input-id='late_progress']";
  await page.click("#insert_late_progress");
  await page.waitForFunction(
    (root) => document.querySelector(`${root} [data-slot='progress-value']`)?.textContent === "60%",
    lateProgress
  );
  await assertText(page, `${lateProgress} [data-slot='progress-message']`, "Late update");

  await assertText(page, "#mod-value", "m0");
  await assertText(page, "#mod-upload_value", "<NULL>");
  await page.setInputFiles("#mod-upload", uploadPath);
  await assertText(page, "#mod-upload_value", "shinyblocks-runtime-upload.txt");
  await assertText(page, "#mod-date_value", "2026-06-15");

  // Under a moduleServer the namespaced progress mount registers its
  // receive-only binding and reports no Shiny input value.
  const modProgress = "[data-sb-component='progress'][data-sb-input-id='mod-progress']";
  await assertText(page, `${modProgress} [data-slot='progress-value']`, "10%");
  await assertText(page, "#mod-progress_value", "<NULL>");

  // Server-driven update from inside the module must route to the ns-baked mount
  // (issue #63): a regressed updater double-namespaces the target and the value
  // never changes off 10%.
  await page.click("#mod-set_progress_60");
  await assertText(page, `${modProgress} [data-slot='progress-value']`, "60%");

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
