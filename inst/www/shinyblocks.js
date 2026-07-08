/*
 * shinyblocks shell runtime — HAND-AUTHORED SOURCE, not a build output.
 * Edit here; `make budget` guards size.
 */
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

  function tabTriggers(tabset) {
    return Array.prototype.slice.call(
      tabset.querySelectorAll(".sb-tabs-list [role='tab']")
    );
  }

  function selectedTab(tabset) {
    var triggers = tabTriggers(tabset);
    return (
      triggers.find(function (trigger) {
        return trigger.getAttribute("aria-selected") === "true" ||
          trigger.getAttribute("data-state") === "active";
      }) || triggers[0]
    );
  }

  // Move the active highlight and panes to `trigger`. Pure DOM: when the tabset
  // is a Shiny input, value reporting is the binding's job (it reads
  // `selectedTab()` from `getValue`), so this never calls `setInputValue`.
  function activateTab(tabset, trigger) {
    if (!trigger) return;
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
  }

  // Returns whether a value matched, so unknown server updates stay silent.
  function activateTabByValue(tabset, value) {
    var selected = String(value == null ? "" : value);
    var trigger = tabTriggers(tabset).find(function (item) {
      return item.getAttribute("data-value") === selected;
    });
    if (!trigger) return false;
    activateTab(tabset, trigger);
    return true;
  }

  // Sidebar/page navigation mirrors the tabs `data-value` binding contract.
  function navInputItems(nav) {
    return Array.prototype.slice.call(nav.querySelectorAll(".sb-nav-item"));
  }

  function selectedNavItem(nav) {
    var items = navInputItems(nav);
    return (
      items.find(function (item) {
        return item.classList.contains("is-selected");
      }) || items[0]
    );
  }

  function setNavGroupExpanded(group, expanded) {
    if (!group) return;
    var v = expanded ? "true" : "false";
    var trigger = group.querySelector(".sb-nav-group-trigger");
    var items = group.querySelector(".sb-nav-group-items");

    group.setAttribute("data-expanded", v);
    if (trigger) {
      trigger.setAttribute("aria-expanded", v);
      trigger.setAttribute("data-expanded", v);
      trigger.setAttribute("data-state", expanded ? "open" : "closed");
    }
    if (items) {
      items.setAttribute("data-expanded", v);
      expanded
        ? items.removeAttribute("hidden")
        : items.setAttribute("hidden", "hidden");
    }
  }

  function expandAncestorNavGroups(nav, item) {
    var group = item && item.closest ? item.closest(".sb-nav-group") : null;
    while (group && nav.contains(group)) {
      setNavGroupExpanded(group, true);
      group = group.parentElement && group.parentElement.closest(".sb-nav-group");
    }
  }

  function activateNavItem(nav, item) {
    if (!item) return;
    expandAncestorNavGroups(nav, item);
    navInputItems(nav).forEach(function (other) {
      var active = other === item;
      other.classList.toggle("is-selected", active);
      if (active) {
        other.setAttribute("aria-current", "page");
      } else {
        other.removeAttribute("aria-current");
      }
    });
  }

  function activateNavByValue(nav, value) {
    var selected = String(value == null ? "" : value);
    if (!selected) return false;
    var item = navInputItems(nav).find(function (candidate) {
      return candidate.getAttribute("data-value") === selected;
    });
    if (!item) return false;
    activateNavItem(nav, item);
    return true;
  }

  function dispatchSelectionChange(el, name) {
    if (typeof Event === "function") {
      el.dispatchEvent(new Event(name));
      return;
    }
    var evt = document.createEvent("Event");
    evt.initEvent(name, false, false);
    el.dispatchEvent(evt);
  }

  // Delegated tabs/nav interactivity works for dynamically inserted markup.
  function wireSelectionDelegation() {
    if (window.shinyblocksSelectionWired) return;
    window.shinyblocksSelectionWired = true;

    document.addEventListener("click", function (event) {
      var target = event.target;
      if (!target || !target.closest) return;

      var accTrigger = target.closest(".sb-accordion-trigger");
      if (accTrigger) {
        var acc = accTrigger.closest(".sb-accordion");
        var accItem = accTrigger.closest(".sb-accordion-item");
        if (!acc || !accItem || accItem.hasAttribute("data-disabled")) return;
        event.preventDefault();
        toggleAccordionItem(acc, accItem);
        if (acc.hasAttribute("data-sb-accordion-input-id")) {
          dispatchSelectionChange(acc, "sb:accordion-change");
        }
        return;
      }

      var groupTrigger = target.closest(".sb-nav-group-trigger");
      if (groupTrigger) {
        var group = groupTrigger.closest(".sb-nav-group");
        if (!group) return;
        event.preventDefault();
        setNavGroupExpanded(
          group,
          groupTrigger.getAttribute("aria-expanded") !== "true"
        );
        return;
      }

      var navItem = target.closest(".sb-nav-item");
      if (navItem) {
        var inputNav = navItem.closest("[data-sb-nav-input-id]");
        if (inputNav) {
          // Input navs select instead of following links.
          event.preventDefault();
          activateNavItem(inputNav, navItem);
          dispatchSelectionChange(inputNav, "sb:nav-change");
        }
        return;
      }

      var trigger = target.closest(".sb-tabs-list [role='tab']");
      if (!trigger) return;
      var tabset = trigger.closest(".sb-tabs");
      if (!tabset) return;
      event.preventDefault();
      activateTab(tabset, trigger);
      if (tabset.hasAttribute("data-sb-tabs-input-id")) {
        dispatchSelectionChange(tabset, "sb:tabs-change");
      }
    });

    document.addEventListener("keydown", function (event) {
      var target = event.target;
      if (!target || !target.closest) return;

      var accTrigger = target.closest(".sb-accordion-trigger");
      if (accTrigger) {
        var acc = accTrigger.closest(".sb-accordion");
        if (!acc) return;
        var accTriggers = accordionTriggers(acc);
        var ai = accTriggers.indexOf(accTrigger);
        var nextTrigger = null;
        if (event.key === "ArrowDown") nextTrigger = accTriggers[ai + 1] || accTriggers[0];
        if (event.key === "ArrowUp") nextTrigger = accTriggers[ai - 1] || accTriggers[accTriggers.length - 1];
        if (event.key === "Home") nextTrigger = accTriggers[0];
        if (event.key === "End") nextTrigger = accTriggers[accTriggers.length - 1];
        if (!nextTrigger) return;
        event.preventDefault();
        nextTrigger.focus();
        return;
      }

      var trigger = target.closest(".sb-tabs-list [role='tab']");
      if (trigger) {
        var tabset = trigger.closest(".sb-tabs");
        if (!tabset) return;
        var triggers = tabTriggers(tabset);
        var i = triggers.indexOf(trigger);
        var nextTab = null;
        if (event.key === "ArrowRight") nextTab = triggers[i + 1] || triggers[0];
        if (event.key === "ArrowLeft") nextTab = triggers[i - 1] || triggers[triggers.length - 1];
        if (event.key === "Home") nextTab = triggers[0];
        if (event.key === "End") nextTab = triggers[triggers.length - 1];
        if (!nextTab) return;
        event.preventDefault();
        nextTab.focus();
        activateTab(tabset, nextTab);
        if (tabset.hasAttribute("data-sb-tabs-input-id")) {
          dispatchSelectionChange(tabset, "sb:tabs-change");
        }
        return;
      }

      var item = target.closest(".sb-nav-item");
      if (!item) return;
      var container = item.closest(".sb-nav, .sb-sidebar-nav");
      if (!container) return;
      var items = navItems(container);
      var index = items.indexOf(item);
      if (index === -1) return;
      var nextItem = null;
      if (event.key === "ArrowDown") nextItem = items[index + 1] || items[0];
      if (event.key === "ArrowUp") nextItem = items[index - 1] || items[items.length - 1];
      if (event.key === "Home") nextItem = items[0];
      if (event.key === "End") nextItem = items[items.length - 1];
      if (!nextItem) return;
      event.preventDefault();
      nextItem.focus();
    });
  }

  // R-side accordion primitive (block_accordion): collapsible content sections.
  function accordionItems(acc) {
    return Array.prototype.slice.call(
      acc.querySelectorAll(".sb-accordion-item")
    );
  }

  function accordionTriggers(acc) {
    return accordionItems(acc)
      .map(function (item) {
        return item.querySelector(".sb-accordion-trigger");
      })
      .filter(Boolean);
  }

  function setAccordionItemState(item, open) {
    if (!item) return;
    var v = open ? "open" : "closed";
    var trigger = item.querySelector(".sb-accordion-trigger");
    var content = item.querySelector(".sb-accordion-content");
    item.setAttribute("data-state", v);
    if (trigger) {
      trigger.setAttribute("aria-expanded", open ? "true" : "false");
      trigger.setAttribute("data-state", v);
    }
    if (content) {
      content.setAttribute("data-state", v);
      // `inert` keeps collapsed content out of the tab order and a11y tree while
      // the CSS grid-rows transition animates the height.
      if (open) {
        content.removeAttribute("inert");
      } else {
        content.setAttribute("inert", "");
      }
    }
  }

  function toggleAccordionItem(acc, item) {
    var wasOpen = item.getAttribute("data-state") === "open";
    var single = acc.getAttribute("data-type") !== "multiple";
    var collapsible = acc.getAttribute("data-collapsible") === "true";
    if (single) {
      if (wasOpen) {
        if (collapsible) setAccordionItemState(item, false);
      } else {
        accordionItems(acc).forEach(function (other) {
          setAccordionItemState(other, other === item);
        });
      }
    } else {
      setAccordionItemState(item, !wasOpen);
    }
  }

  function accordionValue(acc) {
    var open = accordionItems(acc)
      .filter(function (item) {
        return item.getAttribute("data-state") === "open";
      })
      .map(function (item) {
        return item.getAttribute("data-value");
      });
    if (acc.getAttribute("data-type") !== "multiple") {
      return open.length ? open[0] : null;
    }
    return open;
  }

  function applyAccordionOpen(acc, values) {
    var wanted = {};
    (values || []).forEach(function (v) {
      wanted[String(v)] = true;
    });
    var single = acc.getAttribute("data-type") !== "multiple";
    var applied = false;
    var opened = 0;
    accordionItems(acc).forEach(function (item) {
      var value = item.getAttribute("data-value");
      var open = !!wanted[value] && !(single && opened > 0);
      if (open) opened += 1;
      if ((item.getAttribute("data-state") === "open") !== open) applied = true;
      setAccordionItemState(item, open);
    });
    return applied;
  }

  // Real Shiny InputBindings for tab/nav selections.
  function registerSelectionBinding(name, config) {
    function Binding() {}
    Binding.prototype = Object.create(window.Shiny.InputBinding.prototype);
    Binding.prototype.find = function (scope) {
      var root = scope || document;
      var els = Array.prototype.slice.call(root.querySelectorAll(config.selector));
      if (root.matches && root.matches(config.selector)) els.unshift(root);
      return els;
    };
    Binding.prototype.getId = function (el) {
      return el.getAttribute(config.idAttr);
    };
    Binding.prototype.getValue = function (el) {
      var selected = config.selected(el);
      return selected ? selected.getAttribute("data-value") : null;
    };
    Binding.prototype.initialize = function (el) {
      config.activate(el, config.selected(el));
    };
    Binding.prototype.subscribe = function (el, callback) {
      el.__sbSelectionHandler = function () {
        callback(false);
      };
      el.addEventListener(config.changeEvent, el.__sbSelectionHandler);
    };
    Binding.prototype.unsubscribe = function (el) {
      if (!el.__sbSelectionHandler) return;
      el.removeEventListener(config.changeEvent, el.__sbSelectionHandler);
      delete el.__sbSelectionHandler;
    };
    Binding.prototype.receiveMessage = function (el, data) {
      data = data || {};
      // Only report an input event when an item actually matched: an unknown
      // value is a no-op, so dispatching would re-report the previous selection
      // and fire observers for a failed update. notify === false updates the
      // highlight without reporting an input event.
      var applied = config.activateValue(el, data.selected);
      if (applied && data.notify !== false) {
        dispatchSelectionChange(el, config.changeEvent);
      }
    };
    window.Shiny.inputBindings.register(new Binding(), name);
  }

  function registerAccordionBinding() {
    function Binding() {}
    Binding.prototype = Object.create(window.Shiny.InputBinding.prototype);
    Binding.prototype.find = function (scope) {
      var root = scope || document;
      var sel = ".sb-accordion[data-sb-accordion-input-id]";
      var els = Array.prototype.slice.call(root.querySelectorAll(sel));
      if (root.matches && root.matches(sel)) els.unshift(root);
      return els;
    };
    Binding.prototype.getId = function (el) {
      return el.getAttribute("data-sb-accordion-input-id");
    };
    Binding.prototype.getValue = accordionValue;
    Binding.prototype.getType = function (el) {
      return el.getAttribute("data-type") === "multiple"
        ? "shinyblocks.accordion"
        : null;
    };
    Binding.prototype.subscribe = function (el, callback) {
      el.__sbAccordionHandler = function () {
        callback(false);
      };
      el.addEventListener("sb:accordion-change", el.__sbAccordionHandler);
    };
    Binding.prototype.unsubscribe = function (el) {
      if (!el.__sbAccordionHandler) return;
      el.removeEventListener("sb:accordion-change", el.__sbAccordionHandler);
      delete el.__sbAccordionHandler;
    };
    Binding.prototype.receiveMessage = function (el, data) {
      data = data || {};
      var applied = applyAccordionOpen(el, data.open);
      if (applied && data.notify !== false) {
        dispatchSelectionChange(el, "sb:accordion-change");
      }
    };
    window.Shiny.inputBindings.register(new Binding(), "shinyblocks.accordion");
  }

  function registerSelectionBindings() {
    if (window.shinyblocksSelectionBound) return;
    if (!window.Shiny || !window.Shiny.InputBinding || !window.Shiny.inputBindings) {
      return;
    }
    window.shinyblocksSelectionBound = true;

    registerAccordionBinding();

    registerSelectionBinding("shinyblocks.tabs", {
      selector: ".sb-tabs[data-sb-tabs-input-id]",
      idAttr: "data-sb-tabs-input-id",
      changeEvent: "sb:tabs-change",
      selected: selectedTab,
      activate: activateTab,
      activateValue: activateTabByValue
    });

    registerSelectionBinding("shinyblocks.nav", {
      selector: "[data-sb-nav-input-id]",
      idAttr: "data-sb-nav-input-id",
      changeEvent: "sb:nav-change",
      selected: selectedNavItem,
      activate: activateNavItem,
      activateValue: activateNavByValue
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

    // Tabs and sidebar-nav inputs need no observer: interactivity is delegated
    // and Shiny re-binds inserted inputs via `bindAll`. The observer only marks
    // dynamically inserted sidebar pages as enhanced, the progressive-enhancement
    // gate the layout CSS keys off (`data-sidebar-enhanced="true"`).
    var observer = new MutationObserver(function (mutations) {
      var needsPage = false;

      mutations.forEach(function (mutation) {
        if (!mutation.addedNodes.length) return;

        var nodes = Array.prototype.slice.call(mutation.addedNodes);
        nodes.forEach(function (node) {
          if (node.nodeType !== 1) return;

          if (node.matches && node.matches(".sb-page.has-sidebar")) {
            needsPage = true;
          }
          if (node.querySelector && node.querySelector(".sb-page.has-sidebar")) {
            needsPage = true;
          }
        });
      });

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
    wireSelectionDelegation();
    sidebarPages().forEach(wirePage);
    observeDOM();
  }

  if (window.Shiny && window.Shiny.addCustomMessageHandler) {
    window.Shiny.addCustomMessageHandler("sb:theme", function (message) {
      applyTheme(message.mode || "system");
    });

    // Register before Shiny's initial `bindAll` so the first tabs/nav inputs are
    // bound and report their selected value on connect.
    registerSelectionBindings();
  }

  if (document.readyState === "loading") {
    document.addEventListener("DOMContentLoaded", init);
  } else {
    init();
  }
})();
