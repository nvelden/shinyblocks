import * as fs from "fs";
import * as path from "path";
import { marked } from "marked";

function slugify(text: string): string {
  return text
    .toLowerCase()
    .replace(/[^\w\s-]/g, "")
    .replace(/[\s_]+/g, "-")
    .replace(/^-+|-+$/g, "");
}

function main() {
  const newsPath = path.join(__dirname, "../../NEWS.md");
  if (!fs.existsSync(newsPath)) {
    console.error("NEWS.md not found at path:", newsPath);
    process.exit(1);
  }

  let newsContent = fs.readFileSync(newsPath, "utf-8");

  const releaseHeadingPattern = /^(?:\d+\.\d+\.\d+(?:\.\d+)?|shinyblocks\b)/i;

  newsContent = newsContent
    .split("\n")
    .map((line) => {
      const h1 = line.match(/^#\s+(.+)$/);
      if (h1) {
        return `## ${h1[1].trim()}`;
      }

      const h2 = line.match(/^##\s+(.+)$/);
      if (h2 && !releaseHeadingPattern.test(h2[1].trim())) {
        return `### ${h2[1].trim()}`;
      }

      return line;
    })
    .join("\n");

  // Extract versions for TOC
  const toc: { title: string; slug: string }[] = [];
  const headingRegex = /^##\s+(.+)$/gm;
  let match;
  while ((match = headingRegex.exec(newsContent)) !== null) {
    const title = match[1].trim();
    toc.push({
      title,
      slug: slugify(title)
    });
  }

  // Set up custom renderer to inject id attribute to headings
  const renderer = new marked.Renderer();
  renderer.heading = function ({ tokens, depth }) {
    const text = this.parser.parseInline(tokens);
    const slug = slugify(text);
    if (depth === 2) {
      return `<h2 id="${slug}">${text}</h2>\n`;
    }
    if (depth === 3) {
      return `<h3 id="${slug}">${text}</h3>\n`;
    }
    return `<h${depth}>${text}</h${depth}>\n`;
  };

  marked.setOptions({ renderer });
  
  const parsedHtml = marked.parse(newsContent) as string;

  // Ensure output directories exist
  fs.mkdirSync(path.join(__dirname, "../content"), { recursive: true });
  fs.mkdirSync(path.join(__dirname, "../lib"), { recursive: true });

  fs.writeFileSync(path.join(__dirname, "../content/changelog.html"), parsedHtml);
  fs.writeFileSync(path.join(__dirname, "../lib/changelog-toc.json"), JSON.stringify(toc, null, 2));

  console.log("Successfully generated changelog HTML and TOC json!");
}

main();
