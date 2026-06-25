(function () {
  function currentThemeMode() {
    var initialMode = window.shinyblocksInitialThemeMode;
    if (initialMode === "light" || initialMode === "dark") {
      return initialMode;
    }

    try {
      var mode = localStorage.getItem("sb-theme") || "system";
      return mode === "light" || mode === "dark" || mode === "system"
        ? mode
        : "system";
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

  function syncThemeToggles(resolved) {
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

  function applyTheme(mode) {
    var resolved = resolvedTheme(mode);

    try {
      localStorage.setItem("sb-theme", mode);
    } catch (e) {}

    document.documentElement.dataset.theme = resolved;
    document.documentElement.dataset.themeMode = mode;
    syncThemeToggles(resolved);
  }

  function exposeThemeApi() {
    window.shinyblocksTheme = window.shinyblocksTheme || {};
    window.shinyblocksTheme.apply = applyTheme;
  }

  function wireThemeToggleEvents() {
    if (window.shinyblocksThemeToggleWired) return;
    window.shinyblocksThemeToggleWired = true;

    document.addEventListener("click", function (event) {
      var target = event.target;
      var button = target && target.closest
        ? target.closest("[data-sb-theme-toggle]")
        : null;
      if (!button) return;

      event.preventDefault();
      var next = document.documentElement.dataset.theme === "dark"
        ? "light"
        : "dark";
      applyTheme(next);
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
      tabset.querySelectorAll(".sb-tabs-content > .sb-tabs-panel")
    );

    triggers.forEach(function (item) {
      var active = item === trigger;
      item.setAttribute("aria-selected", active ? "true" : "false");
      item.setAttribute("tabindex", active ? "0" : "-1");
      item.setAttribute("data-state", active ? "active" : "inactive");
    });

    panes.forEach(function (pane) {
      var active = pane.id === targetId;
      pane.setAttribute("data-state", active ? "active" : "inactive");
      if (active) {
        pane.removeAttribute("hidden");
      } else {
        pane.setAttribute("hidden", "hidden");
      }
    });

    if (updateInput && window.Shiny && window.Shiny.setInputValue) {
      var tabsetId = tabset.getAttribute("data-sb-tabs-input-id");
      var value = trigger.getAttribute("data-value");
      if (tabsetId && value) {
        window.Shiny.setInputValue(tabsetId, value, { priority: "event" });
      }
    }
  }

  function activateTabByValue(inputId, value, options) {
    var selected = String(value || "");
    if (!inputId || !selected) return;

    tabs().forEach(function (tabset) {
      if (tabset.getAttribute("data-sb-tabs-input-id") !== inputId) return;

      var trigger = tabTriggers(tabset).find(function (item) {
        return item.getAttribute("data-value") === selected;
      });
      if (!trigger) return;

      activateTab(tabset, trigger, options);
    });
  }

  function wireTabs(tabset) {
    if (tabset.getAttribute("data-sb-tabs-wired") === "true") return;
    tabset.setAttribute("data-sb-tabs-wired", "true");

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
        trigger.getAttribute("data-state") === "active";
    }) || triggers[0];

    activateTab(tabset, initial, { updateInput: true });
  }

  function syncTabInputs() {
    tabs().forEach(function (tabset) {
      var active = tabTriggers(tabset).find(function (trigger) {
        return trigger.getAttribute("aria-selected") === "true" ||
          trigger.getAttribute("data-state") === "active";
      });
      if (active) activateTab(tabset, active, { updateInput: true });
    });
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

  function focusableIn(container) {
    return Array.prototype.slice
      .call(
        container.querySelectorAll(
          'a[href], button:not([disabled]), input:not([disabled]),' +
            ' select:not([disabled]), textarea:not([disabled]),' +
            ' [tabindex]:not([tabindex="-1"])'
        )
      )
      .filter(function (node) {
        return node.offsetParent !== null || node === document.activeElement;
      });
  }

  function setMobileOpen(page, open) {
    var sidebar = page.querySelector(".sb-sidebar");
    var trigger = page.querySelector(".sb-sidebar-mobile-trigger");
    if (!sidebar || !trigger) return;

    var wasOpen = page.getAttribute("data-sidebar-mobile-open") === "true";
    var value = open ? "true" : "false";
    page.setAttribute("data-sidebar-mobile-open", value);
    trigger.setAttribute("aria-expanded", open ? "true" : "false");
    trigger.setAttribute("aria-label", open ? "Close sidebar" : "Open sidebar");

    // The mobile drawer is a modal: trap focus, lock background scroll, and
    // make the rest of the page inert so assistive tech and Tab stay inside it.
    var main = page.querySelector(".sb-page-main");

    if (open) {
      // Capture the opener before inerting `main` (the trigger lives inside it
      // and would be blurred), so focus can return there on close.
      if (!wasOpen) page._sbReturnFocus = document.activeElement;
      sidebar.setAttribute("role", "dialog");
      sidebar.setAttribute("aria-modal", "true");
      if (main) {
        main.inert = true;
        main.setAttribute("aria-hidden", "true");
      }
      document.body.style.overflow = "hidden";
      if (!wasOpen) {
        var focusables = focusableIn(sidebar);
        if (focusables.length) focusables[0].focus();
      }
    } else {
      sidebar.removeAttribute("role");
      sidebar.removeAttribute("aria-modal");
      if (main) {
        main.inert = false;
        main.removeAttribute("aria-hidden");
      }
      document.body.style.overflow = "";
      // Restore focus to whatever opened the drawer (un-inert main first so the
      // trigger, which lives inside it, is focusable again).
      if (wasOpen && page._sbReturnFocus && page._sbReturnFocus.focus) {
        page._sbReturnFocus.focus();
      }
      page._sbReturnFocus = null;
    }
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
    if (page.getAttribute("data-sidebar-enhanced") === "true") return;
    page.setAttribute("data-sidebar-enhanced", "true");

    var sidebar = page.querySelector(".sb-sidebar");
    if (!sidebar) return;

    var toggle = sidebar.querySelector(".sb-sidebar-toggle");
    if (toggle) {
      toggle.addEventListener("click", function () {
        // Below the 768px breakpoint the sidebar is an off-canvas drawer and
        // `data-sidebar-collapsed` has no CSS effect (icon-collapse is a
        // desktop-only mode). Closing the drawer is the only meaningful action
        // for the in-sidebar toggle there, so it would otherwise be a no-op.
        if (window.matchMedia("(max-width: 767px)").matches) {
          setMobileOpen(page, false);
          return;
        }
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

    var backdrop = page.querySelector(".sb-sidebar-backdrop");
    if (backdrop) {
      backdrop.addEventListener("click", function () {
        setMobileOpen(page, false);
      });
    }

    // Trap Tab within the drawer while it is open (mobile only — the attribute
    // is never "true" on desktop).
    sidebar.addEventListener("keydown", function (event) {
      if (event.key !== "Tab") return;
      if (page.getAttribute("data-sidebar-mobile-open") !== "true") return;

      var focusables = focusableIn(sidebar);
      if (!focusables.length) return;

      var first = focusables[0];
      var last = focusables[focusables.length - 1];
      if (event.shiftKey && document.activeElement === first) {
        event.preventDefault();
        last.focus();
      } else if (!event.shiftKey && document.activeElement === last) {
        event.preventDefault();
        first.focus();
      }
    });

    Array.prototype.forEach.call(
      page.querySelectorAll(".sb-nav, .sb-sidebar-nav"),
      wireNavKeyboard
    );
  }

  function wireGlobalSidebarHandlers() {
    if (window.shinyblocksSidebarGlobalWired) return;
    window.shinyblocksSidebarGlobalWired = true;

    document.addEventListener("keydown", function (event) {
      if (event.key !== "Escape") return;
      sidebarPages().forEach(function (page) {
        setMobileOpen(page, false);
      });
    });

    // Crossing up to the desktop breakpoint dissolves the drawer, so clear the
    // modal state (inert main, scroll lock) that only makes sense on mobile.
    if (typeof window.matchMedia === "function") {
      var desktop = window.matchMedia("(min-width: 768px)");
      var onBreakpoint = function (event) {
        if (!event.matches) return;
        sidebarPages().forEach(function (page) {
          setMobileOpen(page, false);
        });
      };
      if (desktop.addEventListener) {
        desktop.addEventListener("change", onBreakpoint);
      } else if (desktop.addListener) {
        desktop.addListener(onBreakpoint);
      }
    }

    document.addEventListener("click", function (event) {
      sidebarPages().forEach(function (page) {
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
    });
  }

  function observeDOM() {
    if (typeof MutationObserver === "undefined") return;

    var observer = new MutationObserver(function (mutations) {
      var needsTabs = false;
      var needsPage = false;

      mutations.forEach(function (mutation) {
        if (!mutation.addedNodes.length) return;
        
        var nodes = Array.prototype.slice.call(mutation.addedNodes);
        nodes.forEach(function (node) {
          if (node.nodeType !== 1) return;
          
          if (node.matches && node.matches(".sb-tabs[data-sb-tabs='true']")) {
            needsTabs = true;
          }
          if (node.querySelector && node.querySelector(".sb-tabs[data-sb-tabs='true']")) {
            needsTabs = true;
          }
          if (node.matches && node.matches(".sb-page.has-sidebar")) {
            needsPage = true;
          }
          if (node.querySelector && node.querySelector(".sb-page.has-sidebar")) {
            needsPage = true;
          }
        });
      });

      if (needsTabs) {
        tabs().forEach(wireTabs);
      }
      if (needsPage) {
        sidebarPages().forEach(wirePage);
      }
    });

    observer.observe(document.body, {
      childList: true,
      subtree: true
    });
  }

  function init() {
    exposeThemeApi();
    applyTheme(currentThemeMode());
    wireThemeToggleEvents();
    wireGlobalSidebarHandlers();
    tabs().forEach(wireTabs);
    sidebarPages().forEach(wirePage);
    observeDOM();
  }

  if (window.Shiny && window.Shiny.addCustomMessageHandler) {
    window.Shiny.addCustomMessageHandler("sb:theme", function (message) {
      applyTheme(message.mode || "system");
    });

    window.Shiny.addCustomMessageHandler("sb:tabs", function (message) {
      message = message || {};
      activateTabByValue(message.id, message.selected, {
        updateInput: message.notify !== false
      });
    });
  }

  if (document.readyState === "loading") {
    document.addEventListener("DOMContentLoaded", init);
  } else {
    init();
  }

  document.addEventListener("shiny:connected", syncTabInputs);
})();
