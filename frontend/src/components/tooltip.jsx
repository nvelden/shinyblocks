import { useEffect, useRef, useState } from "react";
import { createPortal } from "react-dom";
import { ensurePortalRoot } from "../runtime/dom.js";
import { classNames } from "./shared.jsx";

function popoverTransform(side, align) {
  if (side === "top" || side === "bottom") {
    const y = side === "top" ? "-100%" : "0";
    if (align === "center") return `translate(-50%, ${y})`;
    if (align === "start") return `translate(0, ${y})`;
    return `translate(-100%, ${y})`;
  }
  const x = side === "left" ? "-100%" : "0";
  if (align === "center") return `translate(${x}, -50%)`;
  if (align === "end") return `translate(${x}, -100%)`;
  return `translate(${x}, 0)`;
}

export function Tooltip({ payload }) {
  const props = payload.props || {};
  const [open, setOpen] = useState(false);
  const [position, setPosition] = useState(null);
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
    if (!open || !triggerRef.current) return undefined;

    function updatePosition() {
      const rect = triggerRef.current.getBoundingClientRect();
      const offset = 8;
      let top = 0;
      let left = 0;
      if (side === "bottom") {
        top = rect.bottom + offset;
      } else if (side === "top") {
        top = rect.top - offset;
      } else if (side === "left") {
        left = rect.left - offset;
        top = rect.top;
      } else if (side === "right") {
        left = rect.right + offset;
        top = rect.top;
      }
      if (side === "top" || side === "bottom") {
        if (align === "center") {
          left = rect.left + rect.width / 2;
        } else if (align === "start") {
          left = rect.left;
        } else {
          left = rect.right;
        }
      } else if (align === "center") {
        top = rect.top + rect.height / 2;
      } else if (align === "end") {
        top = rect.bottom;
      }
      setPosition({ top, left });
    }

    updatePosition();
    window.addEventListener("scroll", updatePosition, true);
    window.addEventListener("resize", updatePosition);
    return () => {
      window.removeEventListener("scroll", updatePosition, true);
      window.removeEventListener("resize", updatePosition);
    };
  }, [open, side, align]);

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

  const portal = ensurePortalRoot();

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
              transform: popoverTransform(side, align),
              ...(contentStyle || {})
            }}
            dangerouslySetInnerHTML={{ __html: bodyHtml || "" }}
          />,
          portal
        )}
    </>
  );
}
