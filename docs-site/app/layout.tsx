import type { Metadata } from "next";
import { GeistSans } from "geist/font/sans";
import { GeistMono } from "geist/font/mono";
import { ThemeProvider } from "@/components/theme-provider";
import { SiteHeader } from "@/components/site-header";
import { SiteFooter } from "@/components/site-footer";
import Script from "next/script";
import { getRuntimeAssets } from "@/lib/runtime-assets";
import "./globals.css";

export const metadata: Metadata = {
  title: "shinyblocks — shadcn-inspired Shiny components",
  description:
    "A set of beautifully designed shadcn-inspired components for Shiny. Pure R. Open source.",
};

export default function RootLayout({
  children,
}: {
  children: React.ReactNode;
}) {
  const assets = getRuntimeAssets();

  return (
    <html
      lang="en"
      suppressHydrationWarning
      className={`${GeistSans.variable} ${GeistMono.variable}`}
    >
      <head>
        <link rel="stylesheet" href="/shinyblocks/runtime/shinyblocks.css" />
        {assets.css && <link rel="stylesheet" href={assets.css} />}
      </head>
      <body className="min-h-screen bg-background font-sans text-foreground antialiased">
        <ThemeProvider>
          <div className="flex min-h-screen flex-col">
            <SiteHeader />
            <main className="flex-1">{children}</main>
            <SiteFooter />
          </div>
        </ThemeProvider>
        {assets.js && (
          <Script 
            src={assets.js} 
            strategy="afterInteractive" 
          />
        )}
        {assets.vanillaJs && (
          <Script 
            src={assets.vanillaJs} 
            strategy="afterInteractive" 
          />
        )}
      </body>
    </html>
  );
}
