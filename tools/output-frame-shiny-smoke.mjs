import assert from "node:assert/strict";
import { spawn } from "node:child_process";
import { chromium } from "playwright";

const port = 4327;
const url = `http://127.0.0.1:${port}`;
const shiny = spawn("Rscript", ["tools/output-frame-shiny-fixture.R", String(port)]);
const delay = (ms) => new Promise((resolve) => setTimeout(resolve, ms));
let browser;

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
  await page.locator(".standalone-plot-fixture img").waitFor({ state: "visible" });

  const style = async (selector, property) => page.locator(selector).evaluate(
    (node, prop) => getComputedStyle(node)[prop], property
  );
  assert.equal(await style(".sb-output-media", "aspectRatio"), "16 / 9");
  assert.equal(await style(".sb-output-media", "borderTopWidth"), "1px");
  assert.equal(await style(".sb-output-media", "borderTopColor"), "rgb(11, 22, 33)");
  assert.equal(await style(".sb-output-caption", "color"), "rgb(77, 88, 99)");
  assert.equal(await page.locator("#standalone_plot").getAttribute("data-click-id"), "standalone_plot_click");

  const oldSrc = await page.locator(".standalone-plot-fixture img").getAttribute("src");
  await page.click("#redraw");
  await page.waitForFunction((src) => {
    return document.querySelector(".standalone-plot-fixture img")?.getAttribute("src") !== src;
  }, oldSrc);
  console.log("Standalone output-frame Shiny smoke test passed.");
} finally {
  if (browser) await browser.close();
  shiny.kill("SIGTERM");
}
