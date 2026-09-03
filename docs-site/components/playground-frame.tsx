"use client";

import { useTheme } from "next-themes";
import {
  type CSSProperties,
  useCallback,
  useEffect,
  useRef,
  useState,
} from "react";

interface PlaygroundFrameProps {
  src: string;
  title: string;
  className?: string;
  style?: CSSProperties;
  loading?: "eager" | "lazy";
  showLoadingState?: boolean;
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
  showLoadingState = false,
}: PlaygroundFrameProps) {
  const frameRef = useRef<HTMLIFrameElement>(null);
  const [isReady, setIsReady] = useState(false);
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
    setIsReady(false);
    if (pushTheme()) setIsReady(true);
    // The app boots asynchronously (webR/WASM); retry until it is reachable,
    // then stop so the playground's own controls keep working between toggles.
    let tries = 0;
    const timer = window.setInterval(() => {
      tries += 1;
      if (pushTheme()) {
        setIsReady(true);
        window.clearInterval(timer);
      } else if (tries > 90) {
        window.clearInterval(timer);
      }
    }, 700);
    return () => window.clearInterval(timer);
  }, [pushTheme, src]);

  const frame = (
    <iframe
      ref={frameRef}
      src={src}
      title={title}
      loading={loading}
      className={className}
      style={style}
      onLoad={() => {
        if (pushTheme()) setIsReady(true);
      }}
    />
  );

  if (!showLoadingState) return frame;

  return (
    <div className="relative w-full" style={{ height: style?.height }}>
      {frame}
      {!isReady && (
        <div
          className="absolute inset-0 flex items-center justify-center bg-background px-6 text-center"
          role="status"
          aria-live="polite"
        >
          <div className="flex max-w-sm flex-col items-center gap-2 rounded-lg border border-border bg-card px-6 py-5 shadow-sm">
            <span className="text-sm font-semibold text-foreground">
              Starting the live R playground…
            </span>
            <span className="text-xs leading-relaxed text-muted-foreground">
              The first visit loads Shiny in your browser. No server required.
            </span>
          </div>
        </div>
      )}
    </div>
  );
}
