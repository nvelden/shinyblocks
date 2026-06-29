import { useEffect, useRef, useState } from "react";
import { labelIdForInput } from "../runtime/dom.js";
import { nativeSlider, normalizeSliderValue, setNativeSliderValue, sliderValueToNative } from "../runtime/native-inputs.js";
import { classNames } from "./shared.jsx";

export function Slider({ payload, root }) {
  const props = payload.props || {};
  const state = payload.state || {};
  const inputId = payload.id;
  const initialMin = Number(props.min);
  const initialMax = Number(props.max);
  const [min, setMin] = useState(Number.isFinite(initialMin) ? initialMin : 0);
  const [max, setMax] = useState(Number.isFinite(initialMax) ? initialMax : 100);
  const [step, setStep] = useState(Number(props.step) > 0 ? Number(props.step) : 1);
  const [disabled, setDisabled] = useState(Boolean(props.disabled));
  const [invalid, setInvalid] = useState(Boolean(props.invalid));
  const [style, setStyle] = useState(props.style || {});
  const [className, setClassName] = useState(payload.className || "");
  const [orientation, setOrientation] = useState(props.orientation === "vertical" ? "vertical" : "horizontal");
  const [showValue, setShowValue] = useState(Boolean(props.showValue));
  const [minLabel, setMinLabel] = useState(props.minLabel == null ? null : String(props.minLabel));
  const [maxLabel, setMaxLabel] = useState(props.maxLabel == null ? null : String(props.maxLabel));
  const rangeMode = Array.isArray(state.value) && state.value.length > 1;
  const [value, setValueState] = useState(
    normalizeSliderValue(rangeMode ? state.value.slice(0, 2) : state.value, min, max)
  );
  const labelledBy = inputId ? labelIdForInput(inputId) : null;
  const describedBy = root?.getAttribute("aria-describedby") || undefined;
  const wrapperInvalid = root?.getAttribute("aria-invalid") === "true";
  const isInvalid = invalid || wrapperInvalid;
  const trackRef = useRef(null);
  const activeThumbRef = useRef(0);
  const draggingRef = useRef(false);

  function valuesArray(nextValue = value) {
    return Array.isArray(nextValue) ? nextValue : [nextValue];
  }

  function percentFor(item) {
    if (max === min) return 0;
    return ((Number(item) - min) / (max - min)) * 100;
  }

  function quantize(raw, nextMin = min, nextMax = max, nextStep = step) {
    const usableStep = Number(nextStep) > 0 ? Number(nextStep) : 1;
    const clamped = Math.min(nextMax, Math.max(nextMin, Number(raw)));
    const snapped = Math.round((clamped - nextMin) / usableStep) * usableStep + nextMin;
    const precision = Math.max(0, String(usableStep).split(".")[1]?.length || 0);
    return Number(Math.min(nextMax, Math.max(nextMin, snapped)).toFixed(precision));
  }

  function normalized(nextValue, nextMin = min, nextMax = max, nextStep = step) {
    const next = normalizeSliderValue(nextValue, nextMin, nextMax);
    if (Array.isArray(next)) return next.map((item) => quantize(item, nextMin, nextMax, nextStep));
    return quantize(next, nextMin, nextMax, nextStep);
  }

  function commit(nextValue, notify = false) {
    const next = normalized(nextValue);
    setValueState(next);
    if (!root) return;
    root.__sbSliderValue = next;
    root.dataset.sbSliderValue = sliderValueToNative(next);
    setNativeSliderValue(root, next, notify);
    if (notify) root.dispatchEvent(new CustomEvent("sb:slider-change"));
  }

  function valueFromPointer(event) {
    const track = trackRef.current;
    if (!track) return min;
    const rect = track.getBoundingClientRect();
    const ratio = orientation === "vertical"
      ? (rect.height <= 0 ? 0 : 1 - (event.clientY - rect.top) / rect.height)
      : (rect.width <= 0 ? 0 : (event.clientX - rect.left) / rect.width);
    return quantize(min + Math.min(1, Math.max(0, ratio)) * (max - min));
  }

  function chooseThumb(nextValue) {
    const values = valuesArray();
    if (values.length < 2) return 0;
    return Math.abs(nextValue - values[0]) <= Math.abs(nextValue - values[1]) ? 0 : 1;
  }

  function updateThumb(index, nextValue, notify = true) {
    const values = valuesArray();
    if (values.length === 1) {
      commit(nextValue, notify);
      return;
    }
    const nextValues = values.slice(0, 2);
    nextValues[index] = nextValue;
    if (index === 0) nextValues[0] = Math.min(nextValues[0], nextValues[1]);
    if (index === 1) nextValues[1] = Math.max(nextValues[0], nextValues[1]);
    commit(nextValues, notify);
  }

  function setCurrentThumb(index) {
    activeThumbRef.current = index;
  }

  function handlePointerDown(event, thumbIndex = null) {
    if (disabled) return;
    event.preventDefault();
    const nextValue = valueFromPointer(event);
    const thumb = thumbIndex == null ? chooseThumb(nextValue) : thumbIndex;
    draggingRef.current = true;
    setCurrentThumb(thumb);
    updateThumb(thumb, nextValue, true);
    event.currentTarget.setPointerCapture?.(event.pointerId);
  }

  function handlePointerMove(event, thumbIndex = null) {
    if (disabled || !draggingRef.current) return;
    updateThumb(thumbIndex == null ? activeThumbRef.current : thumbIndex, valueFromPointer(event), true);
  }

  function handlePointerEnd(event) {
    draggingRef.current = false;
    event.currentTarget.releasePointerCapture?.(event.pointerId);
  }

  function handleKeyDown(event, index) {
    if (disabled) return;
    const values = valuesArray();
    const current = values[index] ?? values[0] ?? min;
    let next = null;

    if (event.key === "ArrowRight" || event.key === "ArrowUp") next = current + step;
    if (event.key === "ArrowLeft" || event.key === "ArrowDown") next = current - step;
    if (event.key === "PageUp") next = current + step * 10;
    if (event.key === "PageDown") next = current - step * 10;
    if (event.key === "Home") next = min;
    if (event.key === "End") next = max;
    if (next == null) return;

    event.preventDefault();
    setCurrentThumb(index);
    updateThumb(index, next, true);
  }

  useEffect(() => {
    if (root) {
      root.__sbSliderValue = value;
      root.dataset.sbSliderValue = sliderValueToNative(value);
      setNativeSliderValue(root, value, false);
    }
  }, [value, root]);

  useEffect(() => {
    if (!root) return undefined;

    root.__sbSliderReceive = (data) => {
      const nextData = data || {};
      let nextMin = min;
      let nextMax = max;
      let nextStep = step;

      if (Object.prototype.hasOwnProperty.call(nextData, "min")) {
        const parsedMin = Number(nextData.min);
        if (Number.isFinite(parsedMin)) {
          nextMin = parsedMin;
          setMin(parsedMin);
        }
      }
      if (Object.prototype.hasOwnProperty.call(nextData, "max")) {
        const parsedMax = Number(nextData.max);
        if (Number.isFinite(parsedMax)) {
          nextMax = parsedMax;
          setMax(parsedMax);
        }
      }
      if (Object.prototype.hasOwnProperty.call(nextData, "step")) {
        const parsedStep = Number(nextData.step);
        nextStep = parsedStep > 0 ? parsedStep : 1;
        setStep(nextStep);
      }
      if (Object.prototype.hasOwnProperty.call(nextData, "orientation")) {
        setOrientation(nextData.orientation === "vertical" ? "vertical" : "horizontal");
      }
      if (Object.prototype.hasOwnProperty.call(nextData, "showValue")) {
        setShowValue(Boolean(nextData.showValue));
      }
      if (Object.prototype.hasOwnProperty.call(nextData, "minLabel")) {
        setMinLabel(nextData.minLabel == null ? null : String(nextData.minLabel));
      }
      if (Object.prototype.hasOwnProperty.call(nextData, "maxLabel")) {
        setMaxLabel(nextData.maxLabel == null ? null : String(nextData.maxLabel));
      }
      if (Object.prototype.hasOwnProperty.call(nextData, "value")) {
        const nextValue = normalizeSliderValue(nextData.value, nextMin, nextMax);
        const next = Array.isArray(nextValue)
          ? nextValue.map((item) => quantize(item, nextMin, nextMax, nextStep))
          : quantize(nextValue, nextMin, nextMax, nextStep);
        setValueState(next);
        root.__sbSliderValue = next;
        root.dataset.sbSliderValue = sliderValueToNative(next);
        setNativeSliderValue(root, next, Boolean(nextData.notify));
        if (nextData.notify) {
          root.dispatchEvent(new CustomEvent("sb:slider-change"));
        }
      }
      if (Object.prototype.hasOwnProperty.call(nextData, "disabled")) {
        const nextDisabled = Boolean(nextData.disabled);
        setDisabled(nextDisabled);
        root.toggleAttribute("data-disabled", nextDisabled);
        const native = nativeSlider(root);
        if (native) native.disabled = nextDisabled;
      }
      if (Object.prototype.hasOwnProperty.call(nextData, "invalid")) {
        setInvalid(Boolean(nextData.invalid));
      }
      if (Object.prototype.hasOwnProperty.call(nextData, "class")) {
        setClassName(nextData.class || "");
      }
      if (Object.prototype.hasOwnProperty.call(nextData, "style")) {
        setStyle(nextData.style || {});
      }
    };

    return () => {
      delete root.__sbSliderReceive;
    };
  }, [max, min, root, step, value]);

  useEffect(() => {
    if (!root) return;
    root.toggleAttribute("data-disabled", disabled);
    const native = nativeSlider(root);
    if (native) native.disabled = disabled;
  }, [disabled, root]);

  const values = valuesArray();
  const lower = values.length > 1 ? values[0] : min;
  const upper = values.length > 1 ? values[1] : values[0];
  const left = Math.min(100, Math.max(0, percentFor(lower)));
  const right = Math.min(100, Math.max(0, percentFor(upper)));
  const isVertical = orientation === "vertical";
  const sliderStyle = isVertical
    ? {
        width: "1.5rem",
        minWidth: "1.5rem",
        height: "8rem",
        flexDirection: "column",
        alignItems: "center",
        ...style
      }
    : style;
  const trackStyle = isVertical
    ? { width: "0.375rem", height: "100%" }
    : undefined;
  const rangeStyle = isVertical
    ? { bottom: `${left}%`, height: `${Math.max(0, right - left)}%`, width: "100%" }
    : { left: `${left}%`, width: `${Math.max(0, right - left)}%` };
  const hasBounds = minLabel != null || maxLabel != null;
  const shellStyle = {
    display: "inline-flex",
    flexDirection: "column",
    alignItems: "center",
    gap: "0.5rem",
    width: isVertical ? "auto" : "100%"
  };
  const bodyStyle = {
    display: "inline-flex",
    flexDirection: isVertical ? "row" : "column",
    alignItems: isVertical ? "stretch" : "center",
    gap: "0.5rem",
    width: isVertical ? "auto" : "100%",
    // Reserve room for the floating value label so it never overlaps content
    // above (horizontal) or beside (vertical) the slider.
    paddingTop: showValue && !isVertical ? "1.25rem" : undefined,
    paddingRight: showValue && isVertical ? "2rem" : undefined
  };
  const labelStyle = {
    fontSize: "0.75rem",
    fontWeight: 500,
    lineHeight: 1,
    color: "var(--muted-foreground)"
  };
  function valueLabelStyle(item) {
    return isVertical
      ? {
          ...labelStyle,
          position: "absolute",
          bottom: `${percentFor(item)}%`,
          left: "100%",
          transform: "translateY(50%)",
          marginLeft: "0.5rem",
          whiteSpace: "nowrap",
          pointerEvents: "none"
        }
      : {
          ...labelStyle,
          position: "absolute",
          left: `${percentFor(item)}%`,
          bottom: "100%",
          transform: "translateX(-50%)",
          marginBottom: "0.4rem",
          whiteSpace: "nowrap",
          pointerEvents: "none"
        };
  }
  const boundsStyle = {
    ...labelStyle,
    display: "flex",
    flexDirection: isVertical ? "column" : "row",
    justifyContent: "space-between",
    alignItems: isVertical ? "flex-start" : "center",
    minHeight: isVertical ? "8rem" : undefined,
    width: isVertical ? "auto" : "100%"
  };

  return (
    <div className="sb-slider-shell" data-orientation={orientation} style={shellStyle}>
      <div className="sb-slider-body" style={bodyStyle}>
        <div
          className={classNames("sb-slider", className)}
          data-slot="slider"
          data-disabled={disabled ? "true" : undefined}
          data-invalid={isInvalid ? "true" : undefined}
          data-orientation={orientation}
          style={sliderStyle}
        >
          <div
            ref={trackRef}
            className="sb-slider-track"
            data-slot="slider-track"
            style={trackStyle}
            onPointerDown={handlePointerDown}
            onPointerMove={handlePointerMove}
            onPointerUp={handlePointerEnd}
            onPointerCancel={handlePointerEnd}
          >
            <div
              className="sb-slider-range"
              data-slot="slider-range"
              style={rangeStyle}
            />
          </div>
          {values.map((item, index) => (
            <button
              key={index}
              type="button"
              className="sb-slider-thumb"
              data-slot="slider-thumb"
              role="slider"
              aria-orientation={orientation}
              aria-valuemin={min}
              aria-valuemax={max}
              aria-valuenow={item}
              aria-labelledby={labelledBy || undefined}
              aria-describedby={describedBy}
              aria-invalid={isInvalid || undefined}
              disabled={disabled}
              style={isVertical
                ? { left: "50%", top: "auto", bottom: `${percentFor(item)}%`, transform: "translate(-50%, 50%)" }
                : { left: `${percentFor(item)}%` }}
              onPointerDown={(event) => handlePointerDown(event, index)}
              onPointerMove={(event) => handlePointerMove(event, index)}
              onPointerUp={handlePointerEnd}
              onPointerCancel={handlePointerEnd}
              onFocus={() => setCurrentThumb(index)}
              onKeyDown={(event) => handleKeyDown(event, index)}
            />
          ))}
          {showValue
            ? values.map((item, index) => (
                <div
                  key={`value-${index}`}
                  className="sb-slider-value"
                  style={valueLabelStyle(item)}
                >
                  {item}
                </div>
              ))
            : null}
        </div>
        {hasBounds ? (
          <div className="sb-slider-bounds" style={boundsStyle}>
            {isVertical ? (
              <>
                <span>{maxLabel == null ? "" : maxLabel}</span>
                <span>{minLabel == null ? "" : minLabel}</span>
              </>
            ) : (
              <>
                <span>{minLabel == null ? "" : minLabel}</span>
                <span>{maxLabel == null ? "" : maxLabel}</span>
              </>
            )}
          </div>
        ) : null}
      </div>
    </div>
  );
}
