(function () {
  const runtime = window.ShinyblocksRuntimeParts ||= {};

  runtime.bindShinyChildren = function bindShinyChildren(root) {
    if (!window.Shiny || !window.Shiny.bindAll) return;
    window.Shiny.bindAll(root);
  };

  runtime.unbindShinyChildren = function unbindShinyChildren(root) {
    if (!window.Shiny || !window.Shiny.unbindAll) return;
    window.Shiny.unbindAll(root);
  };
})();
