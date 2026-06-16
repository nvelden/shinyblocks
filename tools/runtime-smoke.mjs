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
const dateRangePayload = JSON.stringify({
  schemaVersion: 1,
  component: "date-range-picker",
  id: "runtime_range",
  props: {
    separator: " to ",
    placeholder: "Pick a date range",
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
  state: { start: "2026-06-12", end: "2026-06-18" },
  binding: { input: true, type: "shinyblocks.date-range-picker" },
  className: null
});
const progressPayload = JSON.stringify({
  schemaVersion: 1,
  component: "progress",
  id: "runtime_progress",
  props: {
    message: "Importing rows",
    detail: "batch 1/4",
    label: "Upload",
    showValue: true,
    variant: "default",
    style: {}
  },
  slots: {},
  children: [],
  state: { value: 0.25, min: 0, max: 1, indeterminate: false },
  binding: { input: true, type: "shinyblocks.progress" },
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
        <div id="runtime-range" data-shinyblocks-root data-shinyblocks-runtime="true" data-sb-component="date-range-picker" data-sb-input-id="runtime_range">
          <script type="application/json" data-shinyblocks-payload>${dateRangePayload}</script>
          <div data-shinyblocks-react></div>
          <div data-shinyblocks-children><input type="text" class="sb-date-range-picker-native" id="runtime_range" value="2026-06-12/2026-06-18" /></div>
        </div>
        <div id="runtime-progress" data-shinyblocks-root data-shinyblocks-runtime="true" data-sb-component="progress" data-sb-input-id="runtime_progress">
          <script type="application/json" data-shinyblocks-payload>${progressPayload}</script>
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

  // Date range picker: trigger renders both endpoints, out-of-bounds days are
  // disabled, the first click anchors without committing (popover stays open and
  // the reported value is unchanged), and the second click commits the ordered
  // pair — reversed clicks swap — writing the `[start, end]` expando + the
  // delimited hidden native input.
  assert.equal(
    await page.locator("#runtime-range .sb-date-range-picker-value").textContent(),
    "2026-06-12 to 2026-06-18",
    "date range picker should render both endpoints in the trigger label"
  );
  await page.locator("#runtime-range .sb-date-range-picker-trigger").click();
  await page.waitForSelector("[data-slot='date-range-picker-content']");
  assert.equal(
    await page.locator("[data-slot='date-range-picker-content'] .sb-date-range-picker-day", { hasText: "9" }).first().isDisabled(),
    true,
    "range days before min should be disabled"
  );
  // First click (later day) anchors the selection but does not commit.
  await page.locator("[data-slot='date-range-picker-content'] .sb-date-range-picker-day", { hasText: "16" }).first().click();
  assert.equal(
    await page.locator("[data-slot='date-range-picker-content']").count(),
    1,
    "first range click should keep the popover open"
  );
  assert.deepEqual(
    await page.locator("#runtime-range").evaluate((node) => node.__sbDateRangePickerValue),
    { start: "2026-06-12", end: "2026-06-18" },
    "first range click should not change the committed range"
  );
  // Hovering an earlier day makes the *moving* endpoint (now the start) the
  // tentative one — it must carry data-preview, not paint as a committed end.
  await page.locator("[data-slot='date-range-picker-content'] .sb-date-range-picker-day", { hasText: "14" }).first().hover();
  assert.equal(
    await page.locator("[data-slot='date-range-picker-content'] .sb-date-range-picker-day", { hasText: "14" }).first().getAttribute("data-preview"),
    "true",
    "leftward hover should mark the moving start endpoint as a preview"
  );
  // Second click (earlier day) commits the swapped, ordered range and closes.
  await page.locator("[data-slot='date-range-picker-content'] .sb-date-range-picker-day", { hasText: "14" }).first().click();
  await page.waitForSelector("[data-slot='date-range-picker-content']", { state: "detached" });
  assert.deepEqual(
    await page.locator("#runtime-range").evaluate((node) => node.__sbDateRangePickerValue),
    { start: "2026-06-14", end: "2026-06-16" },
    "committing a reversed range should swap into ascending order"
  );
  assert.equal(
    await page.locator("#runtime-range input.sb-date-range-picker-native").inputValue(),
    "2026-06-14/2026-06-16",
    "committing a range should update the delimited hidden native input"
  );
  assert.equal(
    await page.locator("#runtime-range .sb-date-range-picker-value").textContent(),
    "2026-06-14 to 2026-06-16",
    "committing a range should update the trigger label"
  );

  // Keyboard navigation: open, arrow around, Home, commit via Enter, and cancel
  // a draft via Escape — asserting `document.activeElement` throughout. The
  // arrow-nav assertions are the regression guard for the focus-cleanup bug:
  // changing the focused day must NOT tear down the popover/return-focus effect.
  const activeText = () =>
    page.evaluate(() => document.activeElement && document.activeElement.textContent);
  const waitForTriggerFocus = () =>
    page.waitForFunction(() =>
      Boolean(document.activeElement && document.activeElement.classList.contains("sb-date-range-picker-trigger"))
    );
  const activeIsTrigger = () =>
    page.evaluate(() =>
      Boolean(document.activeElement && document.activeElement.classList.contains("sb-date-range-picker-trigger"))
    );

  // Clear the bounds so keyboard nav can roam the whole month (days past the
  // 06-20 max would otherwise be disabled and unable to take focus).
  await page.locator("#runtime-range").evaluate((node) => node.__sbDateRangePickerReceive({ min: null, max: null }));

  // ARIA grid is well-formed: weeks are `role="row"` and days `role="gridcell"`.
  await page.locator("#runtime-range .sb-date-range-picker-trigger").click();
  await page.waitForSelector("[data-slot='date-range-picker-content']");
  assert.ok(
    (await page.locator("[data-slot='date-range-picker-content'] [role='row']").count()) >= 5,
    "range calendar should wrap each week in a role=row"
  );
  assert.ok(
    (await page.locator("[data-slot='date-range-picker-content'] .sb-date-range-picker-day[role='gridcell']").count()) > 0,
    "range day cells should keep role=gridcell"
  );

  // On open, focus lands on the committed start (14).
  assert.equal(await activeText(), "14", "open should focus the committed start day");
  // ArrowRight + ArrowDown move focus; the popover stays open (regression guard).
  await page.keyboard.press("ArrowRight");
  assert.equal(await activeText(), "15", "ArrowRight should move focus a day forward");
  await page.keyboard.press("ArrowDown");
  assert.equal(await activeText(), "22", "ArrowDown should move focus a week forward");
  assert.equal(
    await page.locator("[data-slot='date-range-picker-content']").count(),
    1,
    "arrow navigation must not close the popover"
  );
  assert.equal(await activeIsTrigger(), false, "arrow navigation must not return focus to the trigger");
  // Home jumps to the first day of the focused week. 2026-06-22 is a Monday;
  // weekstart 0 (Sunday) → the row starts on 2026-06-21.
  await page.keyboard.press("Home");
  assert.equal(await activeText(), "21", "Home should focus the first day of the week (weekstart Sunday)");
  // Enter anchors the first endpoint (popover stays open), ArrowRight previews,
  // Enter commits the second endpoint and returns focus to the trigger.
  await page.keyboard.press("Enter");
  assert.equal(
    await page.locator("[data-slot='date-range-picker-content']").count(),
    1,
    "first Enter should anchor without closing"
  );
  await page.keyboard.press("ArrowRight");
  await page.keyboard.press("ArrowRight");
  await page.keyboard.press("Enter");
  await page.waitForSelector("[data-slot='date-range-picker-content']", { state: "detached" });
  await waitForTriggerFocus();
  assert.equal(await activeIsTrigger(), true, "committing via Enter should return focus to the trigger");
  assert.deepEqual(
    await page.locator("#runtime-range").evaluate((node) => node.__sbDateRangePickerValue),
    { start: "2026-06-21", end: "2026-06-23" },
    "keyboard Enter/Enter should commit the ordered range"
  );

  // Escape during a draft cancels the in-progress selection and returns focus.
  await page.locator("#runtime-range .sb-date-range-picker-trigger").click();
  await page.waitForSelector("[data-slot='date-range-picker-content']");
  await page.keyboard.press("Enter"); // anchor a draft
  await page.keyboard.press("ArrowRight");
  await page.keyboard.press("Escape");
  await page.waitForSelector("[data-slot='date-range-picker-content']", { state: "detached" });
  await waitForTriggerFocus();
  assert.equal(await activeIsTrigger(), true, "Escape should return focus to the trigger");
  assert.deepEqual(
    await page.locator("#runtime-range").evaluate((node) => node.__sbDateRangePickerValue),
    { start: "2026-06-21", end: "2026-06-23" },
    "Escape during a draft must leave the committed range unchanged"
  );

  // Progress: receive-only display block. The mount renders the determinate
  // track/indicator, header (label + message), detail, and the rounded percent;
  // `__sbProgressReceive` drives set/increment/clamp/range-repair and ARIA.
  const progressTrack = "#runtime-progress [data-slot='progress-track']";
  const progressIndicatorTransform = () =>
    page.locator("#runtime-progress [data-slot='progress-indicator']").evaluate((node) => node.style.transform);
  const sendProgress = (data) =>
    page.locator("#runtime-progress").evaluate((node, payload) => node.__sbProgressReceive(payload), data);

  assert.equal(
    await page.locator(`${progressTrack}`).getAttribute("aria-valuenow"),
    "0.25",
    "progress should expose the raw clamped value as aria-valuenow"
  );
  assert.equal(
    await page.locator(`${progressTrack}`).getAttribute("aria-valuetext"),
    "25%",
    "progress aria-valuetext should be the rounded percent"
  );
  assert.equal(
    await page.locator("#runtime-progress [data-slot='progress-value']").textContent(),
    "25%",
    "progress should render the rounded percent when show_value is set"
  );
  assert.equal(
    await progressIndicatorTransform(),
    "translateX(-75%)",
    "progress indicator should offset by (100 - percent)%"
  );
  assert.equal(
    await page.locator("#runtime-progress [data-slot='progress-label']").textContent(),
    "Upload",
    "progress should render the label as the header primary line"
  );
  assert.equal(
    await page.locator("#runtime-progress [data-slot='progress-message']").textContent(),
    "Importing rows",
    "progress should render the message beneath the label"
  );
  assert.equal(
    await page.locator("#runtime-progress [data-slot='progress-detail']").textContent(),
    "batch 1/4",
    "progress should render the detail line below the track"
  );

  // Set updates the value/percent/ARIA together.
  await sendProgress({ value: 0.6 });
  assert.equal(
    await page.locator(`${progressTrack}`).getAttribute("aria-valuenow"),
    "0.6",
    "progress set should update aria-valuenow"
  );
  assert.equal(
    await page.locator("#runtime-progress [data-slot='progress-value']").textContent(),
    "60%",
    "progress set should update the rendered percent"
  );

  // Increment saturates at max; a large negative increment saturates at min.
  await sendProgress({ action: "increment", amount: 0.9 });
  assert.equal(
    await page.locator(`${progressTrack}`).getAttribute("aria-valuenow"),
    "1",
    "progress increment should saturate at max (no overflow)"
  );
  assert.equal(await progressIndicatorTransform(), "translateX(0%)", "saturated progress should fill the track");
  await sendProgress({ action: "increment", amount: -5 });
  assert.equal(
    await page.locator(`${progressTrack}`).getAttribute("aria-valuenow"),
    "0",
    "negative progress increment should saturate at min"
  );

  // Range-repair: a single-endpoint update that inverts the current bounds is
  // reconciled (endpoints swap so min < max holds) and the value is re-clamped.
  await sendProgress({ value: 0.5 });
  await sendProgress({ min: 2 });
  assert.deepEqual(
    {
      min: await page.locator(`${progressTrack}`).getAttribute("aria-valuemin"),
      max: await page.locator(`${progressTrack}`).getAttribute("aria-valuemax"),
      now: await page.locator(`${progressTrack}`).getAttribute("aria-valuenow")
    },
    { min: "1", max: "2", now: "1" },
    "inverting the client bounds should swap endpoints and re-clamp the value"
  );

  // Clearing a text field with the null sentinel collapses its node.
  await sendProgress({ message: null });
  assert.equal(
    await page.locator("#runtime-progress [data-slot='progress-message']").count(),
    0,
    "clearing the message should remove its node"
  );

  // Indeterminate mode drops the determinate ARIA + percent and flags the track.
  await sendProgress({ indeterminate: true });
  assert.equal(
    await page.locator(`${progressTrack}`).getAttribute("aria-valuenow"),
    null,
    "indeterminate progress should omit aria-valuenow"
  );
  assert.equal(
    await page.locator(`${progressTrack}`).getAttribute("aria-busy"),
    "true",
    "indeterminate progress should mark the bar busy"
  );
  assert.equal(
    await page.locator("#runtime-progress [data-slot='progress-value']").count(),
    0,
    "indeterminate progress should suppress the percent"
  );
  assert.equal(
    await page.locator(`${progressTrack}`).getAttribute("data-indeterminate"),
    "true",
    "indeterminate progress should flag the track"
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
