import { test, expect } from "@playwright/test";
import { PATH } from "./paths";

test("landing page gallery lists featured components", async ({ page }) => {
  await page.goto(PATH.home);
  const gallery = page.locator("iframe[title='Interactive components gallery']");
  await expect(gallery).toBeVisible();
  await expect(gallery).toHaveAttribute("src", "/shinyblocks/playgrounds/gallery/");

  const response = await page.request.get(`${PATH.home}playgrounds/gallery/app.json`);
  expect(response.ok()).toBe(true);
  const files = (await response.json()) as Array<{ name: string; content: string }>;
  const app = files.find((file) => file.name === "app.R");
  expect(app?.content).toContain('`data-component-preview` = "button"');
  expect(app?.content).toContain('`data-component-preview` = "card"');
  expect(app?.content).toContain("gallery_style_profile");
  expect(app?.content).toContain("gallery_theme_preset");
  expect(app?.content).toContain("block_style_profiles()");
  expect(app?.content).toContain("block_theme_presets()");
  expect(app?.content).toContain("gallery:set-style-profile");
  // Regression guard: the theme/style <style> assets live in a hidden
  // container, so the output must opt out of Shiny's suspend-when-hidden or
  // theme-preset changes never render (the controls would do nothing).
  expect(app?.content).toContain("suspendWhenHidden = FALSE");
});
