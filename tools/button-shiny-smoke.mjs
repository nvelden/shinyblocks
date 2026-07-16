import assert from "node:assert/strict";
import { spawn } from "node:child_process";
import { chromium } from "playwright";

const port = 4328;
const url = `http://127.0.0.1:${port}`;
const shiny = spawn("Rscript", ["tools/button-shiny-fixture.R", String(port)]);
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
  const button = "[data-sb-input-id='run'] [data-slot='button']";
  await page.locator(button).waitFor();

  assert.deepEqual(await page.locator(button).evaluate((node) => ({
    type: node.type,
    slot: node.dataset.slot,
    title: node.title,
    name: node.name,
    ariaLabel: node.getAttribute("aria-label"),
    customData: node.dataset.testButton,
    hasRuntimeClass: node.classList.contains("sb-button"),
    hasAuthorClass: node.classList.contains("author-class"),
    width: node.style.width
  })), {
    type: "button",
    slot: "button",
    title: "Run title",
    name: "run-name",
    ariaLabel: "Run action",
    customData: "preserved",
    hasRuntimeClass: true,
    hasAuthorClass: true,
    width: "100px"
  });

  await page.click(button);
  await page.waitForFunction(() => document.querySelector("#click_value")?.textContent?.trim() === "1");
  await page.click("#resize");
  await page.waitForFunction((selector) => document.querySelector(selector)?.style.width === "200px", button);
  await page.click("#clear_style");
  await page.waitForFunction((selector) => document.querySelector(selector)?.style.width === "", button);
  await page.click(button);
  await page.waitForFunction(() => document.querySelector("#click_value")?.textContent?.trim() === "2");
  console.log("Button Shiny smoke test passed.");
} finally {
  if (browser) await browser.close();
  shiny.kill("SIGTERM");
}
