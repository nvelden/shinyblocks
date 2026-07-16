import { useEffect, useRef, useState } from "react";
import { createPortal } from "react-dom";
import { ensurePortalRoot } from "../runtime/dom.js";
import {
  floatingTransform,
  focusableChildren,
  useFloatingPosition
} from "../runtime/overlays.js";
import { classNames, HtmlSlot } from "./shared.jsx";

export function Popover({ payload, root }) {
  const props = payload.props || {};
  const state = payload.state || {};
  const [open, setOpenState] = useState(Boolean(state.open));
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
  const position = useFloatingPosition({ open, triggerRef, side, align });

  function setOpen(next, notify) {
    const nextOpen = Boolean(next);
    if (nextOpen && !open) {
      const active = document.activeElement;
      returnFocusRef.current =
        active && active !== document.body ? active : triggerRef.current;
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

      const storedTarget = returnFocusRef.current;
      const target =
        storedTarget && storedTarget !== document.body ? storedTarget : triggerRef.current;
      returnFocusRef.current = null;
      if (target && typeof target.focus === "function") {
        target.focus({ preventScroll: true });
        requestAnimationFrame(() => target.focus({ preventScroll: true }));
      }
    };
  }, [open]);

  const portal = ensurePortalRoot(root);

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
