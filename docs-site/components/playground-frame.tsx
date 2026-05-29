"use client";

import { useTheme } from "next-themes";
import { type CSSProperties, useCallback, useEffect, useRef } from "react";

interface PlaygroundFrameProps {
  src: string;
  title: string;
  className?: string;
  style?: CSSProperties;
  loading?: "eager" | "lazy";
}

interface ShinyblocksWindow extends Window {
  shinyblocksTheme?: { apply?: (mode: string) => void };
}

export function PlaygroundFrame({
  src,
  title,
  className,
  style,
  loading = "lazy",
}: PlaygroundFrameProps) {
  const frameRef = useRef<HTMLIFrameElement>(null);
  const { resolvedTheme } = useTheme();
  const theme = resolvedTheme === "dark" ? "dark" : "light";

  // Shinylive runs the Shiny app in a nested (same-origin) frame, so the host
  // cannot just set data-theme on the outer iframe. Walk every reachable frame
  // and (a) call the package's own theme API and (b) set data-theme directly.
  // The package exposes `window.shinyblocksTheme.apply`, so this works with the
  // already-deployed runtime without depending on an in-app postMessage bridge.
  // Returns true once at least one shinyblocks app has been reached.
  const pushTheme = useCallback(() => {
    const root = frameRef.current?.contentWindow;
    if (!root) return false;

    let applied = false;
    const visit = (win: Window) => {
      const sb = win as ShinyblocksWindow;
      try {
        if (typeof sb.shinyblocksTheme?.apply === "function") {
          sb.shinyblocksTheme.apply(theme);
          applied = true;
        }
      } catch {
        // Cross-origin frame: skip.
      }
      try {
        const doc = win.document;
        doc.documentElement.setAttribute("data-theme", theme);
        doc.documentElement.style.colorScheme = theme;
      } catch {
        // Cross-origin frame: skip.
      }
      let children: Window[] = [];
      try {
        for (let i = 0; i < win.frames.length; i += 1) children.push(win.frames[i]);
      } catch {
        children = [];
      }
      children.forEach(visit);
    };

    visit(root);
    return applied;
  }, [theme]);

  useEffect(() => {
    pushTheme();
    // The app boots asynchronously (webR/WASM); retry until it is reachable,
    // then stop so the playground's own controls keep working between toggles.
    let tries = 0;
    const timer = window.setInterval(() => {
      tries += 1;
      if (pushTheme() || tries > 25) {
        window.clearInterval(timer);
      }
    }, 700);
    return () => window.clearInterval(timer);
  }, [pushTheme]);

  return (
    <iframe
      ref={frameRef}
      src={src}
      title={title}
      loading={loading}
      className={className}
      style={style}
      onLoad={() => pushTheme()}
    />
  );
}
