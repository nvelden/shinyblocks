(function () {
  const runtime = window.ShinyblocksRuntimeParts ||= {};

  runtime.isShinyReady = function isShinyReady() {
    if (!window.Shiny || !window.Shiny.setInputValue) return false;
    if (!window.Shiny.shinyapp) return true;

    const socket = window.Shiny.shinyapp.$socket;
    return Boolean(socket && socket.readyState === 1);
  };

  runtime.setInputValue = function setInputValue(id, value, priority) {
    if (!id || !runtime.isShinyReady()) return false;
    window.Shiny.setInputValue(id, value, { priority: priority || "event" });
    return true;
  };

  runtime.registerUpdateHandler = function registerUpdateHandler(applyUpdate) {
    if (!window.Shiny || !window.Shiny.addCustomMessageHandler) return;
    if (runtime.updateHandlerRegistered) return;

    window.Shiny.addCustomMessageHandler("sb:update", applyUpdate);
    runtime.updateHandlerRegistered = true;
  };
})();
