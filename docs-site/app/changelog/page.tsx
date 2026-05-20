import * as fs from "fs";
import * as path from "path";
import Link from "next/link";

export default function ChangelogPage() {
  const changelogHtmlPath = path.join(process.cwd(), "content/changelog.html");
  const tocPath = path.join(process.cwd(), "lib/changelog-toc.json");

  let htmlContent = "";
  let toc: { title: string; slug: string }[] = [];

  try {
    htmlContent = fs.readFileSync(changelogHtmlPath, "utf-8");
    toc = JSON.parse(fs.readFileSync(tocPath, "utf-8"));
  } catch (error) {
    console.error("Failed to load changelog or TOC files:", error);
  }

  return (
    <div className="mx-auto w-full max-w-screen-2xl px-6 py-12">
      <div className="flex flex-col lg:flex-row gap-12">
        
        {/* Main Content Area */}
        <main className="flex-1 min-w-0 max-w-4xl">
          <div className="flex flex-col gap-4 mb-10 border-b border-border/60 pb-8">
            <h1 className="text-4xl font-extrabold tracking-tight text-foreground">Changelog</h1>
            <p className="text-muted-foreground text-lg">
              Stay up to date with the latest additions, fixes, and architectural developments in shinyblocks.
            </p>
          </div>

          <article 
            className="prose dark:prose-invert max-w-none text-foreground leading-relaxed
              [&>h2]:scroll-m-20 [&>h2]:text-2xl [&>h2]:font-bold [&>h2]:tracking-tight [&>h2]:mt-12 [&>h2]:mb-6 [&>h2]:border-b [&>h2]:pb-2 [&>h2]:text-foreground
              [&>ul]:list-disc [&>ul]:pl-6 [&>ul]:my-4 [&>ul]:space-y-3
              [&>ul>li]:text-muted-foreground [&>ul>li]:text-sm
              [&_code]:font-mono [&_code]:text-xs [&_code]:bg-muted [&_code]:px-1.5 [&_code]:py-0.5 [&_code]:rounded-md [&_code]:text-foreground/90"
            dangerouslySetInnerHTML={{ __html: htmlContent }}
          />
        </main>

        {/* Right Sidebar - TOC (Desktop only) */}
        <aside className="hidden xl:block w-64 shrink-0">
          <div className="sticky top-20 flex flex-col gap-4 pl-6 border-l border-border/60">
            <h3 className="font-semibold text-xs uppercase tracking-wider text-muted-foreground">On this page</h3>
            <nav className="flex flex-col gap-2.5">
              {toc.map((item) => (
                <Link
                  key={item.slug}
                  href={`/changelog#${item.slug}`}
                  className="text-sm font-medium text-muted-foreground hover:text-foreground transition-colors"
                >
                  {item.title}
                </Link>
              ))}
            </nav>
          </div>
        </aside>

      </div>
    </div>
  );
}
