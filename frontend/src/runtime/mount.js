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
      const initialized = runtime.setInputValue(
        payload.id,
        currentValue(payload),
        "event"
      );
      if (!initialized) {
        root.dataset.sbPendingInput = "true";
        runtime.schedulePendingInputFlush();
      }
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

  runtime.flushPendingInputs = function flushPendingInputs(container) {
    runtimeRoots(container || document).forEach(function (root) {
      if (!root.hasAttribute("data-sb-pending-input")) return;

      const payload = mounted.get(root);
      if (!payload || !payload.id || !payload.binding || !payload.binding.input) {
        return;
      }

      const initialized = runtime.setInputValue(
        payload.id,
        currentValue(payload),
        "event"
      );
      if (initialized) root.removeAttribute("data-sb-pending-input");
    });
  };

  runtime.hasPendingInputs = function hasPendingInputs(container) {
    return runtimeRoots(container || document).some(function (root) {
      return root.hasAttribute("data-sb-pending-input");
    });
  };

  runtime.schedulePendingInputFlush = function schedulePendingInputFlush() {
    if (runtime.pendingInputFlushTimer) return;

    let attempts = 0;
    runtime.pendingInputFlushTimer = window.setInterval(function () {
      runtime.flushPendingInputs(document);
      attempts += 1;

      if (!runtime.hasPendingInputs(document) || attempts >= 200) {
        window.clearInterval(runtime.pendingInputFlushTimer);
        runtime.pendingInputFlushTimer = null;
      }
    }, 50);
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
