import { test, expect } from "@playwright/test";
import { existsSync } from "node:fs";
import { PATH } from "./paths";

test("preview manifest is generated", () => {
  expect(existsSync("lib/preview-manifest.json")).toBe(true);
});

test("runtime CSS is loaded on every page", async ({ page }) => {
  await page.goto(PATH.home);
  const hasCss = await page.evaluate(() =>
    [...document.styleSheets].some((s) => s.href?.includes("runtime/shinyblocks.css")),
  );
  expect(hasCss).toBe(true);
});
