import AxeBuilder from "@axe-core/playwright";
import { expect, test } from "@playwright/test";
import { PATH } from "./paths";

const pages = [
  ["home", PATH.home],
  ["get started", PATH.getStarted],
  ["components", PATH.components],
  ["component detail", PATH.componentDetail("button")],
] as const;

for (const [name, url] of pages) {
  test(`${name} has no automatically detectable accessibility violations`, async ({ page }) => {
    await page.goto(url);
    await expect(page.getByRole("main")).toBeVisible();

    const results = await new AxeBuilder({ page })
      // Shinylive runs in nested third-party frames and has its own lifecycle;
      // this scan covers the docs document and package-rendered previews.
      .exclude("iframe")
      .analyze();

    expect(results.violations).toEqual([]);
  });
}
