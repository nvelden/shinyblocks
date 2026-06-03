import { useEffect, useRef, useState } from "react";
import { createPortal } from "react-dom";
import { ensurePortalRoot } from "../runtime/dom.js";
import { classNames } from "./shared.jsx";

const FOCUSABLE_SELECTOR = [
  "a[href]",
  "button:not([disabled])",
  "textarea:not([disabled])",
  "input:not([disabled]):not([type='hidden'])",
  "select:not([disabled])",
  "[tabindex]:not([tabindex='-1'])"
].join(",");

function focusableChildren(container) {
  if (!container) return [];
  return Array.from(container.querySelectorAll(FOCUSABLE_SELECTOR)).filter(
    (el) => !el.hasAttribute("aria-hidden") && el.offsetParent !== null
  );
}

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

export function Popover({ payload, root }) {
  const props = payload.props || {};
  const state = payload.state || {};
  const [open, setOpenState] = useState(Boolean(state.open));
  const [position, setPosition] = useState(null);
  const [triggerLabel, setTriggerLabel] = useState(props.triggerLabel || "");
  const [bodyHtml, setBodyHtml] = useState(props.bodyHtml || "");
  const [side, setSide] = useState(props.side || "bottom");
  const [align, setAlign] = useState(props.align || "center");
  const [contentStyle, setContentStyle] = useState(props.contentStyle || null);
  const [contentClass, setContentClass] = useState(props.contentClass || null);
  const triggerRef = useRef(null);
  const contentRef = useRef(null);
  const returnFocusRef = useRef(null);
  const contentId = `${payload.id || "popover"}-content`;

  function setOpen(next, notify) {
    const nextOpen = Boolean(next);
    if (nextOpen && !open) {
      returnFocusRef.current = document.activeElement;
    }
    setOpenState(nextOpen);
    if (root) {
      root.__sbPopoverValue = nextOpen;
      root.dataset.sbPopoverOpen = nextOpen ? "true" : "false";
    }
    if (notify !== false && root) {
      root.dispatchEvent(new CustomEvent("sb:popover-change"));
    }
  }

  useEffect(() => {
    if (!root) return undefined;

    root.__sbPopoverValue = open;
    root.dataset.sbPopoverOpen = open ? "true" : "false";

    root.__sbPopoverReceive = (data) => {
      const nextData = data || {};

      if (Object.prototype.hasOwnProperty.call(nextData, "triggerLabel")) {
        setTriggerLabel(nextData.triggerLabel || "");
      }
      if (Object.prototype.hasOwnProperty.call(nextData, "bodyHtml")) {
        setBodyHtml(nextData.bodyHtml || "");
      }
      if (Object.prototype.hasOwnProperty.call(nextData, "side")) {
        setSide(nextData.side || "bottom");
      }
      if (Object.prototype.hasOwnProperty.call(nextData, "align")) {
        setAlign(nextData.align || "center");
      }
      if (Object.prototype.hasOwnProperty.call(nextData, "contentStyle")) {
        setContentStyle(nextData.contentStyle || null);
      }
      if (Object.prototype.hasOwnProperty.call(nextData, "contentClass")) {
        setContentClass(nextData.contentClass || null);
      }
      if (Object.prototype.hasOwnProperty.call(nextData, "open")) {
        setOpen(Boolean(nextData.open), Boolean(nextData.notify));
      }
    };

    return () => {
      delete root.__sbPopoverReceive;
    };
  }, [root]);

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

    const focusFrame = requestAnimationFrame(() => {
      const focusables = focusableChildren(contentRef.current);
      const initial = focusables[0] || contentRef.current;
      if (initial && typeof initial.focus === "function") {
        initial.focus({ preventScroll: true });
      }
    });

    function onDocumentPointerDown(event) {
      const target = event.target;
      if (triggerRef.current?.contains(target)) return;
      if (contentRef.current?.contains(target)) return;
      setOpen(false);
    }

    function onDocumentKeyDown(event) {
      if (event.key !== "Escape") return;
      event.stopPropagation();
      setOpen(false);
    }

    document.addEventListener("pointerdown", onDocumentPointerDown);
    document.addEventListener("keydown", onDocumentKeyDown);

    return () => {
      cancelAnimationFrame(focusFrame);
      document.removeEventListener("pointerdown", onDocumentPointerDown);
      document.removeEventListener("keydown", onDocumentKeyDown);

      const target = returnFocusRef.current;
      returnFocusRef.current = null;
      if (target && typeof target.focus === "function") {
        requestAnimationFrame(() => target.focus({ preventScroll: true }));
      }
    };
  }, [open]);

  const portal = ensurePortalRoot();

  return (
    <>
      <button
        ref={triggerRef}
        type="button"
        className="sb-button sb-button-default sb-button-size-default"
        data-slot="popover-trigger"
        aria-haspopup="dialog"
        aria-expanded={open ? "true" : "false"}
        aria-controls={open ? contentId : undefined}
        onClick={() => setOpen(!open)}
      >
        {triggerLabel}
      </button>
      {open && position &&
        createPortal(
          <div
            id={contentId}
            ref={contentRef}
            className={classNames("sb-popover-content", contentClass)}
            data-slot="popover-content"
            data-side={side}
            data-align={align}
            role="dialog"
            tabIndex={-1}
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
