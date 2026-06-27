// Shared calendar core for the date-picker family. Owns the pure ISO date
// math and a presentational month grid (nav + weekday headers + day buttons)
// with arrow-key navigation. The consuming component owns selection state,
// popover open/close, focus return, and the hidden native input; the calendar
// only renders a month and reports day activation / cancellation through
// `onSelect` / `onCancel`. `block_date_picker()` and `block_date_range_picker()`
// share this so the ~250 lines of grid logic are not forked.

// --- Pure date helpers (ISO `yyyy-mm-dd` <-> calendar math) -----------------

export const pad2 = (n) => String(n).padStart(2, "0");

// Parse an ISO `yyyy-mm-dd` string into a {y, m, d} record (m is 1-indexed).
// Returns null for empty/invalid input so callers can represent "no value".
export function parseIso(value) {
  if (typeof value !== "string") return null;
  const match = /^(\d{4})-(\d{2})-(\d{2})$/.exec(value.trim());
  if (!match) return null;
  const y = Number(match[1]);
  const m = Number(match[2]);
  const d = Number(match[3]);
  if (m < 1 || m > 12 || d < 1 || d > 31) return null;
  return { y, m, d };
}

export function toIso(y, m, d) {
  return `${String(y).padStart(4, "0")}-${pad2(m)}-${pad2(d)}`;
}

export function daysInMonth(year, month0) {
  return new Date(year, month0 + 1, 0).getDate();
}

// Shift an ISO date by `delta` days using local Date arithmetic.
export function addDays(iso, delta) {
  const parts = parseIso(iso);
  if (!parts) return iso;
  const date = new Date(parts.y, parts.m - 1, parts.d + delta);
  return toIso(date.getFullYear(), date.getMonth() + 1, date.getDate());
}

export function todayIso() {
  const now = new Date();
  return toIso(now.getFullYear(), now.getMonth() + 1, now.getDate());
}

// Shiny `dateInput()` display tokens. Case-sensitive; the regex lists every
// token longest-first so multi-char tokens win over their single-char prefixes
// (`yyyy` over `yy`, `dd` over `d`, `mm` over `m`). `mm`/`MM` and `dd`/`DD`
// differ only by case. Single-char `d`/`m` are unpadded; `yy` is the 2-digit
// year.
export function formatLabel(iso, format) {
  const parts = parseIso(iso);
  if (!parts) return "";
  const date = new Date(parts.y, parts.m - 1, parts.d);
  const intl = (opts) => new Intl.DateTimeFormat(undefined, opts).format(date);
  const yyyy = String(parts.y).padStart(4, "0");
  const tokens = {
    yyyy,
    yy: yyyy.slice(-2),
    MM: intl({ month: "long" }),
    mm: pad2(parts.m),
    m: String(parts.m),
    DD: intl({ weekday: "long" }),
    dd: pad2(parts.d),
    d: String(parts.d),
    M: intl({ month: "short" }),
    D: intl({ weekday: "short" })
  };
  return String(format || "yyyy-mm-dd").replace(
    /yyyy|yy|MM|mm|DD|dd|M|D|m|d/g,
    (token) => tokens[token]
  );
}

// Header labels (Su, Mo, …) rotated to the configured first day of week.
export function weekdayLabels(weekstart) {
  const labels = [];
  // 2024-01-07 is a Sunday; walk forward from it for stable short names.
  for (let i = 0; i < 7; i += 1) {
    const date = new Date(2024, 0, 7 + ((weekstart + i) % 7));
    labels.push(new Intl.DateTimeFormat(undefined, { weekday: "short" }).format(date));
  }
  return labels;
}

// Presentational month grid shared by the single- and range-date pickers.
//
// Props:
// - classPrefix / slotPrefix: namespace the emitted class names and `data-slot`
//   attributes so each picker keeps its own stable CSS hooks
//   (`sb-date-picker-*` vs `sb-date-range-picker-*`). Single-date output stays
//   byte-identical to the pre-refactor markup.
// - view / setView: the displayed `{ y, m }` month (m is 0-indexed).
// - weekstart / spriteHref: presentation config.
// - focused / setFocused: the ISO day that owns the grid's roving tabindex.
// - dayRefs: a ref whose `.current` map the consumer reads to focus day nodes.
// - isDisabledDay(iso): bounds predicate.
// - onSelect(iso): commit a day (click / Enter / Space).
// - onCancel(event): Escape while the grid is focused.
// - getDayProps(iso): extra attributes/handlers spread onto each day button
//   (selection + today markers for single, plus range markers / hover for
//   range). Click and focus handlers stay owned by the calendar.
export function Calendar({
  classPrefix = "sb-date-picker",
  slotPrefix = "date-picker",
  view,
  setView,
  weekstart,
  spriteHref,
  focused,
  setFocused,
  dayRefs,
  isDisabledDay,
  onSelect,
  onCancel,
  getDayProps
}) {
  function moveFocus(nextIso) {
    if (!nextIso) return;
    const parts = parseIso(nextIso);
    if (!parts) return;
    setFocused(nextIso);
    setView({ y: parts.y, m: parts.m - 1 });
  }

  function onGridKeyDown(event) {
    // `focused` is normally a validated ISO date, but runtime bindings and
    // server messages are external inputs, so a malformed value must not crash
    // keyboard handling. Arrow keys lean on `addDays` (which no-ops on invalid
    // input); the month/week branches need the parsed parts, so bail if absent.
    const activeIso = document.activeElement?.dataset?.sbCalendarDate || focused;
    const cur = parseIso(activeIso);
    let next = null;
    if (event.key === "ArrowLeft") next = addDays(activeIso, -1);
    else if (event.key === "ArrowRight") next = addDays(activeIso, 1);
    else if (event.key === "ArrowUp") next = addDays(activeIso, -7);
    else if (event.key === "ArrowDown") next = addDays(activeIso, 7);
    else if (event.key === "Home") {
      if (!cur) return;
      // Jump to the first day of the focused row: subtract the offset of the
      // focused weekday from the configured week start (not day-of-month % 7).
      const weekday = new Date(cur.y, cur.m - 1, cur.d).getDay();
      next = addDays(activeIso, -(((weekday - weekstart) % 7 + 7) % 7));
    } else if (event.key === "PageUp") {
      if (!cur) return;
      const date = new Date(cur.y, cur.m - 2, cur.d);
      next = toIso(date.getFullYear(), date.getMonth() + 1, date.getDate());
    } else if (event.key === "PageDown") {
      if (!cur) return;
      const date = new Date(cur.y, cur.m, cur.d);
      next = toIso(date.getFullYear(), date.getMonth() + 1, date.getDate());
    } else if (event.key === "Enter" || event.key === " ") {
      event.preventDefault();
      onSelect(activeIso);
      return;
    } else if (event.key === "Escape") {
      onCancel(event);
      return;
    } else {
      return;
    }
    event.preventDefault();
    moveFocus(next);
  }

  function shiftMonth(delta) {
    const date = new Date(view.y, view.m + delta, 1);
    setView({ y: date.getFullYear(), m: date.getMonth() });
  }

  const headers = weekdayLabels(weekstart);
  const monthLabel = new Intl.DateTimeFormat(undefined, {
    month: "long",
    year: "numeric"
  }).format(new Date(view.y, view.m, 1));

  const firstWeekday = new Date(view.y, view.m, 1).getDay();
  const offset = (firstWeekday - weekstart + 7) % 7;
  const total = daysInMonth(view.y, view.m);
  const cells = [];
  for (let i = 0; i < offset; i += 1) cells.push(null);
  for (let day = 1; day <= total; day += 1) cells.push(day);
  // Pad the trailing partial week so every `role="row"` holds exactly 7 cells.
  while (cells.length % 7 !== 0) cells.push(null);
  const weeks = [];
  for (let i = 0; i < cells.length; i += 7) weeks.push(cells.slice(i, i + 7));

  return (
    <div className={`${classPrefix}-calendar`} data-slot={`${slotPrefix}-calendar`}>
      <div className={`${classPrefix}-nav`}>
        <button
          type="button"
          className={`${classPrefix}-nav-btn`}
          aria-label="Previous month"
          onClick={() => shiftMonth(-1)}
        >
          <svg aria-hidden="true" focusable="false">
            <use href={`${spriteHref}#sb-icon-chevron-left`} />
          </svg>
        </button>
        <span className={`${classPrefix}-month`} aria-live="polite">{monthLabel}</span>
        <button
          type="button"
          className={`${classPrefix}-nav-btn`}
          aria-label="Next month"
          onClick={() => shiftMonth(1)}
        >
          <svg aria-hidden="true" focusable="false">
            <use href={`${spriteHref}#sb-icon-chevron-right`} />
          </svg>
        </button>
      </div>
      <div className={`${classPrefix}-grid`} role="grid" onKeyDown={onGridKeyDown}>
        <div className={`${classPrefix}-weekdays`} role="row">
          {headers.map((label, index) => (
            <span key={index} className={`${classPrefix}-weekday`} role="columnheader">
              {label}
            </span>
          ))}
        </div>
        <div className={`${classPrefix}-days`}>
          {/* Each week is a `role="row"` for a well-formed ARIA grid. The
              wrapper uses `display: contents` (see the picker CSS) so the day
              buttons still participate in the parent grid's column layout. */}
          {weeks.map((week, weekIndex) => (
            <div key={`week-${weekIndex}`} className={`${classPrefix}-week`} role="row">
              {week.map((day, index) => {
                if (day == null) {
                  return (
                    <span
                      key={`pad-${weekIndex}-${index}`}
                      className={`${classPrefix}-pad`}
                      role="gridcell"
                    />
                  );
                }
                const iso = toIso(view.y, view.m + 1, day);
                const dayDisabled = isDisabledDay(iso);
                const isFocusable = iso === focused;
                const extra = getDayProps ? getDayProps(iso) : {};
                return (
                  <button
                    key={iso}
                    ref={(node) => {
                      if (node) dayRefs.current[iso] = node;
                      else delete dayRefs.current[iso];
                    }}
                    type="button"
                    className={`${classPrefix}-day`}
                    data-slot={`${slotPrefix}-day`}
                    data-sb-calendar-date={iso}
                    role="gridcell"
                    tabIndex={isFocusable ? 0 : -1}
                    disabled={dayDisabled}
                    {...extra}
                    onClick={() => onSelect(iso)}
                    onFocus={() => setFocused(iso)}
                  >
                    {day}
                  </button>
                );
              })}
            </div>
          ))}
        </div>
      </div>
    </div>
  );
}
