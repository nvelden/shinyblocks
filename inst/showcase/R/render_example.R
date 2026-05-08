render_example <- function(path) {
  code <- readLines(path, warn = FALSE)
  env <- new.env(parent = globalenv())
  rendered <- eval(parse(text = code), envir = env)

  htmltools::tagList(
    rendered,
    htmltools::tags$pre(
      htmltools::tags$code(paste(code, collapse = "\n"))
    )
  )
}
