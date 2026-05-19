export function SiteFooter() {
  return (
    <footer className="border-t border-border py-8">
      <div className="mx-auto max-w-screen-2xl px-6 text-center text-sm text-muted-foreground">
        Built in R ·{" "}
        <a
          href="https://github.com/nvelden/shinyblocks"
          target="_blank"
          rel="noreferrer"
          className="underline-offset-4 hover:text-foreground hover:underline"
        >
          Source on GitHub
        </a>{" "}
        · MIT licensed
      </div>
    </footer>
  );
}
