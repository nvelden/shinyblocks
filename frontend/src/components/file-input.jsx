import { useEffect, useState } from "react";
import { labelIdForInput } from "../runtime/dom.js";
import { nativeFileInput } from "../runtime/native-inputs.js";
import { classNames } from "./shared.jsx";

function selectedFileText(nativeInput, placeholder) {
  const files = nativeInput?.files ? Array.from(nativeInput.files) : [];
  if (!files.length) return placeholder || "";
  if (files.length === 1) return files[0].name;
  return files.map((file) => file.name).join(", ");
}

export function FileInput({ payload, root }) {
  const props = payload.props || {};
  const [fileText, setFileText] = useState(props.placeholder || "");
  const disabled = Boolean(props.disabled);
  const invalid = Boolean(props.invalid);
  const style = props.style || {};
  const className = payload.className || "";
  const native = nativeFileInput(root);
  const inputId = native?.id || null;
  const labelledBy = inputId ? labelIdForInput(inputId) : null;
  const describedBy = root?.getAttribute("aria-describedby") || undefined;
  const wrapperInvalid = root?.getAttribute("aria-invalid") === "true";
  const isInvalid = invalid || wrapperInvalid;

  useEffect(() => {
    if (!root || !native) return undefined;

    native.disabled = disabled;
    const handleChange = () => {
      setFileText(selectedFileText(native, props.placeholder || ""));
    };
    native.addEventListener("change", handleChange);
    handleChange();

    return () => {
      native.removeEventListener("change", handleChange);
    };
  }, [root, native, disabled, props.placeholder]);

  function handleClick() {
    if (disabled || !native) return;
    native.click();
  }

  return (
    <div
      className={classNames("sb-file-input-control", className)}
      data-slot="file-input-control"
      data-disabled={disabled ? "true" : undefined}
      aria-invalid={isInvalid || undefined}
      style={style}
    >
      <button
        type="button"
        className="sb-file-input-button"
        data-slot="file-input-button"
        disabled={disabled}
        aria-controls={inputId || undefined}
        aria-labelledby={labelledBy || undefined}
        aria-describedby={describedBy}
        onClick={handleClick}
      >
        {props.buttonLabel || "Browse"}
      </button>
      <span
        className="sb-file-input-text"
        data-slot="file-input-text"
        data-placeholder={!native?.files?.length ? "true" : undefined}
        aria-live="polite"
      >
        {fileText || props.placeholder || ""}
      </span>
    </div>
  );
}
