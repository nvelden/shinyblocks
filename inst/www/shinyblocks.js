(function () {
  function currentThemeMode() {
    try {
      return localStorage.getItem("sb-theme") || "system";
    } catch (e) {
      return "system";
    }
  }

  function resolvedTheme(mode) {
    if (mode === "system") {
      return window.matchMedia("(prefers-color-scheme: dark)").matches
        ? "dark"
        : "light";
    }
    return mode;
  }

  function applyTheme(mode) {
    var resolved = resolvedTheme(mode);

    try {
      localStorage.setItem("sb-theme", mode);
    } catch (e) {}

    document.documentElement.dataset.theme = resolved;
    document.documentElement.dataset.themeMode = mode;

    Array.prototype.slice.call(
      document.querySelectorAll("[data-sb-theme-toggle]")
    ).forEach(function (button) {
      var dark = resolved === "dark";
      button.setAttribute("aria-pressed", dark ? "true" : "false");
      button.setAttribute(
        "aria-label",
        dark ? "Switch to light mode" : "Switch to dark mode"
      );
    });
  }

  function wireThemeToggles() {
    Array.prototype.slice.call(
      document.querySelectorAll("[data-sb-theme-toggle]")
    ).forEach(function (button) {
      button.addEventListener("click", function () {
        var next = document.documentElement.dataset.theme === "dark"
          ? "light"
          : "dark";
        applyTheme(next);
      });
    });
  }

  function tabs() {
    return Array.prototype.slice.call(
      document.querySelectorAll(".sb-tabs[data-sb-tabs='true']")
    );
  }

  function tabTriggers(tabset) {
    return Array.prototype.slice.call(
      tabset.querySelectorAll(".sb-tabs-list [role='tab']")
    );
  }

  function activateTab(tabset, trigger, options) {
    var config = options || {};
    var updateInput = config.updateInput !== false;
    var triggers = tabTriggers(tabset);
    var targetId = (trigger.getAttribute("aria-controls") || "")
      .replace(/^#/, "");
    var panes = Array.prototype.slice.call(
      tabset.querySelectorAll(".sb-tabs-content > .tab-pane")
    );

    triggers.forEach(function (item) {
      var active = item === trigger;
      item.classList.toggle("active", active);
      item.setAttribute("aria-selected", active ? "true" : "false");
      item.setAttribute("tabindex", active ? "0" : "-1");

      if (item.parentElement) {
        item.parentElement.classList.toggle("active", active);
      }
    });

    panes.forEach(function (pane) {
      var active = pane.id === targetId;
      pane.classList.toggle("active", active);
      if (active) {
        pane.removeAttribute("hidden");
      } else {
        pane.setAttribute("hidden", "hidden");
      }
    });

    if (updateInput && window.Shiny && window.Shiny.setInputValue) {
      var tabsetId = tabset.querySelector(".sb-tabs-list");
      var value = trigger.getAttribute("data-value");
      if (tabsetId && tabsetId.id && value) {
        window.Shiny.setInputValue(tabsetId.id, value, { priority: "event" });
      }
    }
  }

  function wireTabs(tabset) {
    var triggers = tabTriggers(tabset);
    if (!triggers.length) return;

    triggers.forEach(function (trigger) {
      trigger.addEventListener("click", function (event) {
        event.preventDefault();
        activateTab(tabset, trigger);
      });

      trigger.addEventListener("keydown", function (event) {
        var index = triggers.indexOf(trigger);
        var next = null;

        if (event.key === "ArrowRight") next = triggers[index + 1] || triggers[0];
        if (event.key === "ArrowLeft") next = triggers[index - 1] || triggers[triggers.length - 1];
        if (event.key === "Home") next = triggers[0];
        if (event.key === "End") next = triggers[triggers.length - 1];

        if (!next) return;
        event.preventDefault();
        next.focus();
        activateTab(tabset, next);
      });
    });

    var initial = triggers.find(function (trigger) {
      return trigger.getAttribute("aria-selected") === "true" ||
        trigger.classList.contains("active");
    }) || triggers[0];

    activateTab(tabset, initial, { updateInput: false });
  }

  function sidebarPages() {
    return Array.prototype.slice.call(
      document.querySelectorAll(".sb-page.has-sidebar")
    );
  }

  function navItems(container) {
    return Array.prototype.slice.call(
      container.querySelectorAll(".sb-nav-item")
    );
  }

  function setCollapsed(page, collapsed) {
    var sidebar = page.querySelector(".sb-sidebar");
    if (!sidebar) return;

    var value = collapsed ? "true" : "false";
    page.setAttribute("data-sidebar-collapsed", value);
    sidebar.setAttribute("data-collapsed", value);

    var toggle = sidebar.querySelector(".sb-sidebar-toggle");
    if (toggle) {
      toggle.setAttribute("aria-expanded", collapsed ? "false" : "true");
    }
  }

  function setMobileOpen(page, open) {
    var sidebar = page.querySelector(".sb-sidebar");
    var trigger = page.querySelector(".sb-sidebar-mobile-trigger");
    if (!sidebar || !trigger) return;

    var value = open ? "true" : "false";
    page.setAttribute("data-sidebar-mobile-open", value);
    trigger.setAttribute("aria-expanded", open ? "true" : "false");
    trigger.setAttribute("aria-label", open ? "Close sidebar" : "Open sidebar");
  }

  function wireNavKeyboard(container) {
    container.addEventListener("keydown", function (event) {
      var current = event.target.closest(".sb-nav-item");
      if (!current) return;

      var items = navItems(container);
      var index = items.indexOf(current);
      if (index === -1) return;

      var next = null;
      if (event.key === "ArrowDown") next = items[index + 1] || items[0];
      if (event.key === "ArrowUp") next = items[index - 1] || items[items.length - 1];
      if (event.key === "Home") next = items[0];
      if (event.key === "End") next = items[items.length - 1];

      if (!next) return;
      event.preventDefault();
      next.focus();
    });
  }

  function wirePage(page) {
    var sidebar = page.querySelector(".sb-sidebar");
    if (!sidebar) return;

    page.setAttribute("data-sidebar-enhanced", "true");

    var toggle = sidebar.querySelector(".sb-sidebar-toggle");
    if (toggle) {
      toggle.addEventListener("click", function () {
        var collapsed = page.getAttribute("data-sidebar-collapsed") === "true";
        setCollapsed(page, !collapsed);
      });
    }

    var mobileTrigger = page.querySelector(".sb-sidebar-mobile-trigger");
    if (mobileTrigger) {
      mobileTrigger.addEventListener("click", function () {
        var open = page.getAttribute("data-sidebar-mobile-open") === "true";
        setMobileOpen(page, !open);
      });
    }

    document.addEventListener("keydown", function (event) {
      if (event.key === "Escape") {
        setMobileOpen(page, false);
      }
    });

    document.addEventListener("click", function (event) {
      var open = page.getAttribute("data-sidebar-mobile-open") === "true";
      if (!open) return;
      if (
        event.target.closest(".sb-sidebar") ||
        event.target.closest(".sb-sidebar-mobile-trigger")
      ) {
        return;
      }
      setMobileOpen(page, false);
    });

    var backdrop = page.querySelector(".sb-sidebar-backdrop");
    if (backdrop) {
      backdrop.addEventListener("click", function () {
        setMobileOpen(page, false);
      });
    }

    Array.prototype.forEach.call(
      page.querySelectorAll(".sb-nav, .sb-sidebar-nav"),
      wireNavKeyboard
    );
  }

  function init() {
    wireThemeToggles();
    tabs().forEach(wireTabs);
    sidebarPages().forEach(wirePage);
  }

  if (window.Shiny && window.Shiny.addCustomMessageHandler) {
    window.Shiny.addCustomMessageHandler("sb:theme", function (message) {
      applyTheme(message.mode || "system");
    });
  }

  if (document.readyState === "loading") {
    document.addEventListener("DOMContentLoaded", init);
  } else {
    init();
  }
})();
