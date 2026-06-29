import { test, expect } from "@playwright/test";
import { PATH } from "./paths";

test("components index page renders sidebar and main grid", async ({ page }) => {
  await page.goto(PATH.components);

  // Sidebar component links.
  await expect(page.getByRole("link", { name: "Button", exact: true })).toBeVisible();
  await expect(page.getByRole("link", { name: "Card", exact: true })).toBeVisible();
});

// Regression: static preview fragments must keep the `.sb-app` token scope.
// Without it, `--sb-surface-gap` is undefined and `.sb-card` header->content
// spacing collapses to 0 (see components/preview-surface.tsx). Assert the
// token resolves and the gap is actually applied on a rendered preview card.
test("static preview cards keep the .sb-app token scope (surface spacing)", async ({
  page,
}) => {
  await page.goto(PATH.components);

  const card = page.locator('[data-component-preview="card"] .sb-card').first();
  await card.waitFor({ state: "attached" });

  const gap = await card.evaluate((el) => {
    const cs = getComputedStyle(el);
    const head = el.querySelector(".sb-card-header")?.getBoundingClientRect();
    const content = el.querySelector(".sb-card-content")?.getBoundingClientRect();
    return {
      surfaceGap: cs.getPropertyValue("--sb-surface-gap").trim(),
      headToContent: head && content ? content.top - head.bottom : null,
    };
  });

  expect(gap.surfaceGap, "--sb-surface-gap must resolve under .sb-app").not.toBe("");
  expect(gap.headToContent ?? 0).toBeGreaterThan(0);
});
