import { useEffect, useRef, useState } from "react";
import { classNames, HtmlSlot, Icon } from "./shared.jsx";

// Decorative busy spinner. `aria-hidden` and no status role — the persistent
// status region (below) carries the announcement, so the spinner must stay
// silent to assistive technology.
function BusySpinner() {
  return (
    <svg
      className="sb-task-button-spinner"
      data-slot="task-button-spinner"
      viewBox="0 0 24 24"
      fill="none"
      stroke="currentColor"
      strokeWidth="2"
      strokeLinecap="round"
      strokeLinejoin="round"
      aria-hidden="true"
      focusable="false"
    >
      <path d="M21 12a9 9 0 1 1-6.219-8.56" />
    </svg>
  );
}

export function TaskButton({ payload, root }) {
  const initialProps = payload.props || {};
  const initialState = payload.state || {};

  const [labelHtml, setLabelHtml] = useState(initialProps.labelHtml || "");
  const [labelBusy, setLabelBusy] = useState(initialProps.labelBusy || "");
  const [variant, setVariant] = useState(initialProps.variant || "default");
  const [size, setSize] = useState(initialProps.size || "default");
  const [iconName, setIconName] = useState(initialProps.iconName || null);
  const [iconHtml, setIconHtml] = useState(initialProps.iconHtml || null);
  const [iconBusyName, setIconBusyName] = useState(initialProps.iconBusyName || null);
  const [iconBusyHtml, setIconBusyHtml] = useState(initialProps.iconBusyHtml || null);
  const [iconPosition, setIconPosition] = useState(initialProps.iconPosition || "inline-start");
  const [spriteHref, setSpriteHref] = useState(initialProps.spriteHref || "");
  const [authorDisabled, setAuthorDisabled] = useState(Boolean(initialProps.disabled));
  const [style, setStyle] = useState(initialProps.style || {});
  const [className, setClassName] = useState(payload.className || "");
  const [taskState, setTaskState] = useState(
    initialState.state === "busy" ? "busy" : "ready"
  );
  const buttonRef = useRef(null);

  // Synchronously reflect a task-state change onto the real button before React
  // reconciles. The click binding calls this so the lock is visible in the same
  // tick as the click; the server-reset path calls it via the receive handler.
  function syncButtonDom(nextState, nextAuthorDisabled, nextLabelBusy) {
    const button = buttonRef.current;
    if (!button) return;
    const busy = nextState === "busy";
    button.disabled = nextAuthorDisabled || busy;
    button.setAttribute("data-state", busy ? "busy" : "ready");
    if (busy) {
      button.setAttribute("aria-busy", "true");
      // While busy the accessible name is the busy label; restore author
      // labeling (the label content) when ready.
      button.setAttribute("aria-label", nextLabelBusy || "");
    } else {
      button.removeAttribute("aria-busy");
      button.removeAttribute("aria-label");
    }
  }

  useEffect(() => {
    if (!root) return undefined;

    if (typeof root.__sbTaskButtonClickCount === "undefined") {
      root.__sbTaskButtonClickCount = Number(initialState.value) || 0;
    }
    root.__sbTaskButtonAutoReset = Boolean(initialProps.autoReset);

    // The click binding installs the synchronous lock by calling this setter,
    // then schedules React reconciliation through it.
    root.__sbTaskButtonSetState = (nextState) => {
      const next = nextState === "busy" ? "busy" : "ready";
      syncButtonDom(next, authorDisabled, labelBusy);
      setTaskState(next);
    };

    root.__sbTaskButtonReceive = (data) => {
      const nextData = data || {};

      if (Object.prototype.hasOwnProperty.call(nextData, "state")) {
        const next = nextData.state === "busy" ? "busy" : "ready";
        syncButtonDom(next, authorDisabled, labelBusy);
        setTaskState(next);
      }
      if (Object.prototype.hasOwnProperty.call(nextData, "labelHtml")) {
        setLabelHtml(nextData.labelHtml == null ? "" : String(nextData.labelHtml));
      }
      if (Object.prototype.hasOwnProperty.call(nextData, "labelBusy")) {
        setLabelBusy(nextData.labelBusy == null ? "" : String(nextData.labelBusy));
      }
      if (Object.prototype.hasOwnProperty.call(nextData, "variant")) {
        setVariant(nextData.variant || "default");
      }
      if (Object.prototype.hasOwnProperty.call(nextData, "size")) {
        setSize(nextData.size || "default");
      }
      if (Object.prototype.hasOwnProperty.call(nextData, "iconPosition")) {
        setIconPosition(nextData.iconPosition || "inline-start");
      }
      if (Object.prototype.hasOwnProperty.call(nextData, "iconName")) {
        setIconName(nextData.iconName == null ? null : String(nextData.iconName));
      }
      if (Object.prototype.hasOwnProperty.call(nextData, "iconHtml")) {
        setIconHtml(nextData.iconHtml == null ? null : String(nextData.iconHtml));
      }
      if (Object.prototype.hasOwnProperty.call(nextData, "iconBusyName")) {
        setIconBusyName(nextData.iconBusyName == null ? null : String(nextData.iconBusyName));
      }
      if (Object.prototype.hasOwnProperty.call(nextData, "iconBusyHtml")) {
        setIconBusyHtml(nextData.iconBusyHtml == null ? null : String(nextData.iconBusyHtml));
      }
      if (Object.prototype.hasOwnProperty.call(nextData, "spriteHref")) {
        setSpriteHref(nextData.spriteHref || "");
      }
      if (Object.prototype.hasOwnProperty.call(nextData, "disabled")) {
        const nextDisabled = Boolean(nextData.disabled);
        setAuthorDisabled(nextDisabled);
        syncButtonDom(taskState, nextDisabled, labelBusy);
      }
      if (Object.prototype.hasOwnProperty.call(nextData, "style")) {
        setStyle(nextData.style == null ? {} : nextData.style);
      }
      if (Object.prototype.hasOwnProperty.call(nextData, "class")) {
        setClassName(nextData.class == null ? "" : String(nextData.class));
      }
    };

    return () => {
      delete root.__sbTaskButtonSetState;
      delete root.__sbTaskButtonReceive;
    };
  }, [root, authorDisabled, labelBusy, taskState]);

  const busy = taskState === "busy";
  const disabled = authorDisabled || busy;

  const readyIconPayload = {
    props: { iconName, iconHtml, spriteHref, iconPosition }
  };
  const busyIconPayload = {
    props: {
      iconName: iconBusyName,
      iconHtml: iconBusyHtml,
      spriteHref,
      iconPosition
    }
  };
  const hasBusyIcon = Boolean(iconBusyName || iconBusyHtml);

  return (
    <>
      <button
        ref={buttonRef}
        type="button"
        data-slot="task-button"
        data-variant={variant}
        data-size={size}
        data-state={busy ? "busy" : "ready"}
        aria-busy={busy ? "true" : undefined}
        aria-label={busy ? labelBusy : undefined}
        className={classNames(
          "sb-button",
          "sb-task-button",
          `sb-button-${variant}`,
          `sb-button-size-${size}`,
          className
        )}
        disabled={disabled}
        style={style}
      >
        {busy ? (
          <>
            {hasBusyIcon ? <Icon payload={busyIconPayload} /> : <BusySpinner />}
            {/* Visible busy label, hidden from AT to avoid a duplicate
                announcement alongside the status region. */}
            <span aria-hidden="true">{labelBusy}</span>
          </>
        ) : (
          <>
            {iconPosition === "inline-start" && <Icon payload={readyIconPayload} />}
            <HtmlSlot html={labelHtml} />
            {iconPosition === "inline-end" && <Icon payload={readyIconPayload} />}
          </>
        )}
      </button>
      {/* One persistent live region: empty while ready, the busy label while
          busy. Kept mounted so screen readers announce the transition. */}
      <span className="sb-visually-hidden" role="status" aria-live="polite">
        {busy ? labelBusy : ""}
      </span>
    </>
  );
}
