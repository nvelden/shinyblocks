import { useCallback, useEffect, useRef, useState } from "react";
import { setNativePaginationValue } from "../runtime/native-inputs.js";
import { classNames } from "./shared.jsx";

function clampPage(value, pages) {
  const parsed = Math.trunc(Number(value));
  return Math.min(pages, Math.max(1, Number.isFinite(parsed) ? parsed : 1));
}

function pageItems(pages, selected, siblings, edges) {
  const visible = new Set();
  for (let page = selected - siblings; page <= selected + siblings; page += 1) {
    if (page >= 1 && page <= pages) visible.add(page);
  }
  if (edges) { visible.add(1); visible.add(pages); }
  const sorted = Array.from(visible).sort((a, b) => a - b);
  const items = [];
  sorted.forEach((page, index) => {
    if (index) {
      const previous = sorted[index - 1];
      if (page - previous === 2) items.push(previous + 1);
      else if (page - previous > 2) items.push(`ellipsis-${previous}-${page}`);
    }
    items.push(page);
  });
  return items;
}

function Icon({ name }) {
  if (name === "more") return <svg viewBox="0 0 24 24" aria-hidden="true"><circle cx="5" cy="12" r="1"/><circle cx="12" cy="12" r="1"/><circle cx="19" cy="12" r="1"/></svg>;
  return <svg viewBox="0 0 24 24" aria-hidden="true"><polyline points={name === "previous" ? "15 18 9 12 15 6" : "9 18 15 12 9 6"}/></svg>;
}

export function Pagination({ payload, root }) {
  const props = payload.props || {};
  const [pages, setPages] = useState(Math.max(1, Math.trunc(Number(props.pages)) || 1));
  const [selected, setSelected] = useState(clampPage(payload.state?.value, pages));
  const [disabled, setDisabled] = useState(Boolean(props.disabled));
  const [className, setClassName] = useState(payload.className || "");
  const pagesRef = useRef(pages);
  const selectedRef = useRef(selected);
  const siblings = Math.max(0, Math.trunc(Number(props.siblingCount)) || 0);
  const edges = props.showEdges !== false;

  const writeValue = useCallback((value) => {
    if (!root) return;
    root.__sbPaginationValue = value;
    root.dataset.sbPaginationValue = String(value);
    setNativePaginationValue(root, value);
  }, [root]);

  useEffect(() => {
    if (!root) return undefined;
    writeValue(selectedRef.current);
    root.__sbPaginationReceive = (data = {}) => {
      let nextPages = pagesRef.current;
      let next = selectedRef.current;
      if (Object.prototype.hasOwnProperty.call(data, "pages")) {
        nextPages = Math.max(1, Math.trunc(Number(data.pages)) || 1);
        pagesRef.current = nextPages;
        setPages(nextPages);
        next = clampPage(next, nextPages);
      }
      if (Object.prototype.hasOwnProperty.call(data, "selected")) next = clampPage(data.selected, nextPages);
      if (next !== selectedRef.current || Object.prototype.hasOwnProperty.call(data, "selected")) {
        selectedRef.current = next;
        setSelected(next); writeValue(next);
        if (data.notify) root.dispatchEvent(new CustomEvent("sb:pagination-change"));
      }
      if (Object.prototype.hasOwnProperty.call(data, "disabled")) setDisabled(Boolean(data.disabled));
      if (Object.prototype.hasOwnProperty.call(data, "class")) setClassName(data.class || "");
      if (Object.prototype.hasOwnProperty.call(data, "style")) {
        root.removeAttribute("style");
        Object.entries(data.style || {}).forEach(([property, value]) => root.style.setProperty(property, value));
      }
    };
    return () => { delete root.__sbPaginationReceive; };
  }, [root, writeValue]);

  function choose(value) {
    if (disabled || value === selected) return;
    const next = clampPage(value, pages);
    selectedRef.current = next;
    setSelected(next); writeValue(next);
    root?.dispatchEvent(new CustomEvent("sb:pagination-change"));
  }

  return <nav aria-label="pagination" className={classNames("sb-pagination-control", className)} data-disabled={disabled ? "true" : undefined}>
    <ul className="sb-pagination-content">
      <li><button type="button" className="sb-pagination-link sb-pagination-nav" aria-label="Go to previous page" disabled={disabled || selected === 1} onClick={() => choose(selected - 1)}><Icon name="previous"/><span>Previous</span></button></li>
      {pageItems(pages, selected, siblings, edges).map((item) => typeof item === "number" ?
        <li key={item}><button type="button" className="sb-pagination-link" aria-label={`Go to page ${item}`} aria-current={item === selected ? "page" : undefined} data-active={item === selected ? "true" : undefined} disabled={disabled} onClick={() => choose(item)}>{item}</button></li> :
        <li key={item}><span className="sb-pagination-ellipsis" aria-hidden="true"><Icon name="more"/><span className="sb-sr-only">More pages</span></span></li>)}
      <li><button type="button" className="sb-pagination-link sb-pagination-nav" aria-label="Go to next page" disabled={disabled || selected === pages} onClick={() => choose(selected + 1)}><span>Next</span><Icon name="next"/></button></li>
    </ul>
  </nav>;
}
