(function () {
  const runtime = window.ShinyblocksRuntimeParts ||= {};
  const mounted = new Map();

  function runtimeRoots(container) {
    return Array.prototype.slice.call(
      (container || document).querySelectorAll("[data-shinyblocks-runtime='true']")
    );
  }

  function currentValue(payload) {
    if (!payload || !payload.state) return null;
    if (!Object.prototype.hasOwnProperty.call(payload.state, "value")) return null;
    return payload.state.value;
  }

  runtime.mountRoot = function mountRoot(root) {
    if (mounted.has(root)) return;

    const payload = runtime.readPayload(root);
    if (!payload) return;

    runtime.ensurePortalRoot();
    root.dataset.sbMounted = "true";
    root.dataset.sbSchemaVersion = String(payload.schemaVersion || 1);

    mounted.set(root, payload);
    runtime.bindShinyChildren(root);

    if (payload.id && payload.binding && payload.binding.input) {
      runtime.setInputValue(payload.id, currentValue(payload), "event");
    }
  };

  runtime.unmountRoot = function unmountRoot(root) {
    const payload = mounted.get(root);
    if (!payload) return;

    runtime.unbindShinyChildren(root);
    if (payload.id) runtime.forgetRevision(payload.id);
    mounted.delete(root);
  };

  runtime.mountAll = function mountAll(container) {
    runtimeRoots(container).forEach(runtime.mountRoot);
  };

  runtime.applyUpdate = function applyUpdate(message) {
    if (!message || !message.id) return;
    if (!runtime.isFreshRevision(message.id, message.revision)) return;

    runtimeRoots(document).forEach(function (root) {
      const payload = mounted.get(root);
      if (!payload || payload.id !== message.id) return;

      payload.state ||= {};
      payload.props ||= {};

      Object.keys(message.updates || {}).forEach(function (key) {
        const value = message.updates[key];
        if (key === "disabled") {
          root.toggleAttribute("data-disabled", Boolean(value));
        }
        payload.state[key] = value;
      });

      if (message.notify && Object.prototype.hasOwnProperty.call(message.updates || {}, "value")) {
        runtime.setInputValue(message.id, message.updates.value, "event");
      }
    });
  };

  runtime.observeDynamicUi = function observeDynamicUi() {
    if (runtime.dynamicObserver) return;

    runtime.dynamicObserver = new MutationObserver(function (records) {
      records.forEach(function (record) {
        Array.prototype.slice.call(record.removedNodes).forEach(function (node) {
          if (node.nodeType !== Node.ELEMENT_NODE) return;
          if (node.matches && node.matches("[data-shinyblocks-runtime='true']")) {
            runtime.unmountRoot(node);
          }
          runtimeRoots(node).forEach(runtime.unmountRoot);
        });

        Array.prototype.slice.call(record.addedNodes).forEach(function (node) {
          if (node.nodeType !== Node.ELEMENT_NODE) return;
          if (node.matches && node.matches("[data-shinyblocks-runtime='true']")) {
            runtime.mountRoot(node);
          }
          runtime.mountAll(node);
        });
      });
    });

    runtime.dynamicObserver.observe(document.documentElement, {
      childList: true,
      subtree: true
    });
  };
})();
