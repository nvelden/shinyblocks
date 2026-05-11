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

function setTheme() {
  const params = new URLSearchParams(window.location.search);
  const theme = params.get("theme") === "dark" ? "dark" : "light";
  document.documentElement.dataset.theme = theme;
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
  return e(NotFound);
}

createRoot(document.getElementById("root")).render(e(App));
