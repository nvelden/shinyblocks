export const BUTTON_PROPS = [
  "backgroundColor",
  "borderRadius",
  "borderTopColor",
  "borderTopStyle",
  "borderTopWidth",
  "boxShadow",
  "color",
  "cursor",
  "display",
  "fontSize",
  "fontWeight",
  "gap",
  "height",
  "justifyContent",
  "letterSpacing",
  "lineHeight",
  "opacity",
  "paddingTop",
  "paddingRight",
  "paddingBottom",
  "paddingLeft",
  "pointerEvents"
];

export const REGISTRY = {
  button: {
    component: "button",
    parityUrl: "http://127.0.0.1:5173/?component=button",
    showcaseUrl: "http://127.0.0.1:4321/#button",
    showcaseReadySelector: '[data-sb-section="button"]:not([hidden])',
    referenceSelectors: {
      default: '[data-parity-component="button"] [data-parity-state="default"]',
      disabled: '[data-parity-component="button"] [data-parity-state="disabled"]'
    },
    showcaseSelectors: {
      default: '[data-sb-section="button"] .sb-button:not([disabled])',
      disabled: '[data-sb-section="button"] .sb-button[disabled]'
    },
    props: BUTTON_PROPS,
    states: ["default", "hover", "disabled"],
    themes: ["light", "dark"]
  }
};

export function getComponentConfig(name) {
  const config = REGISTRY[name];
  if (!config) {
    throw new Error(
      `Unknown parity component "${name}". Known: ${Object.keys(REGISTRY).join(", ")}`
    );
  }
  return config;
}
