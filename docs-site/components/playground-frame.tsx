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
  const { resolvedTheme } = useTheme();
  const theme = resolvedTheme === "dark" ? "dark" : "light";

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
    applyTheme();
  }, [applyTheme]);

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
