import assert from "node:assert/strict";
import { spawn } from "node:child_process";
import { chromium } from "playwright";

const port = 4329;
const url = `http://127.0.0.1:${port}`;
const shiny = spawn("Rscript", ["tools/preflight-isolation-shiny-fixture.R", String(port)]);
const delay = (ms) => new Promise((resolve) => setTimeout(resolve, ms));
let browser;

const properties = {
  heading: ["fontFamily", "fontSize", "fontWeight", "marginTop", "marginBottom"],
  list: ["listStyleType", "marginTop", "marginBottom", "paddingLeft"],
  table: ["borderCollapse", "borderSpacing"],
  button: ["fontFamily", "borderTopWidth", "borderRadius", "backgroundColor", "paddingLeft"],
  input: ["fontFamily", "borderTopWidth", "borderRadius", "backgroundColor", "paddingLeft"],
  select: ["fontFamily", "borderTopWidth", "borderRadius", "backgroundColor"],
  textarea: ["fontFamily", "borderTopWidth", "borderRadius", "backgroundColor"],
  svg: ["display", "verticalAlign"],
  iframe: ["display", "verticalAlign"],
  selectize: ["boxSizing", "paddingLeft", "borderTopWidth"],
  card: ["boxSizing", "marginTop", "paddingLeft", "borderTopWidth", "borderRadius"],
  widget: ["boxSizing", "position", "marginTop", "borderTopWidth"]
};

try {
  for (let attempt = 0; attempt < 80; attempt += 1) {
    try {
      if ((await fetch(url)).ok) break;
    } catch {}
    await delay(250);
  }
  browser = await chromium.launch({ headless: true });
  const page = await browser.newPage();
  await page.goto(url);
  await page.locator("#inside-fixture").waitFor();

  for (const [name, fields] of Object.entries(properties)) {
    const values = await page.evaluate(({ name, fields }) => {
      const read = (prefix) => {
        const styles = getComputedStyle(document.querySelector(`#${prefix}-${name}`));
        return Object.fromEntries(fields.map((field) => [field, styles[field]]));
      };
      return { inside: read("inside"), outside: read("outside") };
    }, { name, fields });
    assert.deepEqual(values.inside, values.outside, `${name} should retain host computed styles inside block_page()`);
  }

  for (const prefix of ["inside", "outside"]) {
    await page.locator(`#${prefix}-button`).focus();
    assert.deepEqual(await page.locator(`#${prefix}-button`).evaluate((node) => {
      const styles = getComputedStyle(node);
      return { style: styles.outlineStyle, width: styles.outlineWidth, color: styles.outlineColor };
    }), { style: "solid", width: "5px", color: "rgb(90, 10, 20)" });
  }

  assert.equal(await page.locator(".owned-card-check").evaluate((node) => getComputedStyle(node).boxSizing), "border-box");
  assert.notEqual(await page.locator(".owned-card-check").evaluate((node) => getComputedStyle(node).borderRadius), "0px");
  console.log("Preflight host-isolation Shiny smoke test passed.");
} finally {
  if (browser) await browser.close();
  shiny.kill("SIGTERM");
}
