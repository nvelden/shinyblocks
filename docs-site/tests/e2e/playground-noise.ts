// Shared allowlist for console/page errors that come from the embedded
// Shinylive (webR/WASM) playgrounds rather than the Next.js docs chrome.
//
// The smoke tests assert "no console errors", but their documented scope is the
// site chrome — nav, theme, layout — NOT embedded page content. The gallery on
// the landing page runs a real Shiny app via webR, whose worker fails to
// initialise under headless WebKit ("PostMessageChannel" can't load). That is a
// known third-party WASM-runtime limitation outside our control, so we ignore
// only that narrow noise and keep every other error fatal.

/** A captured console message location (Playwright `ConsoleMessage.location()`). */
interface ConsoleLocation {
  url: string;
}

/** True when a console error originates from an embedded playground bundle. */
export function isPlaygroundConsoleNoise(location: ConsoleLocation): boolean {
  return location.url.includes("/playgrounds/");
}

/** True when an uncaught page error is the webR worker bootstrap failure. */
export function isPlaygroundPageError(message: string): boolean {
  return /webR/i.test(message);
}
