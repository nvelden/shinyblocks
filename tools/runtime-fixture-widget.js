HTMLWidgets.widget({
  name: "runtimeFixture",
  type: "output",
  factory: function (el) {
    return {
      renderValue: function (x) {
        el.textContent = x.text;
        el.dataset.runtimeFixtureReady = "true";
      },
      resize: function () {}
    };
  }
});
