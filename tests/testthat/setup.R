# Shared test setup. testthat 3 self-sufficient style.
# Loaded once before any test file. Keep minimal; per-test setup
# uses withr.

# testthat sets reproducible language output itself. In local shells
# with LC_ALL pinned, withr warns that the language override cannot
# take effect; clearing LC_ALL keeps the suite warning-free.
if (nzchar(Sys.getenv("LC_ALL"))) {
  Sys.unsetenv("LC_ALL")
}

# Make package internals available without prefixing in test code.
# Helpers like merge_classes() and validate_children() live in
# R/utils.R; this lets tests assert on their behavior directly.
local_internal <- function() {
  asNamespace("shinyblocks")
}

# Render a tag to a single-string HTML chunk for assertion convenience.
# Trailing newlines are stripped so snapshot diffs stay quiet.
render_html <- function(tag) {
  out <- as.character(htmltools::renderTags(tag)$html)
  sub("\\s+$", "", paste(out, collapse = ""))
}

# Look up an attribute on a tag, returning NULL if absent.
tag_attr <- function(tag, name) {
  if (inherits(tag, "shiny.tag")) tag$attribs[[name]] else NULL
}

runtime_payload_from <- function(tag) {
  html <- render_html(tag)
  match <- regexpr(
    '<script type="application/json" data-shinyblocks-payload="">(.*?)</script>',
    html,
    perl = TRUE
  )
  stopifnot(match > 0)
  script <- regmatches(html, match)
  json <- sub(
    '^<script type="application/json" data-shinyblocks-payload="">(.*)</script>$',
    "\\1",
    script
  )
  jsonlite::fromJSON(json, simplifyVector = FALSE)
}

local_input_message_session <- function(ns = identity) {
  messages <- list()
  session <- list(
    ns = ns,
    sendInputMessage = function(input_id, payload) {
      messages[[length(messages) + 1L]] <<- list(
        input_id = input_id,
        payload = payload
      )
    }
  )

  list(
    session = session,
    messages = function() messages,
    last_message = function() {
      if (!length(messages)) {
        stop("No input messages were captured.", call. = FALSE)
      }
      messages[[length(messages)]]
    },
    last_payload = function() {
      if (!length(messages)) {
        stop("No input messages were captured.", call. = FALSE)
      }
      messages[[length(messages)]]$payload
    }
  )
}

local_custom_message_session <- function() {
  messages <- list()
  session <- list(
    sendCustomMessage = function(type, payload) {
      messages[[length(messages) + 1L]] <<- list(
        type = type,
        payload = payload
      )
    }
  )

  list(
    session = session,
    messages = function() messages,
    last_message = function() {
      if (!length(messages)) {
        stop("No custom messages were captured.", call. = FALSE)
      }
      messages[[length(messages)]]
    }
  )
}
