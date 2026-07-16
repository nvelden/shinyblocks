import { useEffect, useRef, useState } from "react";
import { createPortal } from "react-dom";
import { ensurePortalRoot } from "../runtime/dom.js";
import {
  floatingTransform,
  useFloatingPosition
} from "../runtime/overlays.js";
import { classNames, HtmlSlot } from "./shared.jsx";

export function Tooltip({ payload, root }) {
  const props = payload.props || {};
  const [open, setOpen] = useState(false);
  const triggerRef = useRef(null);
  const contentRef = useRef(null);
  const openTimerRef = useRef(null);
  const closeTimerRef = useRef(null);
  const triggerLabel = props.triggerLabel || "";
  const bodyHtml = props.bodyHtml || "";
  const side = props.side || "top";
  const align = props.align || "center";
  const delay = Number.isFinite(props.delayDuration) ? props.delayDuration : 700;
  const contentStyle = props.contentStyle || null;
  const contentClass = props.contentClass || null;
  const contentId = `${payload.id || "tooltip"}-content`;
  const position = useFloatingPosition({ open, triggerRef, side, align });

  function clearTimers() {
    if (openTimerRef.current) {
      clearTimeout(openTimerRef.current);
      openTimerRef.current = null;
    }
    if (closeTimerRef.current) {
      clearTimeout(closeTimerRef.current);
      closeTimerRef.current = null;
    }
  }

  function scheduleOpen() {
    clearTimers();
    if (open) return;
    openTimerRef.current = setTimeout(() => {
      openTimerRef.current = null;
      setOpen(true);
    }, delay);
  }

  function scheduleClose() {
    clearTimers();
    if (!open) return;
    closeTimerRef.current = setTimeout(() => {
      closeTimerRef.current = null;
      setOpen(false);
    }, 150);
  }

  useEffect(() => () => clearTimers(), []);

  useEffect(() => {
    if (!open) return undefined;

    function onKeyDown(event) {
      if (event.key !== "Escape") return;
      event.stopPropagation();
      clearTimers();
      setOpen(false);
    }

    document.addEventListener("keydown", onKeyDown);
    return () => {
      document.removeEventListener("keydown", onKeyDown);
    };
  }, [open]);

  const portal = ensurePortalRoot(root);

  return (
    <>
      <button
        ref={triggerRef}
        type="button"
        className="sb-button sb-button-outline sb-button-size-default"
        data-slot="tooltip-trigger"
        aria-describedby={open ? contentId : undefined}
        onMouseEnter={scheduleOpen}
        onMouseLeave={scheduleClose}
        onFocus={scheduleOpen}
        onBlur={scheduleClose}
      >
        {triggerLabel}
      </button>
      {open && position &&
        createPortal(
          <div
            id={contentId}
            ref={contentRef}
            className={classNames("sb-tooltip-content", contentClass)}
            data-slot="tooltip-content"
            data-side={side}
            data-align={align}
            role="tooltip"
            onMouseEnter={scheduleOpen}
            onMouseLeave={scheduleClose}
            style={{
              position: "fixed",
              top: `${position.top}px`,
              left: `${position.left}px`,
              transform: floatingTransform(side, align),
              ...(contentStyle || {})
            }}
          >
            <HtmlSlot as="div" html={bodyHtml} />
          </div>,
          portal
        )}
    </>
  );
}
