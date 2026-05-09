render_example <- function(path) {
  code <- readLines(path, warn = FALSE)
  rendered <- eval(parse(text = code), envir = new.env(parent = globalenv()))
  list(rendered = rendered, code = paste(code, collapse = "\n"))
}
