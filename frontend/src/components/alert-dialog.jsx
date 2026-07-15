import { useEffect, useRef, useState } from "react";
import { createPortal } from "react-dom";
import { ensurePortalRoot } from "../runtime/dom.js";
import { classNames, HtmlSlot } from "./shared.jsx";

const FOCUSABLE = "button:not([disabled]),a[href],[tabindex]:not([tabindex='-1'])";

function focusableChildren(container) {
  if (!container) return [];
  return Array.from(container.querySelectorAll(FOCUSABLE)).filter(
    (element) => element.offsetParent !== null
  );
}

export function AlertDialog({ payload, root }) {
  const props = payload.props || {};
  const state = payload.state || {};
  const inputId = payload.id || "alert-dialog";
  const [open, setOpen] = useState(Boolean(state.open));
  const [titleHtml, setTitleHtml] = useState(props.titleHtml || "");
  const [descriptionHtml, setDescriptionHtml] = useState(props.descriptionHtml || "");
  const [confirmLabel, setConfirmLabel] = useState(props.confirmLabel || "Continue");
  const [cancelLabel, setCancelLabel] = useState(props.cancelLabel || "Cancel");
  const [confirmVariant, setConfirmVariant] = useState(props.confirmVariant || "default");
  const [size, setSize] = useState(props.size || "default");
  const [contentClass, setContentClass] = useState(payload.className || "");
  const [contentStyle, setContentStyle] = useState(payload.style || {});
  const contentRef = useRef(null);
  const cancelRef = useRef(null);
  const returnFocusRef = useRef(null);
  const titleId = `${inputId}-title`;
  const descriptionId = `${inputId}-description`;

  function changeOpen(next) {
    if (next && !open) returnFocusRef.current = document.activeElement;
    setOpen(Boolean(next));
  }

  function choose(outcome) {
    if (root) {
      root.__sbAlertDialogValue = outcome;
      root.dispatchEvent(new CustomEvent("sb:alert-dialog-change"));
    }
    setOpen(false);
  }

  useEffect(() => {
    if (!root) return undefined;
    root.__sbAlertDialogValue = null;
    root.__sbAlertDialogReceive = (data = {}) => {
      const has = (key) => Object.prototype.hasOwnProperty.call(data, key);
      if (has("open")) changeOpen(data.open);
      if (has("titleHtml")) setTitleHtml(data.titleHtml || "");
      if (has("descriptionHtml")) setDescriptionHtml(data.descriptionHtml || "");
      if (has("confirmLabel")) setConfirmLabel(data.confirmLabel || "Continue");
      if (has("cancelLabel")) setCancelLabel(data.cancelLabel || "Cancel");
      if (has("confirmVariant")) setConfirmVariant(data.confirmVariant || "default");
      if (has("size")) setSize(data.size || "default");
      if (has("class")) setContentClass(data.class || "");
      if (has("style")) setContentStyle(data.style || {});
    };
    return () => delete root.__sbAlertDialogReceive;
  }, [root]);

  useEffect(() => {
    if (!open) return undefined;
    const previousOverflow = document.body.style.overflow;
    document.body.style.overflow = "hidden";
    (cancelRef.current || contentRef.current)?.focus({ preventScroll: true });

    function onKeyDown(event) {
      if (event.key === "Escape") {
        event.preventDefault();
        event.stopPropagation();
        choose("cancel");
        return;
      }
      if (event.key !== "Tab") return;
      const items = focusableChildren(contentRef.current);
      if (!items.length) {
        event.preventDefault();
        contentRef.current?.focus();
        return;
      }
      const first = items[0];
      const last = items[items.length - 1];
      if (event.shiftKey && document.activeElement === first) {
        event.preventDefault();
        last.focus();
      } else if (!event.shiftKey && document.activeElement === last) {
        event.preventDefault();
        first.focus();
      }
    }
    document.addEventListener("keydown", onKeyDown);
    return () => {
      document.removeEventListener("keydown", onKeyDown);
      document.body.style.overflow = previousOverflow;
      const target = returnFocusRef.current;
      returnFocusRef.current = null;
      if (target?.focus) requestAnimationFrame(() => target.focus({ preventScroll: true }));
    };
  }, [open]);

  return (
    <>
      {props.triggerLabel && (
        <button
          type="button"
          className="sb-button sb-button-default sb-button-size-default"
          data-slot="alert-dialog-trigger"
          aria-haspopup="dialog"
          aria-expanded={open ? "true" : "false"}
          onClick={() => changeOpen(true)}
        >
          {props.triggerLabel}
        </button>
      )}
      {open && createPortal(
        <div data-slot="alert-dialog" data-sb-alert-dialog-open="true">
          <div className="sb-dialog-overlay" data-slot="alert-dialog-overlay" />
          <div
            ref={contentRef}
            role="alertdialog"
            aria-modal="true"
            aria-labelledby={titleId}
            aria-describedby={descriptionHtml ? descriptionId : undefined}
            tabIndex={-1}
            className={classNames(
              "sb-dialog-content",
              "sb-alert-dialog-content",
              `sb-dialog-content-size-${size}`,
              contentClass
            )}
            style={contentStyle}
            data-slot="alert-dialog-content"
            data-size={size}
          >
            <div className="sb-dialog-header" data-slot="alert-dialog-header">
              <HtmlSlot html={titleHtml} id={titleId} className="sb-dialog-title" />
              {descriptionHtml && (
                <HtmlSlot html={descriptionHtml} id={descriptionId} className="sb-dialog-description" />
              )}
            </div>
            {props.bodyHtml && (
              <HtmlSlot as="div" html={props.bodyHtml} className="sb-dialog-body" data-slot="alert-dialog-body" />
            )}
            <div className="sb-dialog-footer" data-slot="alert-dialog-footer">
              <button
                ref={cancelRef}
                type="button"
                className="sb-button sb-button-outline sb-button-size-default"
                data-slot="alert-dialog-cancel"
                onClick={() => choose("cancel")}
              >
                {cancelLabel}
              </button>
              <button
                type="button"
                className={`sb-button sb-button-${confirmVariant} sb-button-size-default`}
                data-slot="alert-dialog-action"
                onClick={() => choose("confirm")}
              >
                {confirmLabel}
              </button>
            </div>
          </div>
        </div>,
        ensurePortalRoot()
      )}
    </>
  );
}
