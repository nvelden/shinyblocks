import { useEffect, useState } from "react";
import { classNames, HtmlSlot, Icon, passthroughAttrs } from "./shared.jsx";

export function Button({ payload, root }) {
  const initialProps = payload.props || {};
  const attrs = passthroughAttrs(initialProps.attrs);

  const [labelHtml, setLabelHtml] = useState(initialProps.labelHtml || "");
  const [variant, setVariant] = useState(initialProps.variant || "default");
  const [size, setSize] = useState(initialProps.size || "default");
  const [iconName, setIconName] = useState(initialProps.iconName || null);
  const [iconHtml, setIconHtml] = useState(initialProps.iconHtml || null);
  const [iconPosition, setIconPosition] = useState(initialProps.iconPosition || "inline-start");
  const [spriteHref, setSpriteHref] = useState(initialProps.spriteHref || "");
  const [disabled, setDisabled] = useState(Boolean(initialProps.disabled));
  const [style, setStyle] = useState(initialProps.style || {});
  const [className, setClassName] = useState(payload.className || "");

  useEffect(() => {
    if (!root) return undefined;

    root.__sbButtonReceive = (data) => {
      const nextData = data || {};

      if (Object.prototype.hasOwnProperty.call(nextData, "labelHtml")) {
        setLabelHtml(nextData.labelHtml == null ? "" : String(nextData.labelHtml));
      }
      if (Object.prototype.hasOwnProperty.call(nextData, "variant")) {
        setVariant(nextData.variant || "default");
      }
      if (Object.prototype.hasOwnProperty.call(nextData, "size")) {
        setSize(nextData.size || "default");
      }
      if (Object.prototype.hasOwnProperty.call(nextData, "iconPosition")) {
        setIconPosition(nextData.iconPosition || "inline-start");
      }
      if (Object.prototype.hasOwnProperty.call(nextData, "iconName")) {
        setIconName(nextData.iconName == null ? null : String(nextData.iconName));
      }
      if (Object.prototype.hasOwnProperty.call(nextData, "iconHtml")) {
        setIconHtml(nextData.iconHtml == null ? null : String(nextData.iconHtml));
      }
      if (Object.prototype.hasOwnProperty.call(nextData, "spriteHref")) {
        setSpriteHref(nextData.spriteHref || "");
      }
      if (Object.prototype.hasOwnProperty.call(nextData, "disabled")) {
        setDisabled(Boolean(nextData.disabled));
      }
      if (Object.prototype.hasOwnProperty.call(nextData, "style")) {
        setStyle(nextData.style == null ? {} : nextData.style);
      }
      if (Object.prototype.hasOwnProperty.call(nextData, "class")) {
        setClassName(nextData.class == null ? "" : String(nextData.class));
      }
    };

    return () => {
      delete root.__sbButtonReceive;
    };
  }, [root]);

  const iconPayload = {
    props: { iconName, iconHtml, spriteHref, iconPosition }
  };

  return (
    <button
      type="button"
      data-slot="button"
      data-variant={variant}
      data-size={size}
      className={classNames(
        "sb-button",
        `sb-button-${variant}`,
        `sb-button-size-${size}`,
        className
      )}
      disabled={disabled}
      style={style}
      {...attrs}
    >
      {iconPosition === "inline-start" && <Icon payload={iconPayload} />}
      <HtmlSlot html={labelHtml} />
      {iconPosition === "inline-end" && <Icon payload={iconPayload} />}
    </button>
  );
}
