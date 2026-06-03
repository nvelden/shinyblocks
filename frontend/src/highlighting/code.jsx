import React from "react";

export function highlightCodeLine(line, language) {
  if (!line) return " ";

  const lang = String(language || "").toLowerCase();
  if (["js", "jsx", "ts", "tsx", "javascript", "typescript"].includes(lang)) {
    return highlightTokens(
      line,
      /("(?:\\.|[^"\\])*"|'(?:\\.|[^'\\])*'|`(?:\\.|[^`\\])*`|<\/?[A-Z][A-Za-z0-9.]*(?=[\s>/])|[A-Za-z_$][\w$]*(?=\s*\()|\b(?:import|from|export|function|return|const|let|var|if|else)\b|[{}()[\];,=<>/])/g,
      classifyJsToken
    );
  }

  if (["py", "python"].includes(lang)) {
    return highlightTokens(
      line,
      /(#.*$|"(?:\\.|[^"\\])*"|'(?:\\.|[^'\\])*'|\b\d+(?:\.\d+)?\b|[A-Za-z_]\w*(?=\s*\()|\b(?:and|as|class|def|elif|else|except|False|finally|for|from|if|import|in|is|lambda|None|not|or|pass|raise|return|True|try|while|with|yield)\b|[{}()[\]:,=<>.+*/-])/g,
      classifyPythonToken
    );
  }

  if (["r", "rscript"].includes(lang)) {
    return highlightTokens(
      line,
      /(#.*$|"(?:\\.|[^"\\])*"|'(?:\\.|[^'\\])*'|\b\d+(?:\.\d+)?\b|[A-Za-z.]\w*(?=\s*\()|\b(?:function|if|else|for|while|repeat|in|next|break|TRUE|FALSE|NULL|NA|NaN|Inf)\b|<-|->|::|[{}()[\],=<>+$*/~-])/g,
      classifyRToken
    );
  }

  if (["html", "xml", "svg"].includes(lang)) {
    return highlightTokens(
      line,
      /(<!--[\s\S]*?-->|<!--[\s\S]*$|"(?:\\.|[^"\\])*"|'(?:\\.|[^'\\])*'|<\/?[A-Za-z][\w:-]*|\/?>|[A-Za-z_:][\w:.-]*(?=\s*=))/g,
      classifyHtmlToken
    );
  }

  if (["css", "scss", "less"].includes(lang)) {
    return highlightTokens(
      line,
      /(\/\*[\s\S]*?\*\/|\/\*[\s\S]*$|"(?:\\.|[^"\\])*"|'(?:\\.|[^'\\])*'|[.#][A-Za-z][\w-]*|@[A-Za-z-]+|--[\w-]+|[A-Za-z-]+(?=\s*:)|\b\d+(?:\.\d+)?(?:px|rem|em|%|vh|vw|fr|s|ms|deg|pt)?\b|[{}();:,])/g,
      classifyCssToken
    );
  }

  if (["json", "json5", "jsonc"].includes(lang)) {
    return highlightTokens(
      line,
      /("(?:\\.|[^"\\])*"|-?\b\d+(?:\.\d+)?(?:[eE][+-]?\d+)?\b|\b(?:true|false|null)\b|[{}[\]:,])/g,
      classifyJsonToken
    );
  }

  if (["sql", "mysql", "postgres", "postgresql", "sqlite"].includes(lang)) {
    return highlightTokens(
      line,
      /(--.*$|"(?:\\.|[^"\\])*"|'(?:\\.|[^'\\])*'|\b\d+(?:\.\d+)?\b|\b(?:SELECT|FROM|WHERE|ORDER|BY|GROUP|HAVING|LIMIT|OFFSET|INSERT|INTO|VALUES|UPDATE|SET|DELETE|CREATE|TABLE|ALTER|ADD|DROP|JOIN|LEFT|RIGHT|INNER|OUTER|FULL|CROSS|ON|USING|AS|AND|OR|NOT|NULL|IS|IN|EXISTS|LIKE|BETWEEN|DISTINCT|UNION|ALL|CASE|WHEN|THEN|ELSE|END|ASC|DESC|TRUE|FALSE|PRIMARY|FOREIGN|KEY|REFERENCES|DEFAULT|UNIQUE|INDEX|VIEW|WITH|RETURNING)\b|[A-Za-z_]\w*(?=\s*\()|[(),.;*=<>+-])/gi,
      classifySqlToken
    );
  }

  if (["bash", "sh", "shell", "zsh"].includes(lang)) {
    return highlightTokens(
      line,
      /(#.*$|"(?:\\.|[^"\\])*"|'(?:\\.|[^'\\])*'|\$\{?[A-Za-z_][\w]*\}?|\b(?:if|then|else|elif|fi|for|in|do|done|while|until|case|esac|function|return|echo|cd|export|local|read|exit|source|set|unset|alias)\b|--?[A-Za-z][\w-]*|\b\d+\b|[{}()[\];|&<>=])/g,
      classifyBashToken
    );
  }

  return line;
}

function highlightTokens(line, pattern, classifyToken) {
  const nodes = [];
  let cursor = 0;
  let match;
  let key = 0;

  while ((match = pattern.exec(line)) !== null) {
    if (match.index > cursor) {
      nodes.push(line.slice(cursor, match.index));
    }

    const token = match[0];
    const tokenClass = classifyToken(token, line.slice(pattern.lastIndex));
    nodes.push(
      tokenClass ? (
        <span key={`token-${key++}`} className={tokenClass}>
          {token}
        </span>
      ) : token
    );
    cursor = pattern.lastIndex;
  }

  if (cursor < line.length) {
    nodes.push(line.slice(cursor));
  }

  return nodes.length ? nodes : line;
}

function classifyJsToken(token) {
  if (/^["'`]/.test(token)) {
    return "sb-code-token-string";
  }
  if (/^<\/?[A-Z]/.test(token)) {
    return "sb-code-token-tag";
  }
  if (/^(import|from|export|function|return|const|let|var|if|else)$/.test(token)) {
    return "sb-code-token-keyword";
  }
  if (/^[A-Za-z_$]/.test(token)) {
    return "sb-code-token-function";
  }
  if (/^[{}()[\];,=<>/]$/.test(token)) {
    return "sb-code-token-punctuation";
  }
  return null;
}

function classifyPythonToken(token) {
  if (token.startsWith("#")) {
    return "sb-code-token-comment";
  }
  if (/^["']/.test(token)) {
    return "sb-code-token-string";
  }
  if (/^\d/.test(token)) {
    return "sb-code-token-number";
  }
  if (/^(and|as|class|def|elif|else|except|False|finally|for|from|if|import|in|is|lambda|None|not|or|pass|raise|return|True|try|while|with|yield)$/.test(token)) {
    return "sb-code-token-keyword";
  }
  if (/^[A-Za-z_]/.test(token)) {
    return "sb-code-token-function";
  }
  return "sb-code-token-punctuation";
}

function classifyRToken(token) {
  if (token.startsWith("#")) {
    return "sb-code-token-comment";
  }
  if (/^["']/.test(token)) {
    return "sb-code-token-string";
  }
  if (/^\d/.test(token)) {
    return "sb-code-token-number";
  }
  if (/^(function|if|else|for|while|repeat|in|next|break|TRUE|FALSE|NULL|NA|NaN|Inf)$/.test(token)) {
    return "sb-code-token-keyword";
  }
  if (/^[A-Za-z.]/.test(token)) {
    return "sb-code-token-function";
  }
  return "sb-code-token-punctuation";
}

function classifyHtmlToken(token) {
  if (token.startsWith("<!--")) {
    return "sb-code-token-comment";
  }
  if (/^["']/.test(token)) {
    return "sb-code-token-string";
  }
  if (/^<\/?[A-Za-z]/.test(token) || /^\/?>$/.test(token)) {
    return "sb-code-token-tag";
  }
  return "sb-code-token-function";
}

function classifyCssToken(token) {
  if (token.startsWith("/*")) {
    return "sb-code-token-comment";
  }
  if (/^["']/.test(token)) {
    return "sb-code-token-string";
  }
  if (/^[.#@]/.test(token)) {
    return "sb-code-token-tag";
  }
  if (/^--[\w-]+$/.test(token)) {
    return "sb-code-token-function";
  }
  if (/^\d/.test(token)) {
    return "sb-code-token-number";
  }
  if (/^[{}();:,]$/.test(token)) {
    return "sb-code-token-punctuation";
  }
  return "sb-code-token-keyword";
}

function classifyJsonToken(token, rest) {
  if (/^["']/.test(token)) {
    return /^\s*:/.test(rest || "")
      ? "sb-code-token-tag"
      : "sb-code-token-string";
  }
  if (/^-?\d/.test(token)) {
    return "sb-code-token-number";
  }
  if (/^(true|false|null)$/.test(token)) {
    return "sb-code-token-keyword";
  }
  return "sb-code-token-punctuation";
}

const SQL_KEYWORDS = /^(SELECT|FROM|WHERE|ORDER|BY|GROUP|HAVING|LIMIT|OFFSET|INSERT|INTO|VALUES|UPDATE|SET|DELETE|CREATE|TABLE|ALTER|ADD|DROP|JOIN|LEFT|RIGHT|INNER|OUTER|FULL|CROSS|ON|USING|AS|AND|OR|NOT|NULL|IS|IN|EXISTS|LIKE|BETWEEN|DISTINCT|UNION|ALL|CASE|WHEN|THEN|ELSE|END|ASC|DESC|TRUE|FALSE|PRIMARY|FOREIGN|KEY|REFERENCES|DEFAULT|UNIQUE|INDEX|VIEW|WITH|RETURNING)$/i;

function classifySqlToken(token) {
  if (token.startsWith("--")) {
    return "sb-code-token-comment";
  }
  if (/^["']/.test(token)) {
    return "sb-code-token-string";
  }
  if (/^\d/.test(token)) {
    return "sb-code-token-number";
  }
  if (SQL_KEYWORDS.test(token)) {
    return "sb-code-token-keyword";
  }
  if (/^[A-Za-z_]\w*$/.test(token)) {
    return "sb-code-token-function";
  }
  return "sb-code-token-punctuation";
}

const BASH_KEYWORDS = /^(if|then|else|elif|fi|for|in|do|done|while|until|case|esac|function|return|echo|cd|export|local|read|exit|source|set|unset|alias)$/;

function classifyBashToken(token) {
  if (token.startsWith("#")) {
    return "sb-code-token-comment";
  }
  if (/^["']/.test(token)) {
    return "sb-code-token-string";
  }
  if (token.startsWith("$")) {
    return "sb-code-token-function";
  }
  if (BASH_KEYWORDS.test(token)) {
    return "sb-code-token-keyword";
  }
  if (/^--?[A-Za-z]/.test(token)) {
    return "sb-code-token-number";
  }
  if (/^\d/.test(token)) {
    return "sb-code-token-number";
  }
  return "sb-code-token-punctuation";
}
