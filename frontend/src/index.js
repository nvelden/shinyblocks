(function () {
  const runtime = window.ShinyblocksRuntimeParts ||= {};

  function init() {
    runtime.mountAll(document);
    runtime.observeDynamicUi();
    runtime.registerUpdateHandler(runtime.applyUpdate);
    runtime.flushPendingInputs(document);
  }

  window.shinyblocksRuntime = {
    init,
    mountAll: runtime.mountAll,
    applyUpdate: runtime.applyUpdate
  };

  if (document.readyState === "loading") {
    document.addEventListener("DOMContentLoaded", init, { once: true });
  } else {
    init();
  }

  document.addEventListener("shiny:connected", function () {
    runtime.flushPendingInputs(document);
    runtime.schedulePendingInputFlush();
  });
})();
