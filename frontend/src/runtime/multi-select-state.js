export function toMultiSelected(value) {
  if (value == null) return [];
  const values = Array.isArray(value) ? value : [value];
  return values.map(String).filter((item) => item.length > 0);
}

export function orderSelectedByChoices(choices, selected) {
  const wanted = selected instanceof Set ? selected : new Set(toMultiSelected(selected));
  return choices.map((choice) => choice.value).filter((value) => wanted.has(value));
}

export function clampSelected(values, maxItems) {
  return maxItems != null && values.length > maxItems
    ? values.slice(0, maxItems)
    : values;
}

export function reconcileMultiSelection(choices, selected, maxItems) {
  return clampSelected(orderSelectedByChoices(choices, selected), maxItems);
}
