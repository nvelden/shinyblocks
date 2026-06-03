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

export function HtmlSlot({ html, className, ...attrs }) {
  if (!html) return null;
  return (
    <span
      className={className}
      dangerouslySetInnerHTML={{ __html: html }}
      {...attrs}
    />
  );
}

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
