(function () {
  const runtime = window.ShinyblocksRuntimeParts ||= {};

  runtime.setInputValue = function setInputValue(id, value, priority) {
    if (!id || !window.Shiny || !window.Shiny.setInputValue) return;
    window.Shiny.setInputValue(id, value, { priority: priority || "event" });
  };

  runtime.registerUpdateHandler = function registerUpdateHandler(applyUpdate) {
    if (!window.Shiny || !window.Shiny.addCustomMessageHandler) return;
    if (runtime.updateHandlerRegistered) return;

    window.Shiny.addCustomMessageHandler("sb:update", applyUpdate);
    runtime.updateHandlerRegistered = true;
  };
})();
