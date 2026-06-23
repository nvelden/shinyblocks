import { useEffect, useRef, useState } from "react";
import { classNames, HtmlSlot, Icon, passthroughAttrs } from "./shared.jsx";

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

  // Author-provided passthrough attributes (title, data-*, etc.) are fixed at
  // construction — the updater cannot change them. Pull `aria-label` /
  // `aria-labelledby` out of the spread so the busy state can override the
  // accessible name and restore the author's labeling when ready; `style` flows
  // through its own state channel (so the updater's style messages win).
  const attrs = passthroughAttrs(initialProps.attrs);
  const authorAriaLabel =
    typeof attrs["aria-label"] === "string" ? attrs["aria-label"] : null;
  const authorAriaLabelledBy =
    typeof attrs["aria-labelledby"] === "string" ? attrs["aria-labelledby"] : null;
  delete attrs["aria-label"];
  delete attrs["aria-labelledby"];
  delete attrs.style;

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
  // Mirrors of the values the click binding and receive handler need
  // synchronously. A combined server update computes one consistent next state
  // from these refs instead of layering stale closure reads field by field.
  const taskStateRef = useRef(taskState);
  const authorDisabledRef = useRef(authorDisabled);
  const labelBusyRef = useRef(labelBusy);

  // Reflect the complete next state onto the real button in one pass, before
  // React reconciles. The click binding calls this (via the setter) for the
  // synchronous lock; the receive handler calls it after computing the merged
  // next state.
  function syncButtonDom(nextState, nextAuthorDisabled, nextLabelBusy) {
    const button = buttonRef.current;
    if (!button) return;
    const busy = nextState === "busy";
    button.disabled = nextAuthorDisabled || busy;
    button.setAttribute("data-state", busy ? "busy" : "ready");
    if (busy) {
      button.setAttribute("aria-busy", "true");
      // While busy the accessible name is the busy label.
      button.setAttribute("aria-label", nextLabelBusy || "");
    } else {
      button.removeAttribute("aria-busy");
      // Restore the author's accessible name (or clear ours when none).
      if (authorAriaLabel != null) {
        button.setAttribute("aria-label", authorAriaLabel);
      } else {
        button.removeAttribute("aria-label");
      }
    }
  }

  useEffect(() => {
    if (!root) return undefined;

    if (typeof root.__sbTaskButtonClickCount === "undefined") {
      root.__sbTaskButtonClickCount = Number(initialState.value) || 0;
    }
    root.__sbTaskButtonAutoReset = Boolean(initialProps.autoReset);

    // The click binding installs the synchronous lock by calling this setter.
    root.__sbTaskButtonSetState = (nextState) => {
      const next = nextState === "busy" ? "busy" : "ready";
      taskStateRef.current = next;
      syncButtonDom(next, authorDisabledRef.current, labelBusyRef.current);
      setTaskState(next);
    };

    root.__sbTaskButtonReceive = (data) => {
      const d = data || {};
      const has = (key) => Object.prototype.hasOwnProperty.call(d, key);

      // Compute the complete next synchronous state first, then sync the DOM
      // once — never field-by-field with stale values (a combined
      // {state, disabled} update must not flip disabled mid-apply).
      let nextState = taskStateRef.current;
      let nextDisabled = authorDisabledRef.current;
      let nextLabelBusy = labelBusyRef.current;
      if (has("state")) nextState = d.state === "busy" ? "busy" : "ready";
      if (has("disabled")) nextDisabled = Boolean(d.disabled);
      if (has("labelBusy")) nextLabelBusy = d.labelBusy == null ? "" : String(d.labelBusy);

      if (has("state")) setTaskState(nextState);
      if (has("disabled")) setAuthorDisabled(nextDisabled);
      if (has("labelBusy")) setLabelBusy(nextLabelBusy);
      if (has("labelHtml")) setLabelHtml(d.labelHtml == null ? "" : String(d.labelHtml));
      if (has("variant")) setVariant(d.variant || "default");
      if (has("size")) setSize(d.size || "default");
      if (has("iconPosition")) setIconPosition(d.iconPosition || "inline-start");
      if (has("iconName")) setIconName(d.iconName == null ? null : String(d.iconName));
      if (has("iconHtml")) setIconHtml(d.iconHtml == null ? null : String(d.iconHtml));
      if (has("iconBusyName")) setIconBusyName(d.iconBusyName == null ? null : String(d.iconBusyName));
      if (has("iconBusyHtml")) setIconBusyHtml(d.iconBusyHtml == null ? null : String(d.iconBusyHtml));
      if (has("spriteHref")) setSpriteHref(d.spriteHref || "");
      if (has("style")) setStyle(d.style == null ? {} : d.style);
      if (has("class")) setClassName(d.class == null ? "" : String(d.class));

      taskStateRef.current = nextState;
      authorDisabledRef.current = nextDisabled;
      labelBusyRef.current = nextLabelBusy;
      syncButtonDom(nextState, nextDisabled, nextLabelBusy);
    };

    return () => {
      delete root.__sbTaskButtonSetState;
      delete root.__sbTaskButtonReceive;
    };
  }, [root]);

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
  const busyIndicator = hasBusyIcon ? <Icon payload={busyIconPayload} /> : <BusySpinner />;

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
        aria-label={busy ? labelBusy : (authorAriaLabel ?? undefined)}
        aria-labelledby={busy ? undefined : (authorAriaLabelledBy ?? undefined)}
        className={classNames(
          "sb-button",
          "sb-task-button",
          `sb-button-${variant}`,
          `sb-button-size-${size}`,
          className
        )}
        disabled={disabled}
        style={style}
        {...attrs}
      >
        {busy ? (
          <>
            {iconPosition === "inline-start" && busyIndicator}
            {/* Visible busy label, hidden from AT to avoid a duplicate
                announcement alongside the status region. */}
            <span aria-hidden="true">{labelBusy}</span>
            {iconPosition === "inline-end" && busyIndicator}
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
