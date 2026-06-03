import { useEffect, useState } from "react";

const FOCUSABLE_SELECTOR = [
  "a[href]",
  "button:not([disabled])",
  "textarea:not([disabled])",
  "input:not([disabled]):not([type='hidden'])",
  "select:not([disabled])",
  "[tabindex]:not([tabindex='-1'])"
].join(",");

export function focusableChildren(container) {
  if (!container) return [];
  return Array.from(container.querySelectorAll(FOCUSABLE_SELECTOR)).filter(
    (el) => !el.hasAttribute("aria-hidden") && el.offsetParent !== null
  );
}

export function floatingTransform(side, align) {
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

export function useFloatingPosition({
  open,
  triggerRef,
  side,
  align,
  offset = 8
}) {
  const [position, setPosition] = useState(null);

  useEffect(() => {
    if (!open || !triggerRef.current) return undefined;

    function updatePosition() {
      const rect = triggerRef.current.getBoundingClientRect();
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
  }, [open, triggerRef, side, align, offset]);

  return position;
}
