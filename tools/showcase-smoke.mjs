import assert from "node:assert/strict";
import { spawn } from "node:child_process";
import net from "node:net";
import { chromium } from "playwright";

async function canListen(port) {
  return new Promise((resolve) => {
    const server = net.createServer();
    server.once("error", () => resolve(false));
    server.once("listening", () => {
      server.close(() => resolve(true));
    });
    server.listen(port, "127.0.0.1");
  });
}

async function resolvePort() {
  const requested = process.env.PORT_SHOWCASE_SMOKE;
  if (requested) return Number(requested);

  for (let candidate = 4326; candidate < 4376; candidate += 1) {
    if (await canListen(candidate)) return candidate;
  }

  throw new Error("No available showcase smoke port found.");
}

const port = await resolvePort();
const url = `http://127.0.0.1:${port}`;

function delay(ms) {
  return new Promise((resolve) => setTimeout(resolve, ms));
}

async function waitForServer(process) {
  const deadline = Date.now() + 20000;
  while (Date.now() < deadline) {
    if (process.exitCode !== null) {
      throw new Error(`Showcase exited early with code ${process.exitCode}`);
    }
    try {
      const response = await fetch(url);
      if (response.ok) return;
    } catch {
      await delay(250);
    }
  }

  throw new Error(`Timed out waiting for ${url}`);
}

const showcase = spawn(
  "Rscript",
  [
    "-e",
    `devtools::load_all(".", quiet = TRUE); shiny::runApp("inst/showcase", port = ${port}, launch.browser = FALSE)`
  ],
  { stdio: ["ignore", "pipe", "pipe"] }
);

let stdout = "";
let stderr = "";
showcase.stdout.on("data", (chunk) => {
  stdout += chunk;
});
showcase.stderr.on("data", (chunk) => {
  stderr += chunk;
});

let browser;
let page;

try {
  await waitForServer(showcase);

  browser = await chromium.launch({ headless: true });
  page = await browser.newPage();
  await page.addInitScript(() => {
    localStorage.setItem("sb-theme", "light");
  });
  await page.goto(`${url}/#button`, { waitUntil: "domcontentloaded" });

  await page.waitForSelector('#button:not([hidden])');
  await page.waitForSelector("[data-sb-theme-toggle]");
  assert.equal(
    await page.evaluate(() => document.documentElement.dataset.theme),
    "light"
  );
  await page.click("[data-sb-theme-toggle]");
  await page.waitForFunction(() => {
    return document.documentElement.dataset.theme === "dark";
  });
  assert.equal(
    await page.locator("[data-sb-theme-toggle]").first().getAttribute("aria-pressed"),
    "true"
  );

  await page.fill(
    "[data-sb-component='input'][data-sb-input-id='showcase_button_doc_style'] [data-slot='input-control']",
    "color: red;"
  );
  await page.waitForFunction(() => {
    const button = document.querySelector(
      "[data-sb-component='button'][data-sb-input-id='showcase_button_preview'] [data-slot='button']"
    );
    return button && getComputedStyle(button).color === "rgb(255, 0, 0)";
  });

  const preview = await page.locator(
    "[data-sb-component='button'][data-sb-input-id='showcase_button_preview'] [data-slot='button']"
  ).evaluate((node) => {
    const style = getComputedStyle(node);
    return {
      display: style.display,
      text: node.textContent.trim(),
      style: node.getAttribute("style")
    };
  });

  assert.equal(preview.display, "inline-flex");
  assert.equal(preview.text, "Continue");
  assert.equal(preview.style, "color: red;");

  await page.goto(`${url}/#tabs`, { waitUntil: "domcontentloaded" });
  await page.waitForSelector("#tabs:not([hidden])");
  // Drive the stable parity instance (overview/usage tabs, defaults to overview).
  const tabsRoot = page.locator("#showcase_tabs_parity_default");
  await tabsRoot.locator(".sb-tabs-trigger[data-value='usage']").click();
  await page.waitForFunction(() => {
    const trigger = document.querySelector(
      "#showcase_tabs_parity_default .sb-tabs-trigger[data-value='usage']"
    );
    const panel = document.querySelector(
      "#showcase_tabs_parity_default .sb-tabs-panel[data-value='usage']"
    );
    return trigger?.getAttribute("aria-selected") === "true" &&
      trigger?.getAttribute("data-state") === "active" &&
      panel?.getAttribute("data-state") === "active" &&
      !panel.hasAttribute("hidden");
  });

  // ArrowRight from the last tab (usage) wraps roving focus back to overview
  // and activates it (automatic activation), hiding the usage panel.
  await tabsRoot.locator(".sb-tabs-trigger[data-value='usage']").press("ArrowRight");
  await page.waitForFunction(() => {
    const trigger = document.querySelector(
      "#showcase_tabs_parity_default .sb-tabs-trigger[data-value='overview']"
    );
    const previousPanel = document.querySelector(
      "#showcase_tabs_parity_default .sb-tabs-panel[data-value='usage']"
    );
    return trigger?.getAttribute("aria-selected") === "true" &&
      trigger?.getAttribute("data-state") === "active" &&
      previousPanel?.hasAttribute("hidden");
  });

  // Sidebar-nav Shiny input (#layout). The nav is rendered through renderUI, so
  // this exercises the InputBinding binding on dynamically inserted markup
  // (Shiny.bindAll), delegated click selection, and the update_block_nav()
  // server round-trip (sendInputMessage -> receiveMessage).
  await page.goto(`${url}/#layout`, { waitUntil: "domcontentloaded" });
  await page.waitForSelector("#layout:not([hidden])");
  // The renderUI'd nav binds as a Shiny input and reports its initial value.
  await page.waitForFunction(() => {
    const nav = document.querySelector("#showcase_layout_preview_nav");
    const echo = document.querySelector("#showcase_layout_preview_value");
    return nav?.classList.contains("shiny-bound-input") &&
      echo?.textContent.includes('"dashboard"');
  });
  // Toggling a group updates disclosure state only; it must not report a nav
  // input value or leave collapsed leaves focusable.
  await page
    .locator("#showcase_layout_preview_nav .sb-nav-group-trigger")
    .filter({ hasText: "Operations" })
    .click();
  await page.waitForFunction(() => {
    const group = document.querySelector(
      "#showcase_layout_preview_nav .sb-nav-group[data-sb-nav-group-value='operations']"
    );
    const trigger = group?.querySelector(".sb-nav-group-trigger");
    const items = group?.querySelector(".sb-nav-group-items");
    const echo = document.querySelector("#showcase_layout_preview_value");
    return trigger?.getAttribute("aria-expanded") === "false" &&
      items?.hasAttribute("hidden") &&
      echo?.textContent.includes('"dashboard"');
  });
  assert.equal(
    await page.locator(
      "#showcase_layout_preview_nav .sb-nav-group-items[hidden] .sb-nav-item[data-value='users']"
    ).count(),
    1,
    "collapsed group should hide nested leaf items"
  );
  // update_block_nav() from the server selects a nested item and expands its
  // ancestor group (receiveMessage -> activateNavByValue).
  await page.getByRole("button", { name: "Toggle nav" }).click();
  await page.waitForFunction(() => {
    const item = document.querySelector(
      "#showcase_layout_preview_nav .sb-nav-item[data-value='users']"
    );
    const group = document.querySelector(
      "#showcase_layout_preview_nav .sb-nav-group[data-sb-nav-group-value='operations']"
    );
    const items = group?.querySelector(".sb-nav-group-items");
    const echo = document.querySelector("#showcase_layout_preview_value");
    return item?.classList.contains("is-selected") &&
      item?.getAttribute("aria-current") === "page" &&
      !items?.hasAttribute("hidden") &&
      echo?.textContent.includes('"users"');
  });
  // Clicking a leaf still selects it through the existing delegated binding.
  await page
    .locator("#showcase_layout_preview_nav .sb-nav-item[data-value='dashboard']")
    .click();
  await page.waitForFunction(() => {
    const item = document.querySelector(
      "#showcase_layout_preview_nav .sb-nav-item[data-value='dashboard']"
    );
    const echo = document.querySelector("#showcase_layout_preview_value");
    return item?.classList.contains("is-selected") &&
      echo?.textContent.includes('"dashboard"');
  });

  await page.goto(`${url}/#card`, { waitUntil: "domcontentloaded" });
  await page.waitForSelector("#card:not([hidden])");
  const cardSpacing = await page.locator(".sb-parity-card-composed").evaluate((node) => {
    const card = getComputedStyle(node);
    const header = getComputedStyle(node.querySelector(".sb-card-header"));
    const content = getComputedStyle(node.querySelector(".sb-card-content"));
    return {
      gap: card.gap,
      paddingTop: card.paddingTop,
      headerPaddingInline: header.paddingInline,
      contentPaddingInline: content.paddingInline
    };
  });
  assert.deepEqual(cardSpacing, {
    gap: "24px",
    paddingTop: "24px",
    headerPaddingInline: "24px",
    contentPaddingInline: "24px"
  });

  await page.goto(`${url}/#layout-primitives`, { waitUntil: "domcontentloaded" });
  await page.waitForSelector("#layout-primitives:not([hidden])");
  await page.waitForFunction(() => window.Shiny?.setInputValue);

  const setLayoutInputs = async (values) => {
    await page.evaluate((nextValues) => {
      for (const [name, value] of Object.entries(nextValues)) {
        window.Shiny.setInputValue(`showcase_layout_primitives_${name}`, value, {
          priority: "event"
        });
      }
    }, values);
  };

  await setLayoutInputs({
    type: "grid",
    count: "2",
    min_width: "10rem",
    align: "stretch",
    vary_heights: true
  });
  await page.waitForFunction(() => {
    const grids = document.querySelectorAll(
      "#showcase_layout_primitives_preview_ui .showcase-layout-primitives-viewport > .sb-grid"
    );
    if (!grids.length) return false;
    const grid = grids[grids.length - 1];
    return grid.querySelectorAll(":scope > .sb-card").length === 2 &&
      grid.style.getPropertyValue("--sb-grid-min") === "10rem" &&
      getComputedStyle(grid).gridTemplateColumns.split(" ").length === 2;
  });

  const gridSnapshot = await page.evaluate(() => {
    const grids = [...document.querySelectorAll(
      "#showcase_layout_primitives_preview_ui .showcase-layout-primitives-viewport > .sb-grid"
    )];
    const grid = grids.findLast((node) => node.isConnected && node.getClientRects().length);
    return {
      cards: [...grid.querySelectorAll(":scope > .sb-card")].map((node) => {
        const box = node.getBoundingClientRect();
        return { x: box.x, y: box.y, width: box.width, height: box.height };
      })
    };
  });
  const gridBoxes = gridSnapshot.cards;
  assert.ok(gridBoxes[1].x > gridBoxes[0].x);
  assert.ok(Math.abs(gridBoxes[1].y - gridBoxes[0].y) < 2);
  assert.ok(Math.abs(gridBoxes[1].height - gridBoxes[0].height) < 2);

  await page.setViewportSize({ width: 700, height: 800 });
  await page.goto(`${url}/#layout`, { waitUntil: "domcontentloaded" });
  await page.waitForSelector("#layout:not([hidden])");
  await page.evaluate(() => {
    const shell = document.querySelector(".sb-page");
    const sidebar = document.querySelector(".sb-sidebar");
    shell.setAttribute("data-sidebar-collapsed", "true");
    sidebar.setAttribute("data-collapsed", "true");
  });
  await page.locator(".sb-sidebar-mobile-trigger").click();
  await page.waitForFunction(() => {
    const shell = document.querySelector(".sb-page");
    const sidebar = document.querySelector(".sb-sidebar");
    return shell?.getAttribute("data-sidebar-mobile-open") === "true" &&
      getComputedStyle(sidebar).transform === "matrix(1, 0, 0, 1, 0, 0)";
  });
  await page.evaluate(() => {
    const main = document.querySelector(".sb-page-main");
    const blocker = document.createElement("div");
    blocker.dataset.sidebarStackingProbe = "";
    Object.assign(blocker.style, {
      position: "fixed",
      inset: "0",
      zIndex: "50",
      background: "white"
    });
    main.append(blocker);
  });

  const mobileSidebar = await page.evaluate(() => {
    const sidebar = document.querySelector(".sb-sidebar");
    const backdrop = document.querySelector(".sb-sidebar-backdrop");
    const sidebarStyle = getComputedStyle(sidebar);
    const backdropStyle = getComputedStyle(backdrop);
    const titleText = sidebar.querySelector(".sb-sidebar-title-text");
    const navLabel = sidebar.querySelector(".sb-nav-label");
    const navItem = sidebar.querySelector(".sb-nav-item");
    const rect = sidebar.getBoundingClientRect();
    const sidebarTopElement = document.elementFromPoint(
      rect.left + rect.width / 2,
      rect.top + rect.height - 100
    );
    const backdropTopElement = document.elementFromPoint(
      rect.right + 50,
      rect.top + rect.height / 2
    );

    return {
      backgroundColor: sidebarStyle.backgroundColor,
      sidebarToken: sidebarStyle.getPropertyValue("--sidebar").trim(),
      sidebarZIndex: sidebarStyle.zIndex,
      backdropZIndex: backdropStyle.zIndex,
      sidebarWidth: rect.width,
      titleTextDisplay: getComputedStyle(titleText).display,
      navLabelDisplay: getComputedStyle(navLabel).display,
      navItemJustify: getComputedStyle(navItem).justifyContent,
      sidebarOnTop: sidebar.contains(sidebarTopElement),
      backdropOnTop: backdrop === backdropTopElement,
      backdropPointerEvents: backdropStyle.pointerEvents
    };
  });

  assert.notEqual(mobileSidebar.backgroundColor, "rgba(0, 0, 0, 0)");
  assert.notEqual(mobileSidebar.backgroundColor, "transparent");
  assert.ok(mobileSidebar.sidebarToken);
  assert.equal(mobileSidebar.sidebarZIndex, "80");
  assert.equal(mobileSidebar.backdropZIndex, "79");
  assert.equal(mobileSidebar.sidebarWidth, 288);
  assert.notEqual(mobileSidebar.titleTextDisplay, "none");
  assert.notEqual(mobileSidebar.navLabelDisplay, "none");
  assert.notEqual(mobileSidebar.navItemJustify, "center");
  assert.equal(mobileSidebar.sidebarOnTop, true);
  assert.equal(mobileSidebar.backdropOnTop, true);
  assert.equal(mobileSidebar.backdropPointerEvents, "auto");

  // The open drawer must behave as a modal: dialog semantics, an inert/hidden
  // background, and a locked body scroll.
  const modalState = await page.evaluate(() => {
    const sidebar = document.querySelector(".sb-sidebar");
    const main = document.querySelector(".sb-page-main");
    return {
      role: sidebar.getAttribute("role"),
      ariaModal: sidebar.getAttribute("aria-modal"),
      mainInert: main.inert === true,
      mainHidden: main.getAttribute("aria-hidden"),
      bodyOverflow: getComputedStyle(document.body).overflow
    };
  });
  assert.equal(modalState.role, "dialog");
  assert.equal(modalState.ariaModal, "true");
  assert.equal(modalState.mainInert, true);
  assert.equal(modalState.mainHidden, "true");
  assert.equal(modalState.bodyOverflow, "hidden");

  // The in-sidebar toggle has no icon-collapse effect below 768px, so it must
  // close the open drawer there instead of being a dead button.
  await page.evaluate(() => {
    document.querySelector("[data-sidebar-stacking-probe]")?.remove();
  });
  await page.locator(".sb-sidebar-toggle").click();
  await page.waitForFunction(
    () =>
      document.querySelector(".sb-page")?.getAttribute(
        "data-sidebar-mobile-open"
      ) === "false"
  );

  // Closing must tear the modal state back down.
  const restored = await page.evaluate(() => {
    const sidebar = document.querySelector(".sb-sidebar");
    const main = document.querySelector(".sb-page-main");
    return {
      role: sidebar.getAttribute("role"),
      mainInert: main.inert === true,
      bodyOverflow: getComputedStyle(document.body).overflow
    };
  });
  assert.equal(restored.role, null);
  assert.equal(restored.mainInert, false);
  assert.notEqual(restored.bodyOverflow, "hidden");

  console.log("Showcase smoke test passed.");
} catch (error) {
  console.error(stdout);
  console.error(stderr);
  throw error;
} finally {
  if (browser) await browser.close();
  showcase.kill("SIGTERM");
}
