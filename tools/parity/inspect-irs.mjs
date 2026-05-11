import { chromium } from "playwright";
const browser = await chromium.launch();
const page = await browser.newPage();
await page.goto("http://127.0.0.1:4321/#slider", { waitUntil: "networkidle" });
await page.waitForSelector('[data-sb-section="slider"] .irs--shiny .irs-handle', { state: "visible", timeout: 5000 });
const dump = await page.evaluate(() => {
  const root = document.querySelector('[data-sb-section="slider"] .sb-slider .irs--shiny');
  const innerIrs = root.querySelector(':scope > .irs');
  const line = root.querySelector('.irs-line');
  const handle = root.querySelector('.irs-handle');
  const get = (el) => {
    if (!el) return null;
    const cs = window.getComputedStyle(el);
    const b = el.getBoundingClientRect();
    return { tag: el.tagName, cls: el.className, position: cs.position, top: cs.top, height: cs.height, rect: { y: b.y, h: b.height } };
  };
  return {
    container: get(root),
    innerIrs: get(innerIrs),
    rail: get(line),
    handle: get(handle),
    railParent: line && line.parentElement ? get(line.parentElement) : null,
    handleParent: handle && handle.parentElement ? get(handle.parentElement) : null,
  };
});
console.log(JSON.stringify(dump, null, 2));
await browser.close();
