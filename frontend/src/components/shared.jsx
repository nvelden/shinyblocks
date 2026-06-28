import { forwardRef, useCallback, useLayoutEffect, useRef } from "react";
import { bindShinyChildren, unbindShinyChildren } from "../runtime/shiny.js";

function htmlMayContainShinyBinding(html) {
  return /(<input\b|<select\b|<textarea\b|shiny-|action-button|html-widget-output|data-for=)/i.test(
    html || ""
  );
}

export function classNames(...values) {
  return values
    .flatMap((value) => String(value || "").split(/\s+/))
    .filter(Boolean)
    .filter((value, index, all) => all.indexOf(value) === index)
    .join(" ");
}

export function passthroughAttrs(attrs) {
  const normalized = Object.fromEntries(
    Object.entries(attrs || {}).filter(([, value]) => value !== false && value !== null)
  );

  if (Object.prototype.hasOwnProperty.call(normalized, "style")) {
    if (
      typeof normalized.style !== "object" ||
      Array.isArray(normalized.style)
    ) {
      throw new Error("shinyblocks runtime style attrs must be objects.");
    }
  }

  return normalized;
}

export const HtmlSlot = forwardRef(function HtmlSlot(
  { html, className, as: Tag = "span", ...attrs },
  forwardedRef
) {
  const ref = useRef(null);
  const setRef = useCallback(
    (node) => {
      ref.current = node;
      if (typeof forwardedRef === "function") {
        forwardedRef(node);
      } else if (forwardedRef) {
        forwardedRef.current = node;
      }
    },
    [forwardedRef]
  );

  useLayoutEffect(() => {
    const node = ref.current;
    if (!node || !htmlMayContainShinyBinding(html)) return undefined;
    // Capture the node at bind time: `ref.current` is mutable across renders and
    // may be null or a different element by the time cleanup runs, which would
    // unbind the wrong subtree (or nothing).
    bindShinyChildren(node);
    return () => unbindShinyChildren(node);
  }, [html]);

  if (!html) return null;
  return (
    <Tag
      ref={setRef}
      className={className}
      dangerouslySetInnerHTML={{ __html: html }}
      {...attrs}
    />
  );
});

export function Icon({ payload }) {
  const props = payload.props || {};
  const position = props.iconPosition || "inline-start";

  if (props.iconHtml) {
    return (
      <HtmlSlot
        html={props.iconHtml}
        data-icon={position}
      />
    );
  }

  if (!props.iconName) return null;

  return (
    <svg
      aria-hidden="true"
      focusable="false"
      data-icon={position}
    >
      <use href={`${props.spriteHref}#sb-icon-${props.iconName}`} />
    </svg>
  );
}
