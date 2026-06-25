import { existsSync, readdirSync, readFileSync } from "node:fs";
import path from "node:path";
import { test, expect } from "@playwright/test";
import { PATH } from "./paths";

test("component detail page displays preview and code block", async ({ page }) => {
  await page.goto(PATH.componentDetail("button"));
  
  // Renders the header and details.
  await expect(page.getByRole("heading", { level: 1, name: "Button" })).toBeVisible();
  
  // Displays R Code section and recipe content.
  await expect(page.getByRole("heading", { level: 2, name: "R Code" })).toBeVisible();
  const codeBlock = page.locator("[data-sb-component='code']").last();
  await expect(codeBlock).toContainText("shinyblocks::block_button");
  await expect(codeBlock.locator(".sb-code-block-pre")).toHaveCSS("overflow-x", "hidden");
  const overflow = await codeBlock.locator(".sb-code-block-pre").evaluate((node) => {
    return node.scrollWidth > node.clientWidth + 1;
  });
  expect(overflow).toBe(false);
  
  // Navigation back works.
  await page.getByRole("link", { name: /Back to Components/ }).click();
  await expect(page).toHaveURL(PATH.components);
});

test("layout primitives page exposes the family API", async ({ page }) => {
  await page.goto(PATH.componentDetail("layout-primitives"));

  await expect(page.getByRole("heading", { level: 1, name: "Layout Primitives" })).toBeVisible();
  await expect(page.getByText("block_stack", { exact: true })).toBeVisible();
  await expect(page.getByText("block_cluster", { exact: true })).toBeVisible();
  await expect(page.getByText("block_grid", { exact: true })).toBeVisible();

  const playground = page.locator('iframe[title="Layout Primitives playground"]');
  await expect(playground).toBeVisible();
});

// Guards the migrated docs playgrounds against losing their two-column split.
//
// The responsive split is pure CSS: the migrated playgrounds wrap controls +
// main in `block_cluster(class = "showcase-playground__split")`, and the runtime
// override stylesheet turns that into a flex row at desktop width. A unit/render
// test that only inspects the R markup cannot tell whether the columns actually
// land side by side, so we exercise the real stylesheet against the real class
// structure in a browser and measure the laid-out boxes. Booting the full webR
// playground is unreliable in CI (Shinylive needs a COI service-worker reload
// for SharedArrayBuffer), so we load the override CSS directly instead.
const OVERRIDE_CSS = readFileSync(
  path.resolve(__dirname, "../../public/shinyblocks-runtime-override.css"),
  "utf8",
);

// `main` is given content far taller than the cap so we can prove the frame
// stays fixed-height and scrolls internally instead of stretching the page.
const playgroundMarkup = `<!doctype html><html><head><meta charset="utf-8">
  <style>${OVERRIDE_CSS}</style></head>
  <body><div class="showcase-playground">
    <div class="showcase-playground__split">
      <div class="showcase-playground__controls">controls</div>
      <div class="showcase-playground__main"><div style="height:2000px">main</div></div>
    </div>
  </div></body></html>`;

test("playground split CSS yields a capped two-column layout at desktop width", async ({ page }) => {
  await page.setViewportSize({ width: 1280, height: 900 });
  await page.setContent(playgroundMarkup);

  const split = await page.locator(".showcase-playground__split").boundingBox();
  const controls = await page.locator(".showcase-playground__controls").boundingBox();
  const main = await page.locator(".showcase-playground__main").boundingBox();
  expect(split).toBeTruthy();
  expect(controls).toBeTruthy();
  expect(main).toBeTruthy();

  // Vertical ranges overlap -> the columns sit on the same row (not stacked).
  expect(controls!.y).toBeLessThan(main!.y + main!.height);
  expect(main!.y).toBeLessThan(controls!.y + controls!.height);
  // Distinct horizontal positions -> main is to the right of the controls.
  expect(main!.x).toBeGreaterThan(controls!.x + controls!.width / 2);

  // The whole playground is height-capped (not stretched by its 2000px child)
  // and the main column scrolls internally within that frame.
  expect(split!.height).toBeLessThanOrEqual(700);
  const mainOverflowY = await page
    .locator(".showcase-playground__main")
    .evaluate((n) => getComputedStyle(n).overflowY);
  expect(mainOverflowY).toBe("auto");
  const scrolls = await page
    .locator(".showcase-playground__main")
    .evaluate((n) => n.scrollHeight > n.clientHeight + 1);
  expect(scrolls).toBe(true);
});

test("every migrated docs playground keeps the showcase-playground__split wrapper", () => {
  // Direct structural guard: the geometry test above proves the CSS contract,
  // and this proves each migrated playground actually opts into it. Unmigrated
  // playgrounds still carry inline `display: flex` chrome and are skipped.
  const dir = path.resolve(__dirname, "../../playgrounds");
  const slugs = readdirSync(dir).filter((name) =>
    existsSync(path.join(dir, name, "app.R")),
  );
  const migrated = slugs.filter((slug) => {
    const src = readFileSync(path.join(dir, slug, "app.R"), "utf8");
    return /class = "showcase-playground",\s*$/m.test(src);
  });
  expect(migrated.length).toBeGreaterThan(0);
  for (const slug of migrated) {
    const src = readFileSync(path.join(dir, slug, "app.R"), "utf8");
    expect(src, `${slug}/app.R lost its showcase-playground__split wrapper`).toContain(
      'class = "showcase-playground__split"',
    );
  }
});
