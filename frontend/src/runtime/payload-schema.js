(function () {
  const runtime = window.ShinyblocksRuntimeParts ||= {};

  runtime.readPayload = function readPayload(root) {
    const script = root.querySelector("script[data-shinyblocks-payload]");
    if (!script) return null;

    try {
      return JSON.parse(script.textContent || "{}");
    } catch (error) {
      root.dataset.sbRuntimeError = "payload";
      console.error("shinyblocks: invalid runtime payload", error);
      return null;
    }
  };
})();
