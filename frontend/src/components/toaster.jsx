import { useEffect, useRef, useState } from "react";
import { createPortal } from "react-dom";
import { ensurePortalRoot } from "../runtime/dom.js";
import { classNames, HtmlSlot } from "./shared.jsx";

let nextLocalId = 0;

// Server-driven toast region. The mounted element carries the Shiny input
// binding; `show_toast()` / `dismiss_toast()` arrive through `__sbToasterReceive`
// (single writer of toast state and the reported `input$<id>` value, per
// ADR 0019). React owns the stack, per-toast timers, and dismissal.
export function Toaster({ payload, root }) {
  const props = payload.props || {};
  const [position, setPosition] = useState(props.position || "bottom-right");
  const [toasts, setToasts] = useState([]);
  const timersRef = useRef(new Map());
  const seqRef = useRef(0);

  function clearTimer(id) {
    const handle = timersRef.current.get(id);
    if (handle) {
      clearTimeout(handle);
      timersRef.current.delete(id);
    }
  }

  function startTimer(toast) {
    clearTimer(toast.id);
    if (!toast.duration || toast.duration <= 0) return;
    // Auto-dismiss reports just like a manual dismiss so the server sees it.
    const handle = setTimeout(() => dismiss(toast.id, true), toast.duration);
    timersRef.current.set(toast.id, handle);
  }

  // `input$<id>` is event-shaped: `{ action, id, seq }`. The monotonic `seq`
  // guarantees the value changes on every show/dismiss — even when the same
  // toast id is dismissed twice — so the server reactive always fires.
  function reportValue(action, id, notify) {
    if (root) {
      seqRef.current += 1;
      root.__sbToasterValue = {
        action,
        id: id == null ? null : String(id),
        seq: seqRef.current
      };
    }
    if (notify !== false && root) {
      root.dispatchEvent(new CustomEvent("sb:toaster-change"));
    }
  }

  function dismiss(id, notify) {
    clearTimer(id);
    setToasts((prev) => prev.filter((toast) => toast.id !== id));
    reportValue("dismiss", id, notify);
  }

  useEffect(() => {
    if (!root) return undefined;
    if (typeof root.__sbToasterValue === "undefined") {
      root.__sbToasterValue = null;
    }

    root.__sbToasterReceive = (data) => {
      const next = data || {};

      if (next.action === "config") {
        if (Object.prototype.hasOwnProperty.call(next, "position")) {
          setPosition(next.position || "bottom-right");
        }
        return;
      }

      if (next.action === "dismiss") {
        if (next.toastId == null) {
          timersRef.current.forEach((handle) => clearTimeout(handle));
          timersRef.current.clear();
          setToasts([]);
          reportValue("dismiss", null, next.notify);
        } else {
          dismiss(String(next.toastId), next.notify);
        }
        return;
      }

      const incoming = next.toast;
      if (!incoming) return;

      const toast = {
        id: incoming.id != null ? String(incoming.id) : `sb-toast-${nextLocalId++}`,
        variant: incoming.variant || "default",
        titleHtml: incoming.titleHtml || "",
        descriptionHtml: incoming.descriptionHtml || "",
        iconHtml: incoming.iconHtml || "",
        duration: Number.isFinite(incoming.duration) ? incoming.duration : 5000,
        dismissible: incoming.dismissible !== false
      };

      setToasts((prev) => {
        const index = prev.findIndex((item) => item.id === toast.id);
        if (index === -1) return [...prev, toast];

        const nextToasts = [...prev];
        nextToasts[index] = toast;
        return nextToasts;
      });
      startTimer(toast);
      reportValue("show", toast.id, next.notify);
    };

    return () => {
      delete root.__sbToasterReceive;
      timersRef.current.forEach((handle) => clearTimeout(handle));
      timersRef.current.clear();
    };
  }, [root]);

  const portal = ensurePortalRoot(root);
  if (toasts.length === 0) return null;

  return createPortal(
    <div
      className={classNames("sb-toaster", `sb-toaster-${position}`, payload.className)}
      style={payload.style || undefined}
      data-slot="toaster"
      data-position={position}
      role="region"
      aria-label="Notifications"
    >
      {toasts.map((toast) => (
        <div
          key={toast.id}
          role={toast.variant === "destructive" ? "alert" : "status"}
          className={classNames("sb-toast", `sb-toast-${toast.variant}`)}
          data-slot="toast"
          data-variant={toast.variant}
          onMouseEnter={() => clearTimer(toast.id)}
          onMouseLeave={() => startTimer(toast)}
          onFocus={() => clearTimer(toast.id)}
          onBlur={() => startTimer(toast)}
          onKeyDown={(event) => {
            if (event.key === "Escape" && toast.dismissible) {
              event.stopPropagation();
              dismiss(toast.id, true);
            }
          }}
        >
          {toast.iconHtml && (
            <div className="sb-toast-icon">
              <HtmlSlot html={toast.iconHtml} />
            </div>
          )}
          <div className="sb-toast-content">
            {toast.titleHtml && (
              <HtmlSlot html={toast.titleHtml} className="sb-toast-title" />
            )}
            {toast.descriptionHtml && (
              <HtmlSlot
                html={toast.descriptionHtml}
                className="sb-toast-description"
              />
            )}
          </div>
          {toast.dismissible && (
            <button
              type="button"
              className="sb-toast-close"
              data-slot="toast-close"
              aria-label="Dismiss"
              onClick={() => dismiss(toast.id, true)}
            >
              ×
            </button>
          )}
        </div>
      ))}
    </div>,
    portal
  );
}
