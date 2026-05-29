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

export function PlaygroundFrame({
  src,
  title,
  className,
  style,
  loading = "lazy",
}: PlaygroundFrameProps) {
  const frameRef = useRef<HTMLIFrameElement>(null);
  // Embedded shinyblocks apps that announced readiness (incl. the nested
  // Shinylive `srcdoc` app frame, reached via postMessage).
  const appWindows = useRef<Set<Window>>(new Set());
  const { resolvedTheme } = useTheme();
  const theme = resolvedTheme === "dark" ? "dark" : "light";

  // Fallback for non-Shinylive embeds: set data-theme on the iframe document
  // directly. (Shinylive runs the Shiny app in a nested srcdoc iframe that this
  // cannot reach, which is why the postMessage bridge below is the primary path.)
  const applyTheme = useCallback(() => {
    let doc: Document | null | undefined;
    try {
      doc = frameRef.current?.contentDocument;
    } catch {
      return;
    }
    if (!doc) return;

    doc.documentElement.setAttribute("data-theme", theme);
    doc.documentElement.style.colorScheme = theme;
    doc.body?.setAttribute("data-theme", theme);
  }, [theme]);

  useEffect(() => {
    const post = (w: Window) => {
      try {
        w.postMessage({ type: "shinyblocks:set-theme", mode: theme }, "*");
      } catch {
        // Ignore frames we cannot reach.
      }
    };

    const onMessage = (event: MessageEvent) => {
      if (event.data?.type === "shinyblocks:ready" && event.source) {
        const win = event.source as Window;
        appWindows.current.add(win);
        post(win);
      }
    };

    window.addEventListener("message", onMessage);
    // Re-push the current theme to apps that already announced themselves.
    appWindows.current.forEach(post);
    applyTheme();

    return () => window.removeEventListener("message", onMessage);
  }, [theme, applyTheme]);

  return (
    <iframe
      ref={frameRef}
      src={src}
      title={title}
      loading={loading}
      className={className}
      style={style}
      onLoad={applyTheme}
    />
  );
}
