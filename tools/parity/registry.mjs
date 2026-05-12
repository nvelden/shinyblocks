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

export const BADGE_PROPS = [
  "backgroundColor",
  "borderRadius",
  "borderTopColor",
  "borderTopStyle",
  "borderTopWidth",
  "color",
  "display",
  "fontSize",
  "fontWeight",
  "gap",
  "height",
  "justifyContent",
  "lineHeight",
  "overflowX",
  "overflowY",
  "paddingTop",
  "paddingRight",
  "paddingBottom",
  "paddingLeft",
  "whiteSpace",
  "width"
];

export const ALERT_ROOT_PROPS = [
  "backgroundColor",
  "borderRadius",
  "borderTopColor",
  "borderTopStyle",
  "borderTopWidth",
  "display",
  "paddingTop",
  "paddingRight",
  "paddingBottom",
  "paddingLeft",
  "position"
];

export const ALERT_TITLE_PROPS = [
  "color",
  "fontSize",
  "fontWeight",
  "letterSpacing",
  "lineHeight"
];

export const ALERT_DESCRIPTION_PROPS = [
  "color",
  "fontSize",
  "lineHeight"
];

export const SELECT_PROPS = [
  "alignItems",
  "backgroundColor",
  "borderBottomLeftRadius",
  "borderBottomRightRadius",
  "borderRadius",
  "borderTopColor",
  "borderTopStyle",
  "borderTopWidth",
  "boxShadow",
  "color",
  "display",
  "fontSize",
  "fontWeight",
  "gap",
  "height",
  "justifyContent",
  "letterSpacing",
  "lineHeight",
  "minHeight",
  "paddingTop",
  "paddingRight",
  "paddingBottom",
  "paddingLeft",
  "position"
];

export const SLIDER_ROOT_PROPS = ["height", "opacity", "pointerEvents"];

export const SLIDER_RAIL_PROPS = [
  "backgroundColor",
  "borderRadius",
  "height"
];

export const SLIDER_RANGE_PROPS = ["backgroundColor", "borderRadius", "height"];

export const SLIDER_THUMB_PROPS = [
  "backgroundColor",
  "borderRadius",
  "borderTopColor",
  "borderTopStyle",
  "borderTopWidth",
  "boxShadow",
  "cursor",
  "display",
  "height",
  "marginTop",
  "position",
  "top",
  "transform",
  "width"
];

export const CHECKBOX_TEXT_PROPS = ["opacity"];

export const CHECKBOX_INDICATOR_PROPS = [
  "backgroundColor",
  "borderRadius",
  "borderTopColor",
  "borderTopStyle",
  "borderTopWidth",
  "boxShadow",
  "display",
  "height",
  "width"
];

export const SWITCH_TEXT_PROPS = ["opacity"];

export const SWITCH_TRACK_PROPS = [
  "backgroundColor",
  "borderRadius",
  "boxShadow",
  "display",
  "height",
  "width"
];

export const TEXTAREA_PROPS = [
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
  "height",
  "letterSpacing",
  "lineHeight",
  "minHeight",
  "opacity",
  "paddingTop",
  "paddingRight",
  "paddingBottom",
  "paddingLeft",
  "resize"
];

async function prepareFocusState(page, state, selector) {
  if (state !== "focus") {
    return;
  }

  await page.locator(selector).first().focus();
  await page.waitForTimeout(150);
}

async function prepareSelectOpenState(page, _state, selector) {
  await page.locator(selector).first().click();
  await page.waitForSelector('[data-sb-section="field"] .sb-select .selectize-dropdown', {
    state: "visible",
    timeout: 10000
  });
  await page.waitForTimeout(250);
}

async function prepareSliderHoverState(page, state, selectors) {
  if (state !== "hover") {
    return;
  }

  await page.locator(selectors.thumb).first().hover();
  await page.waitForTimeout(250);
}

async function sliderExtraChecks(page, theme, state, selectors) {
  let drifts = 0;

  if (state === "default" || state === "hover") {
    const geometry = await page.evaluate(({ rail, thumb }) => {
      const railEl = document.querySelector(rail);
      const thumbEl = document.querySelector(thumb);
      if (!railEl || !thumbEl) {
        return null;
      }

      const railRect = railEl.getBoundingClientRect();
      const thumbRect = thumbEl.getBoundingClientRect();
      const railCenterY = railRect.top + railRect.height / 2;
      const thumbCenterY = thumbRect.top + thumbRect.height / 2;

      return {
        railCenterY,
        thumbCenterY,
        delta: Math.abs(railCenterY - thumbCenterY)
      };
    }, selectors);

    if (geometry) {
      console.log(`\n== slider :: ${theme} :: ${state} :: geometry ==`);
      console.log(`  rail center Y   ${geometry.railCenterY.toFixed(2)}`);
      console.log(`  thumb center Y  ${geometry.thumbCenterY.toFixed(2)}`);
      console.log(`  vertical delta  ${geometry.delta.toFixed(2)} px`);
      if (geometry.delta > 1.5) {
        drifts += 1;
        console.log("  drift  thumb is not vertically centred on the rail");
      } else {
        console.log("  match  thumb centred on rail");
      }
    }
  }

  if (theme === "light" && state === "default") {
    const labels = await page.evaluate((root) => {
      return [".irs-min", ".irs-max", ".irs-single", ".irs-from", ".irs-to", ".irs-grid"].map(
        (selector) => {
          const el = document.querySelector(`${root} ${selector}`);
          return {
            selector,
            display: el ? window.getComputedStyle(el).display : "absent"
          };
        }
      );
    }, selectors.root);

    console.log("\n== slider :: light :: default :: hidden labels ==");
    for (const row of labels) {
      const ok = row.display === "none" || row.display === "absent";
      console.log(
        `  ${row.selector.padEnd(12)} ${ok ? "match  hidden" : `drift  display=${row.display}`}`
      );
      if (!ok) {
        drifts += 1;
      }
    }
  }

  return drifts;
}

export const REGISTRY = {
  alert: {
    component: "alert",
    parityUrl: "http://127.0.0.1:5173/?component=alert",
    showcaseUrl: "http://127.0.0.1:4321/#alert",
    showcaseReadySelector: '[data-sb-section="alert"]:not([hidden])',
    roles: {
      root: {
        props: ALERT_ROOT_PROPS,
        referenceSelectors: {
          default: '[data-parity-component="alert"] [data-parity-state="default"]',
          destructive: '[data-parity-component="alert"] [data-parity-state="destructive"]'
        },
        showcaseSelectors: {
          default: '[data-sb-section="alert"] .sb-parity-alert-default',
          destructive: '[data-sb-section="alert"] .sb-parity-alert-destructive'
        }
      },
      title: {
        props: ALERT_TITLE_PROPS,
        referenceSelectors: {
          default: '[data-parity-component="alert"] [data-parity-state="default"] [data-parity-role="title"]',
          destructive: '[data-parity-component="alert"] [data-parity-state="destructive"] [data-parity-role="title"]'
        },
        showcaseSelectors: {
          default: '[data-sb-section="alert"] .sb-parity-alert-default .sb-alert-title',
          destructive: '[data-sb-section="alert"] .sb-parity-alert-destructive .sb-alert-title'
        }
      },
      description: {
        props: ALERT_DESCRIPTION_PROPS,
        referenceSelectors: {
          default: '[data-parity-component="alert"] [data-parity-state="default"] [data-parity-role="description"]',
          destructive: '[data-parity-component="alert"] [data-parity-state="destructive"] [data-parity-role="description"]'
        },
        showcaseSelectors: {
          default: '[data-sb-section="alert"] .sb-parity-alert-default .sb-alert-description',
          destructive: '[data-sb-section="alert"] .sb-parity-alert-destructive .sb-alert-description'
        }
      }
    },
    states: ["default", "destructive"],
    themes: ["light", "dark"]
  },
  badge: {
    component: "badge",
    parityUrl: "http://127.0.0.1:5173/?component=badge",
    showcaseUrl: "http://127.0.0.1:4321/#badge",
    showcaseReadySelector: '[data-sb-section="badge"]:not([hidden])',
    referenceSelectors: {
      default: '[data-parity-component="badge"] [data-parity-state="default"]',
      secondary: '[data-parity-component="badge"] [data-parity-state="secondary"]',
      outline: '[data-parity-component="badge"] [data-parity-state="outline"]',
      destructive: '[data-parity-component="badge"] [data-parity-state="destructive"]'
    },
    showcaseSelectors: {
      default: '[data-sb-section="badge"] .sb-badge-default',
      secondary: '[data-sb-section="badge"] .sb-badge-secondary',
      outline: '[data-sb-section="badge"] .sb-badge-outline',
      destructive: '[data-sb-section="badge"] .sb-badge-destructive'
    },
    props: BADGE_PROPS,
    states: ["default", "secondary", "outline", "destructive"],
    themes: ["light", "dark"]
  },
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
  },
  select: {
    component: "select",
    parityUrl: "http://127.0.0.1:5173/?component=select",
    showcaseUrl: "http://127.0.0.1:4321/#field",
    showcaseReadySelector: '[data-sb-section="field"]:not([hidden])',
    referenceSelectors: {
      default: '[data-parity-component="select"] [data-parity-state="default"]',
      open: '[data-parity-component="select"] [data-parity-state="open"]'
    },
    showcaseSelectors: {
      default:
        '[data-sb-section="field"] .sb-select .selectize-control.single .selectize-input',
      open: '[data-sb-section="field"] .sb-select .selectize-control.single .selectize-input'
    },
    props: SELECT_PROPS,
    states: ["default", "open"],
    themes: ["light", "dark"],
    prepareShowcaseState: async (page, state, selector) => {
      if (state === "open") {
        await prepareSelectOpenState(page, state, selector);
      }
    }
  },
  slider: {
    component: "slider",
    parityUrl: "http://127.0.0.1:5173/?component=slider",
    showcaseUrl: "http://127.0.0.1:4321/#slider",
    showcaseReadySelector: '[data-sb-section="slider"]:not([hidden])',
    roles: {
      root: {
        props: SLIDER_ROOT_PROPS,
        referenceSelectors: {
          default: '[data-parity-component="slider"] [data-parity-state="default"][data-parity-role="root"]',
          hover: '[data-parity-component="slider"] [data-parity-state="default"][data-parity-role="root"]',
          disabled:
            '[data-parity-component="slider"] [data-parity-state="disabled"][data-parity-role="root"]'
        },
        showcaseSelectors: {
          default: '[data-sb-section="slider"] .sb-slider:not([data-disabled="true"]) .irs--shiny',
          hover: '[data-sb-section="slider"] .sb-slider:not([data-disabled="true"]) .irs--shiny',
          disabled: '[data-sb-section="slider"] .sb-slider[data-disabled="true"] .irs--shiny'
        }
      },
      rail: {
        props: SLIDER_RAIL_PROPS,
        referenceSelectors: {
          default: '[data-parity-component="slider"] [data-parity-state="default"] [data-parity-role="rail"]',
          hover: '[data-parity-component="slider"] [data-parity-state="default"] [data-parity-role="rail"]',
          disabled:
            '[data-parity-component="slider"] [data-parity-state="disabled"] [data-parity-role="rail"]'
        },
        showcaseSelectors: {
          default: '[data-sb-section="slider"] .sb-slider:not([data-disabled="true"]) .irs--shiny .irs-line',
          hover: '[data-sb-section="slider"] .sb-slider:not([data-disabled="true"]) .irs--shiny .irs-line',
          disabled: '[data-sb-section="slider"] .sb-slider[data-disabled="true"] .irs--shiny .irs-line'
        }
      },
      range: {
        props: SLIDER_RANGE_PROPS,
        referenceSelectors: {
          default: '[data-parity-component="slider"] [data-parity-state="default"] [data-parity-role="range"]',
          hover: '[data-parity-component="slider"] [data-parity-state="default"] [data-parity-role="range"]',
          disabled:
            '[data-parity-component="slider"] [data-parity-state="disabled"] [data-parity-role="range"]'
        },
        showcaseSelectors: {
          default: '[data-sb-section="slider"] .sb-slider:not([data-disabled="true"]) .irs--shiny .irs-bar',
          hover: '[data-sb-section="slider"] .sb-slider:not([data-disabled="true"]) .irs--shiny .irs-bar',
          disabled: '[data-sb-section="slider"] .sb-slider[data-disabled="true"] .irs--shiny .irs-bar'
        }
      },
      thumb: {
        props: SLIDER_THUMB_PROPS,
        referenceSelectors: {
          default: '[data-parity-component="slider"] [data-parity-state="default"] [data-parity-role="thumb"]',
          hover: '[data-parity-component="slider"] [data-parity-state="default"] [data-parity-role="thumb"]',
          disabled:
            '[data-parity-component="slider"] [data-parity-state="disabled"] [data-parity-role="thumb"]'
        },
        showcaseSelectors: {
          default: '[data-sb-section="slider"] .sb-slider:not([data-disabled="true"]) .irs--shiny .irs-handle',
          hover: '[data-sb-section="slider"] .sb-slider:not([data-disabled="true"]) .irs--shiny .irs-handle',
          disabled: '[data-sb-section="slider"] .sb-slider[data-disabled="true"] .irs--shiny .irs-handle'
        }
      }
    },
    states: ["default", "hover", "disabled"],
    themes: ["light", "dark"],
    prepareReferenceState: prepareSliderHoverState,
    prepareShowcaseState: prepareSliderHoverState,
    extraShowcaseChecks: sliderExtraChecks
  },
  checkbox: {
    component: "checkbox",
    parityUrl: "http://127.0.0.1:5173/?component=checkbox",
    showcaseUrl: "http://127.0.0.1:4321/#field",
    showcaseReadySelector: '[data-sb-section="field"]:not([hidden])',
    roles: {
      text: {
        props: CHECKBOX_TEXT_PROPS,
        referenceSelectors: {
          default: '[data-parity-component="checkbox"] [data-parity-state="default"] [data-parity-role="text"]',
          checked: '[data-parity-component="checkbox"] [data-parity-state="checked"] [data-parity-role="text"]',
          disabled:
            '[data-parity-component="checkbox"] [data-parity-state="disabled"] [data-parity-role="text"]'
        },
        showcaseSelectors: {
          default:
            '[data-sb-section="field"] .sb-parity-checkbox-default .sb-checkbox-text',
          checked:
            '[data-sb-section="field"] .sb-parity-checkbox-checked .sb-checkbox-text',
          disabled:
            '[data-sb-section="field"] .sb-parity-checkbox-disabled .sb-checkbox-text'
        }
      },
      indicator: {
        props: CHECKBOX_INDICATOR_PROPS,
        referenceSelectors: {
          default: '[data-parity-component="checkbox"] [data-parity-state="default"] [data-parity-role="indicator"]',
          checked: '[data-parity-component="checkbox"] [data-parity-state="checked"] [data-parity-role="indicator"]',
          disabled:
            '[data-parity-component="checkbox"] [data-parity-state="disabled"] [data-parity-role="indicator"]'
        },
        showcaseSelectors: {
          default:
            '[data-sb-section="field"] .sb-parity-checkbox-default .sb-checkbox-indicator',
          checked:
            '[data-sb-section="field"] .sb-parity-checkbox-checked .sb-checkbox-indicator',
          disabled:
            '[data-sb-section="field"] .sb-parity-checkbox-disabled .sb-checkbox-indicator'
        }
      }
    },
    states: ["default", "checked", "disabled"],
    themes: ["light", "dark"]
  },
  switch: {
    component: "switch",
    parityUrl: "http://127.0.0.1:5173/?component=switch",
    showcaseUrl: "http://127.0.0.1:4321/#field",
    showcaseReadySelector: '[data-sb-section="field"]:not([hidden])',
    roles: {
      text: {
        props: SWITCH_TEXT_PROPS,
        referenceSelectors: {
          default: '[data-parity-component="switch"] [data-parity-state="default"] [data-parity-role="text"]',
          checked: '[data-parity-component="switch"] [data-parity-state="checked"] [data-parity-role="text"]',
          disabled:
            '[data-parity-component="switch"] [data-parity-state="disabled"] [data-parity-role="text"]'
        },
        showcaseSelectors: {
          default: '[data-sb-section="field"] .sb-parity-switch-default .sb-switch-text',
          checked: '[data-sb-section="field"] .sb-parity-switch-checked .sb-switch-text',
          disabled: '[data-sb-section="field"] .sb-parity-switch-disabled .sb-switch-text'
        }
      },
      track: {
        props: SWITCH_TRACK_PROPS,
        referenceSelectors: {
          default: '[data-parity-component="switch"] [data-parity-state="default"] [data-parity-role="track"]',
          checked: '[data-parity-component="switch"] [data-parity-state="checked"] [data-parity-role="track"]',
          disabled:
            '[data-parity-component="switch"] [data-parity-state="disabled"] [data-parity-role="track"]'
        },
        showcaseSelectors: {
          default: '[data-sb-section="field"] .sb-parity-switch-default .sb-switch-track',
          checked: '[data-sb-section="field"] .sb-parity-switch-checked .sb-switch-track',
          disabled: '[data-sb-section="field"] .sb-parity-switch-disabled .sb-switch-track'
        }
      }
    },
    states: ["default", "checked", "disabled"],
    themes: ["light", "dark"]
  },
  textarea: {
    component: "textarea",
    parityUrl: "http://127.0.0.1:5173/?component=textarea",
    showcaseUrl: "http://127.0.0.1:4321/#field",
    showcaseReadySelector: '[data-sb-section="field"]:not([hidden])',
    referenceSelectors: {
      default: '[data-parity-component="textarea"] [data-parity-state="default"]',
      focus: '[data-parity-component="textarea"] [data-parity-state="focus"]',
      disabled: '[data-parity-component="textarea"] [data-parity-state="disabled"]',
      invalid: '[data-parity-component="textarea"] [data-parity-state="invalid"]'
    },
    showcaseSelectors: {
      default: '[data-sb-section="field"] .sb-parity-textarea-default textarea',
      focus: '[data-sb-section="field"] .sb-parity-textarea-default textarea',
      disabled: '[data-sb-section="field"] .sb-parity-textarea-disabled textarea',
      invalid: '[data-sb-section="field"] .sb-parity-textarea-invalid textarea'
    },
    props: TEXTAREA_PROPS,
    states: ["default", "focus", "disabled", "invalid"],
    themes: ["light", "dark"],
    prepareReferenceState: prepareFocusState,
    prepareShowcaseState: prepareFocusState
  }
};

export function listComponentNames() {
  return Object.keys(REGISTRY).sort();
}

export function getComponentConfig(name) {
  const config = REGISTRY[name];
  if (!config) {
    throw new Error(
      `Unknown parity component "${name}". Known: ${Object.keys(REGISTRY).join(", ")}`
    );
  }
  return config;
}
