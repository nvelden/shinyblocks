import { useEffect, useRef, useState } from "react";
import { createPortal } from "react-dom";
import { ensurePortalRoot } from "../runtime/dom.js";
import { classNames, HtmlSlot } from "./shared.jsx";

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

export function Dialog({ payload, root }) {
  const props = payload.props || {};
  const state = payload.state || {};
  const inputId = payload.id || "dialog";
  const [open, setOpenState] = useState(Boolean(state.open));
  const [titleHtml, setTitleHtml] = useState(props.titleHtml || "");
  const [descriptionHtml, setDescriptionHtml] = useState(
    props.descriptionHtml || ""
  );
  const [footerHtml, setFooterHtml] = useState(props.footerHtml || "");
  const [size, setSize] = useState(props.size || "default");
  const [contentClassName, setContentClassName] = useState(
    payload.className || ""
  );
  const [contentStyle, setContentStyle] = useState(payload.style || {});
  const hideTitle = Boolean(props.hideTitle);
  const titleId = `${inputId}-title`;
  const descriptionId = `${inputId}-description`;

  const contentRef = useRef(null);
  const returnFocusRef = useRef(null);

  function setOpen(next, notify) {
    const nextOpen = Boolean(next);
    if (nextOpen && !open) {
      returnFocusRef.current = document.activeElement;
    }
    setOpenState(nextOpen);
    if (root) {
      root.__sbDialogValue = nextOpen;
      root.dataset.sbDialogOpen = nextOpen ? "true" : "false";
    }
    if (notify !== false && root) {
      root.dispatchEvent(new CustomEvent("sb:dialog-change"));
    }
  }

  useEffect(() => {
    if (!root) return undefined;

    root.__sbDialogValue = open;
    root.dataset.sbDialogOpen = open ? "true" : "false";

    root.__sbDialogReceive = (data) => {
      const nextData = data || {};

      if (Object.prototype.hasOwnProperty.call(nextData, "titleHtml")) {
        setTitleHtml(nextData.titleHtml || "");
      }
      if (Object.prototype.hasOwnProperty.call(nextData, "descriptionHtml")) {
        setDescriptionHtml(nextData.descriptionHtml || "");
      }
      if (Object.prototype.hasOwnProperty.call(nextData, "footerHtml")) {
        setFooterHtml(nextData.footerHtml || "");
      }
      if (Object.prototype.hasOwnProperty.call(nextData, "size")) {
        setSize(nextData.size || "default");
      }
      if (Object.prototype.hasOwnProperty.call(nextData, "class")) {
        setContentClassName(nextData.class || "");
      }
      if (Object.prototype.hasOwnProperty.call(nextData, "style")) {
        setContentStyle(nextData.style || {});
      }
      if (Object.prototype.hasOwnProperty.call(nextData, "open")) {
        setOpen(Boolean(nextData.open), Boolean(nextData.notify));
      }
    };

    return () => {
      delete root.__sbDialogReceive;
    };
  }, [root]);

  useEffect(() => {
    if (!open) return undefined;

    const previousOverflow = document.body.style.overflow;
    const previousPaddingRight = document.body.style.paddingRight;
    const scrollbarWidth =
      window.innerWidth - document.documentElement.clientWidth;
    document.body.style.overflow = "hidden";
    if (scrollbarWidth > 0) {
      document.body.style.paddingRight = `${scrollbarWidth}px`;
    }

    const focusables = focusableChildren(contentRef.current);
    const initial = focusables[0] || contentRef.current;
    initial && initial.focus({ preventScroll: true });

    function onKeyDown(event) {
      if (event.key === "Escape") {
        event.stopPropagation();
        setOpen(false);
        return;
      }
      if (event.key !== "Tab") return;

      const items = focusableChildren(contentRef.current);
      if (items.length === 0) {
        event.preventDefault();
        contentRef.current && contentRef.current.focus();
        return;
      }

      const first = items[0];
      const last = items[items.length - 1];
      const active = document.activeElement;

      if (event.shiftKey && active === first) {
        event.preventDefault();
        last.focus();
      } else if (!event.shiftKey && active === last) {
        event.preventDefault();
        first.focus();
      }
    }

    document.addEventListener("keydown", onKeyDown);

    return () => {
      document.removeEventListener("keydown", onKeyDown);
      document.body.style.overflow = previousOverflow;
      document.body.style.paddingRight = previousPaddingRight;

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
      {props.triggerLabel && (
        <button
          type="button"
          className="sb-button sb-button-default sb-button-size-default"
          data-slot="dialog-trigger"
          aria-haspopup="dialog"
          aria-expanded={open ? "true" : "false"}
          onClick={() => setOpen(true)}
        >
          {props.triggerLabel}
        </button>
      )}
      {open &&
        createPortal(
          <div data-slot="dialog" data-sb-dialog-open="true">
            <div
              className="sb-dialog-overlay"
              data-slot="dialog-overlay"
              onClick={() => setOpen(false)}
            />
            <div
              role="dialog"
              aria-modal="true"
              aria-labelledby={titleId}
              aria-describedby={descriptionHtml ? descriptionId : undefined}
              tabIndex={-1}
              ref={contentRef}
              className={classNames(
                "sb-dialog-content",
                `sb-dialog-content-size-${size}`,
                contentClassName
              )}
              style={contentStyle}
              data-slot="dialog-content"
              data-size={size}
            >
              <div className="sb-dialog-header" data-slot="dialog-header">
                <HtmlSlot
                  html={titleHtml}
                  id={titleId}
                  className={classNames(
                    "sb-dialog-title",
                    hideTitle && "sb-visually-hidden"
                  )}
                />
                {descriptionHtml && (
                  <HtmlSlot
                    html={descriptionHtml}
                    id={descriptionId}
                    className="sb-dialog-description"
                  />
                )}
              </div>
              {props.bodyHtml && (
                <HtmlSlot
                  as="div"
                  className="sb-dialog-body"
                  data-slot="dialog-body"
                  html={props.bodyHtml}
                />
              )}
              {footerHtml && (
                <HtmlSlot
                  as="div"
                  className="sb-dialog-footer"
                  data-slot="dialog-footer"
                  html={footerHtml}
                />
              )}
              <button
                type="button"
                className="sb-dialog-close"
                data-slot="dialog-close"
                aria-label="Close"
                onClick={() => setOpen(false)}
              >
                ×
              </button>
            </div>
          </div>,
          portal
        )}
    </>
  );
}
