import type { Metadata } from "next";
import { GeistSans } from "geist/font/sans";
import { GeistMono } from "geist/font/mono";
import { ThemeProvider } from "@/components/theme-provider";
import { SiteHeader } from "@/components/site-header";
import { SiteFooter } from "@/components/site-footer";
import Script from "next/script";
import { getRuntimeAssets } from "@/lib/runtime-assets";
import { SITE_URL, SITE_DESCRIPTION } from "@/lib/site";
import "./globals.css";

// Absolute URLs throughout: basePath + metadataBase resolution is easy to
// get subtly wrong on a GitHub Pages project site, and scrapers need exact
// URLs. og.png is a committed static asset (see scripts/generate-og-image.mjs).
const OG_IMAGE = {
  url: `${SITE_URL}/og.png`,
  width: 1200,
  height: 630,
  alt: "shinyblocks — shadcn-inspired Shiny components",
};

export const metadata: Metadata = {
  metadataBase: new URL(SITE_URL),
  title: {
    default: "shinyblocks — shadcn-inspired Shiny components",
    template: "%s — shinyblocks",
  },
  description: SITE_DESCRIPTION,
  openGraph: {
    title: "shinyblocks — shadcn-inspired Shiny components",
    description: SITE_DESCRIPTION,
    url: `${SITE_URL}/`,
    siteName: "shinyblocks",
    locale: "en_US",
    type: "website",
    images: [OG_IMAGE],
  },
  twitter: {
    card: "summary_large_image",
    title: "shinyblocks — shadcn-inspired Shiny components",
    description: SITE_DESCRIPTION,
    images: [OG_IMAGE.url],
  },
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
