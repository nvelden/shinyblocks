(function () {
  const runtime = window.ShinyblocksRuntimeParts ||= {};

  runtime.ensurePortalRoot = function ensurePortalRoot() {
    let portal = document.querySelector("[data-shinyblocks-portal-root]");
    if (portal) return portal;

    portal = document.createElement("div");
    portal.setAttribute("data-shinyblocks-portal-root", "");
    document.body.appendChild(portal);
    return portal;
  };
})();
