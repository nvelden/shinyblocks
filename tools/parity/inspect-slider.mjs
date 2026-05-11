import { chromium } from "playwright";
const browser = await chromium.launch();
const page = await browser.newPage();
await page.goto("http://127.0.0.1:4321/#slider", { waitUntil: "networkidle" });
await page.waitForSelector('[data-sb-section="slider"] .irs--shiny .irs-handle', { state: "visible", timeout: 5000 });

const dump = await page.evaluate(() => {
  const root = '[data-sb-section="slider"] .sb-slider .irs--shiny';
  const r = document.querySelector(`${root} .irs-line`);
  const handles = Array.from(document.querySelectorAll(`${root} .irs-handle`));
  return {
    container: (() => {
      const c = document.querySelector(root);
      const cs = window.getComputedStyle(c);
      const b = c.getBoundingClientRect();
      return { height: cs.height, position: cs.position, rect: { y: b.y, h: b.height } };
    })(),
    rail: (() => {
      const cs = window.getComputedStyle(r);
      const b = r.getBoundingClientRect();
      return { top: cs.top, height: cs.height, rect: { y: b.y, h: b.height } };
    })(),
    handles: handles.map((h) => {
      const cs = window.getComputedStyle(h);
      const b = h.getBoundingClientRect();
      return {
        classes: h.className,
        top: cs.top,
        height: cs.height,
        display: cs.display,
        visibility: cs.visibility,
        rect: { y: b.y, h: b.height, w: b.width },
        offsetParent: h.offsetParent ? h.offsetParent.className : null,
      };
    }),
  };
});

console.log(JSON.stringify(dump, null, 2));
await browser.close();
