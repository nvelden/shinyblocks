(function () {
  function selectRoots() {
    return Array.prototype.slice.call(
      document.querySelectorAll(".sb-select")
    );
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

  function selectItems(root) {
    return Array.prototype.slice.call(
      root.querySelectorAll(".sb-select-item")
    );
  }

  function setSelectOpen(root, open) {
    var trigger = root.querySelector(".sb-select-trigger");
    var content = root.querySelector(".sb-select-content");
    if (!trigger || !content) return;

    root.setAttribute("data-state", open ? "open" : "closed");
    trigger.setAttribute("aria-expanded", open ? "true" : "false");
    if (open) content.removeAttribute("hidden");
    else content.setAttribute("hidden", "");
  }

  function syncSelect(root) {
    var select = root.querySelector(".sb-select-native");
    var value = root.querySelector(".sb-select-value");
    if (!select || !value) return;

    var items = selectItems(root);
    var selected = select.options[select.selectedIndex];
    var selectedValue = selected ? selected.value : "";
    var selectedLabel = selected ? selected.textContent : "";
    var placeholder = root.getAttribute("data-placeholder") || "";

    root.setAttribute("data-value", selectedValue);
    value.textContent = selectedValue ? selectedLabel : placeholder;
    value.classList.toggle("is-placeholder", !selectedValue);

    items.forEach(function (item) {
      var active = item.getAttribute("data-value") === selectedValue;
      item.classList.toggle("is-selected", active);
      item.setAttribute("aria-selected", active ? "true" : "false");
    });
  }

  function focusSelectItem(root, index) {
    var items = selectItems(root);
    if (!items.length) return;
    var bounded = Math.max(0, Math.min(index, items.length - 1));
    items.forEach(function (item) {
      item.classList.remove("is-highlighted");
    });
    items[bounded].classList.add("is-highlighted");
    items[bounded].focus();
  }

  function selectedSelectIndex(root) {
    var select = root.querySelector(".sb-select-native");
    if (!select) return 0;

    for (var i = 0; i < select.options.length; i += 1) {
      if (select.options[i].value === select.value && select.value !== "") {
        return Math.max(0, i - (root.getAttribute("data-placeholder") ? 1 : 0));
      }
    }

    return 0;
  }

  function chooseSelectValue(root, value) {
    var select = root.querySelector(".sb-select-native");
    var trigger = root.querySelector(".sb-select-trigger");
    if (!select || !trigger) return;

    select.value = value;
    select.dispatchEvent(new Event("change", { bubbles: true }));
    syncSelect(root);
    setSelectOpen(root, false);
    trigger.focus();
  }

  function wireSelect(root) {
    var select = root.querySelector(".sb-select-native");
    var trigger = root.querySelector(".sb-select-trigger");
    if (!select || !trigger) return;

    syncSelect(root);
    setSelectOpen(root, false);

    trigger.addEventListener("click", function () {
      var open = root.getAttribute("data-state") === "open";
      setSelectOpen(root, !open);
      if (!open) focusSelectItem(root, selectedSelectIndex(root));
    });

    trigger.addEventListener("keydown", function (event) {
      if (
        event.key !== "ArrowDown" &&
        event.key !== "ArrowUp" &&
        event.key !== "Enter" &&
        event.key !== " "
      ) {
        return;
      }

      event.preventDefault();
      setSelectOpen(root, true);
      focusSelectItem(root, selectedSelectIndex(root));
    });

    select.addEventListener("change", function () {
      syncSelect(root);
    });

    selectItems(root).forEach(function (item, index) {
      item.addEventListener("click", function () {
        chooseSelectValue(root, item.getAttribute("data-value"));
      });

      item.addEventListener("keydown", function (event) {
        if (event.key === "ArrowDown") {
          event.preventDefault();
          focusSelectItem(root, index + 1);
        }
        if (event.key === "ArrowUp") {
          event.preventDefault();
          focusSelectItem(root, index - 1);
        }
        if (event.key === "Home") {
          event.preventDefault();
          focusSelectItem(root, 0);
        }
        if (event.key === "End") {
          event.preventDefault();
          focusSelectItem(root, selectItems(root).length - 1);
        }
        if (event.key === "Enter" || event.key === " ") {
          event.preventDefault();
          chooseSelectValue(root, item.getAttribute("data-value"));
        }
        if (event.key === "Escape") {
          event.preventDefault();
          setSelectOpen(root, false);
          trigger.focus();
        }
      });
    });

    document.addEventListener("click", function (event) {
      if (!root.contains(event.target)) {
        setSelectOpen(root, false);
      }
    });
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
    selectRoots().forEach(wireSelect);
    sidebarPages().forEach(wirePage);
  }

  if (document.readyState === "loading") {
    document.addEventListener("DOMContentLoaded", init);
  } else {
    init();
  }
})();
