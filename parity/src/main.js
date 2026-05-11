import React from "react";
import { createRoot } from "react-dom/client";

const e = React.createElement;

const BUTTON_CLASS = [
  "inline-flex",
  "items-center",
  "justify-center",
  "gap-2",
  "whitespace-nowrap",
  "rounded-md",
  "text-sm",
  "font-medium",
  "transition-[color,box-shadow]",
  "disabled:pointer-events-none",
  "disabled:opacity-50",
  "outline-none",
  "focus-visible:border-ring",
  "focus-visible:ring-ring/50",
  "focus-visible:ring-[3px]",
  "aria-invalid:ring-destructive/20",
  "dark:aria-invalid:ring-destructive/40",
  "aria-invalid:border-destructive",
  "bg-primary",
  "text-primary-foreground",
  "shadow-xs",
  "hover:bg-primary/90",
  "h-9",
  "px-4",
  "py-2"
].join(" ");

const SELECT_TRIGGER_BASE_CLASS = [
  "flex",
  "w-[180px]",
  "items-center",
  "justify-between",
  "gap-2",
  "whitespace-nowrap",
  "rounded-lg",
  "border",
  "px-2.5",
  "py-0",
  "pr-8",
  "text-sm",
  "text-foreground",
  "outline-none",
  "transition-[color,box-shadow]",
  "h-8",
  "min-h-8",
  "leading-5",
  "relative"
].join(" ");

const SELECT_TRIGGER_DEFAULT_CLASS = [
  SELECT_TRIGGER_BASE_CLASS,
  "border-input",
  "bg-transparent",
  "shadow-xs"
].join(" ");

const SELECT_TRIGGER_OPEN_CLASS = [
  SELECT_TRIGGER_BASE_CLASS,
  "bg-background",
  "border-ring",
  "shadow-xs",
  "ring-[3px]",
  "ring-ring/50"
].join(" ");

const SELECT_ICON_CLASS = "pointer-events-none absolute right-2 size-4 shrink-0 text-muted-foreground";

const SELECT_DROPDOWN_CLASS = [
  "mt-1",
  "w-[180px]",
  "overflow-hidden",
  "rounded-md",
  "border",
  "border-border",
  "bg-popover",
  "p-1",
  "text-popover-foreground",
  "shadow-md"
].join(" ");

const SELECT_OPTION_CLASS = [
  "rounded-sm",
  "px-2",
  "py-1.5",
  "text-sm",
  "text-popover-foreground"
].join(" ");
const TEXTAREA_CLASS = [
  "parity-textarea",
  "flex",
  "field-sizing-content",
  "min-h-16",
  "w-full",
  "rounded-md",
  "border",
  "border-input",
  "bg-transparent",
  "px-3",
  "py-2",
  "text-sm",
  "text-foreground",
  "shadow-xs",
  "outline-none",
  "transition-[color,box-shadow]",
  "placeholder:text-muted-foreground",
  "focus-visible:border-ring",
  "focus-visible:ring-[3px]",
  "focus-visible:ring-ring/50",
  "aria-invalid:border-destructive",
  "aria-invalid:ring-[3px]",
  "aria-invalid:ring-destructive/20",
  "dark:aria-invalid:ring-destructive/40",
  "disabled:cursor-not-allowed",
  "disabled:opacity-50"
].join(" ");

const SLIDER_ROOT_CLASS = "parity-slider-root";
const SLIDER_ROOT_DISABLED_CLASS = "parity-slider-root parity-slider-root-disabled";
const SLIDER_TRACK_CLASS = "parity-slider-track";
const SLIDER_RANGE_CLASS = "parity-slider-range";
const SLIDER_THUMB_CLASS = "parity-slider-thumb";
const CHECKBOX_ROOT_CLASS = "parity-checkbox-root";
const CHECKBOX_ROOT_DISABLED_CLASS = "parity-checkbox-root parity-checkbox-root-disabled";
const CHECKBOX_LABEL_CLASS = "parity-checkbox-label";
const CHECKBOX_INDICATOR_CLASS = "parity-checkbox-indicator";
const CHECKBOX_INDICATOR_CHECKED_CLASS =
  "parity-checkbox-indicator parity-checkbox-indicator-checked";
const SWITCH_ROOT_DISABLED_CLASS = "parity-switch-root parity-switch-root-disabled";
const SWITCH_LABEL_CLASS = "parity-switch-label";
const SWITCH_TRACK_CLASS = "parity-switch-track";
const SWITCH_TRACK_CHECKED_CLASS = "parity-switch-track parity-switch-track-checked";

function setTheme() {
  const params = new URLSearchParams(window.location.search);
  const theme = params.get("theme") === "dark" ? "dark" : "light";
  document.documentElement.dataset.theme = theme;
  document.documentElement.classList.toggle("dark", theme === "dark");
}

function Stage(props) {
  return e(
    "main",
    {
      "data-parity-component": props.component,
      className: "parity-stage"
    },
    props.children
  );
}

function ChevronIcon() {
  return e(
    "svg",
    {
      "aria-hidden": "true",
      className: SELECT_ICON_CLASS,
      viewBox: "0 0 24 24",
      fill: "none",
      stroke: "currentColor",
      strokeWidth: "2",
      strokeLinecap: "round",
      strokeLinejoin: "round"
    },
    e("path", { d: "m6 9 6 6 6-6" })
  );
}

function ButtonRoute() {
  return e(
    Stage,
    { component: "button" },
    e(
      "div",
      { className: "parity-stack" },
      e(
        "div",
        { className: "parity-row" },
        e(
          "button",
          {
            type: "button",
            className: `${BUTTON_CLASS} sb-parity-target`,
            "data-parity-state": "default"
          },
          "Button"
        ),
        e(
          "button",
          {
            type: "button",
            className: `${BUTTON_CLASS} sb-parity-target`,
            "data-parity-state": "disabled",
            disabled: true
          },
          "Disabled"
        )
      )
    )
  );
}

function SelectRoute() {
  return e(
    Stage,
    { component: "select" },
    e(
      "div",
      { className: "parity-stack" },
      e(
        "div",
        { className: "parity-row items-start" },
        e(
          "div",
          { className: "flex flex-col gap-1" },
          e(
            "button",
            {
              type: "button",
              className: SELECT_TRIGGER_DEFAULT_CLASS,
              "data-parity-state": "default"
            },
            e("span", null, "Free"),
            e(ChevronIcon)
          )
        ),
        e(
          "div",
          { className: "flex flex-col gap-0" },
          e(
            "button",
            {
              type: "button",
              className: SELECT_TRIGGER_OPEN_CLASS,
              "data-parity-state": "open",
              "aria-expanded": "true"
            },
            e("span", null, "Free"),
            e(ChevronIcon)
          ),
          e(
            "div",
            {
              className: SELECT_DROPDOWN_CLASS,
              "aria-hidden": "true"
            },
            e(
              "div",
              {
                className: `${SELECT_OPTION_CLASS} font-medium`
              },
              "Free"
            ),
            e(
              "div",
              {
                className: `${SELECT_OPTION_CLASS} bg-accent text-accent-foreground`
              },
              "Pro"
            ),
            e(
              "div",
              { className: SELECT_OPTION_CLASS },
              "Enterprise"
            )
          )
        )
      )
    )
  );
}

function SliderShape(props) {
  const rootClass = props.disabled ? SLIDER_ROOT_DISABLED_CLASS : SLIDER_ROOT_CLASS;

  return e(
    "div",
    {
      className: rootClass,
      "data-parity-state": props.state,
      "data-parity-role": "root"
    },
    e(
      "span",
      { className: SLIDER_TRACK_CLASS, "data-parity-role": "rail" },
      e("span", { className: SLIDER_RANGE_CLASS, "data-parity-role": "range" })
    ),
    e("span", { className: SLIDER_THUMB_CLASS, "data-parity-role": "thumb" })
  );
}

function SliderRoute() {
  return e(
    Stage,
    { component: "slider" },
    e(
      "div",
      { className: "parity-stack" },
      e(
        "div",
        { className: "parity-row items-start" },
        e(
          "div",
          { className: "flex flex-col gap-3" },
          e(SliderShape, { state: "default", disabled: false }),
          e(SliderShape, { state: "disabled", disabled: true })
        )
      )
    )
  );
}

function TextareaRoute() {
  return e(
    Stage,
    { component: "textarea" },
    e(
      "div",
      { className: "parity-stack" },
      e(
        "div",
        { className: "flex max-w-md flex-col gap-3" },
        e("textarea", {
          className: TEXTAREA_CLASS,
          rows: 2,
          placeholder: "Record rollout details for the next operator.",
          "data-parity-state": "default"
        }),
        e("textarea", {
          className: TEXTAREA_CLASS,
          rows: 2,
          defaultValue: "Focused textarea reference content.",
          "data-parity-state": "focus"
        }),
        e("textarea", {
          className: TEXTAREA_CLASS,
          rows: 2,
          defaultValue: "Escalate to the on-call operator if retries fail.",
          "data-parity-state": "disabled",
          disabled: true
        }),
        e("textarea", {
          className: TEXTAREA_CLASS,
          rows: 2,
          defaultValue: "Document rollback steps before continuing.",
          "data-parity-state": "invalid",
          "aria-invalid": "true"
        })
      )
    )
  );
}

function CheckboxShape(props) {
  const rootClass = props.disabled ? CHECKBOX_ROOT_DISABLED_CLASS : CHECKBOX_ROOT_CLASS;
  const indicatorClass = props.checked ? CHECKBOX_INDICATOR_CHECKED_CLASS : CHECKBOX_INDICATOR_CLASS;

  return e(
    "div",
    {
      className: rootClass,
      "data-parity-state": props.state
    },
    e(
      "label",
      { className: CHECKBOX_LABEL_CLASS },
      e("span", {
        className: indicatorClass,
        "data-parity-role": "indicator",
        "aria-hidden": "true"
      }),
      e("span", { "data-parity-role": "text" }, props.label)
    )
  );
}

function CheckboxRoute() {
  return e(
    Stage,
    { component: "checkbox" },
    e(
      "div",
      { className: "parity-stack" },
      e(
        "div",
        { className: "flex flex-col gap-3" },
        e(CheckboxShape, {
          state: "default",
          checked: false,
          disabled: false,
          label: "Email me product updates"
        }),
        e(CheckboxShape, {
          state: "checked",
          checked: true,
          disabled: false,
          label: "Join beta releases"
        }),
        e(CheckboxShape, {
          state: "disabled",
          checked: false,
          disabled: true,
          label: "Paused notifications"
        })
      )
    )
  );
}

function SwitchShape(props) {
  const rootClass = props.disabled ? SWITCH_ROOT_DISABLED_CLASS : "parity-switch-root";
  const trackClass = props.checked ? SWITCH_TRACK_CHECKED_CLASS : SWITCH_TRACK_CLASS;

  return e(
    "div",
    {
      className: rootClass,
      "data-parity-state": props.state
    },
    e(
      "label",
      { className: SWITCH_LABEL_CLASS },
      e("span", {
        className: trackClass,
        "data-parity-role": "track",
        "aria-hidden": "true"
      }),
      e("span", { "data-parity-role": "text" }, props.label)
    )
  );
}

function SwitchRoute() {
  return e(
    Stage,
    { component: "switch" },
    e(
      "div",
      { className: "parity-stack" },
      e(
        "div",
        { className: "flex flex-col gap-3" },
        e(SwitchShape, {
          state: "default",
          checked: false,
          disabled: false,
          label: "Send incident alerts"
        }),
        e(SwitchShape, {
          state: "checked",
          checked: true,
          disabled: false,
          label: "Auto-resolve low-severity pages"
        }),
        e(SwitchShape, {
          state: "disabled",
          checked: false,
          disabled: true,
          label: "Mute low-priority alerts"
        })
      )
    )
  );
}

function NotFound() {
  return e(
    Stage,
    { component: "index" },
    e("h1", { className: "parity-title" }, "shinyblocks parity"),
    e(
      "p",
      { className: "parity-copy" },
      "Open /button?theme=light or /button?theme=dark."
    )
  );
}

function App() {
  const params = new URLSearchParams(window.location.search);
  setTheme();
  const component = params.get("component");
  const path = window.location.pathname.replace(/\/+$/, "") || "/";
  if (component === "button" || path === "/button") {
    return e(ButtonRoute);
  }
  if (component === "select" || path === "/select") {
    return e(SelectRoute);
  }
  if (component === "slider" || path === "/slider") {
    return e(SliderRoute);
  }
  if (component === "checkbox" || path === "/checkbox") {
    return e(CheckboxRoute);
  }
  if (component === "switch" || path === "/switch") {
    return e(SwitchRoute);
  }
  if (component === "textarea" || path === "/textarea") {
    return e(TextareaRoute);
  }
  return e(NotFound);
}

createRoot(document.getElementById("root")).render(e(App));
