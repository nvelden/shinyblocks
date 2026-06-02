# Vendored from the official shadcn/create base-color registry:
# https://github.com/shadcn-ui/ui/tree/main/apps/v4/public/r/colors
#
# Keep these as package-owned R data. End users do not load JSON at runtime.
theme_preset_scales <- list(
  neutral = c(
    `50` = "oklch(0.985 0 0)", `100` = "oklch(0.97 0 0)",
    `200` = "oklch(0.922 0 0)", `300` = "oklch(0.87 0 0)",
    `400` = "oklch(0.708 0 0)", `500` = "oklch(0.556 0 0)",
    `600` = "oklch(0.439 0 0)", `700` = "oklch(0.371 0 0)",
    `800` = "oklch(0.269 0 0)", `900` = "oklch(0.205 0 0)",
    `950` = "oklch(0.145 0 0)"
  ),
  stone = c(
    `50` = "oklch(0.985 0.001 106.423)", `100` = "oklch(0.97 0.001 106.424)",
    `200` = "oklch(0.923 0.003 48.717)", `300` = "oklch(0.869 0.005 56.366)",
    `400` = "oklch(0.709 0.01 56.259)", `500` = "oklch(0.553 0.013 58.071)",
    `600` = "oklch(0.444 0.011 73.639)", `700` = "oklch(0.374 0.01 67.558)",
    `800` = "oklch(0.268 0.007 34.298)", `900` = "oklch(0.216 0.006 56.043)",
    `950` = "oklch(0.147 0.004 49.25)"
  ),
  zinc = c(
    `50` = "oklch(0.985 0 0)", `100` = "oklch(0.967 0.001 286.375)",
    `200` = "oklch(0.92 0.004 286.32)", `300` = "oklch(0.871 0.006 286.286)",
    `400` = "oklch(0.705 0.015 286.067)", `500` = "oklch(0.552 0.016 285.938)",
    `600` = "oklch(0.442 0.017 285.786)", `700` = "oklch(0.37 0.013 285.805)",
    `800` = "oklch(0.274 0.006 286.033)", `900` = "oklch(0.21 0.006 285.885)",
    `950` = "oklch(0.141 0.005 285.823)"
  ),
  mauve = c(
    `50` = "oklch(0.985 0 0)", `100` = "oklch(0.96 0.003 325.6)",
    `200` = "oklch(0.922 0.005 325.62)", `300` = "oklch(0.865 0.012 325.68)",
    `400` = "oklch(0.711 0.019 323.02)", `500` = "oklch(0.542 0.034 322.5)",
    `600` = "oklch(0.435 0.029 321.78)", `700` = "oklch(0.364 0.029 323.89)",
    `800` = "oklch(0.263 0.024 320.12)", `900` = "oklch(0.212 0.019 322.12)",
    `950` = "oklch(0.145 0.008 326)"
  ),
  olive = c(
    `50` = "oklch(0.988 0.003 106.5)", `100` = "oklch(0.966 0.005 106.5)",
    `200` = "oklch(0.93 0.007 106.5)", `300` = "oklch(0.88 0.011 106.6)",
    `400` = "oklch(0.737 0.021 106.9)", `500` = "oklch(0.58 0.031 107.3)",
    `600` = "oklch(0.466 0.025 107.3)", `700` = "oklch(0.394 0.023 107.4)",
    `800` = "oklch(0.286 0.016 107.4)", `900` = "oklch(0.228 0.013 107.4)",
    `950` = "oklch(0.153 0.006 107.1)"
  ),
  mist = c(
    `50` = "oklch(0.987 0.002 197.1)", `100` = "oklch(0.963 0.002 197.1)",
    `200` = "oklch(0.925 0.005 214.3)", `300` = "oklch(0.872 0.007 219.6)",
    `400` = "oklch(0.723 0.014 214.4)", `500` = "oklch(0.56 0.021 213.5)",
    `600` = "oklch(0.45 0.017 213.2)", `700` = "oklch(0.378 0.015 216)",
    `800` = "oklch(0.275 0.011 216.9)", `900` = "oklch(0.218 0.008 223.9)",
    `950` = "oklch(0.148 0.004 228.8)"
  ),
  taupe = c(
    `50` = "oklch(0.986 0.002 67.8)", `100` = "oklch(0.96 0.002 17.2)",
    `200` = "oklch(0.922 0.005 34.3)", `300` = "oklch(0.868 0.007 39.5)",
    `400` = "oklch(0.714 0.014 41.2)", `500` = "oklch(0.547 0.021 43.1)",
    `600` = "oklch(0.438 0.017 39.3)", `700` = "oklch(0.367 0.016 35.7)",
    `800` = "oklch(0.268 0.011 36.5)", `900` = "oklch(0.214 0.009 43.1)",
    `950` = "oklch(0.147 0.004 49.3)"
  )
)

theme_preset_from_scale <- function(scale) {
  light <- c(
    background = "oklch(1 0 0)", foreground = scale[["950"]],
    card = "oklch(1 0 0)", `card-foreground` = scale[["950"]],
    popover = "oklch(1 0 0)", `popover-foreground` = scale[["950"]],
    primary = scale[["900"]], `primary-foreground` = scale[["50"]],
    secondary = scale[["100"]], `secondary-foreground` = scale[["900"]],
    muted = scale[["100"]], `muted-foreground` = scale[["500"]],
    accent = scale[["100"]], `accent-foreground` = scale[["900"]],
    destructive = "oklch(0.577 0.245 27.325)", border = scale[["200"]],
    input = scale[["200"]], ring = scale[["400"]],
    `chart-1` = scale[["300"]], `chart-2` = scale[["500"]],
    `chart-3` = scale[["600"]], `chart-4` = scale[["700"]],
    `chart-5` = scale[["800"]], sidebar = scale[["50"]],
    `sidebar-foreground` = scale[["950"]], `sidebar-primary` = scale[["900"]],
    `sidebar-primary-foreground` = scale[["50"]], `sidebar-accent` = scale[["100"]],
    `sidebar-accent-foreground` = scale[["900"]], `sidebar-border` = scale[["200"]],
    `sidebar-ring` = scale[["400"]]
  )
  dark <- c(
    background = scale[["950"]], foreground = scale[["50"]],
    card = scale[["900"]], `card-foreground` = scale[["50"]],
    popover = scale[["900"]], `popover-foreground` = scale[["50"]],
    primary = scale[["200"]], `primary-foreground` = scale[["900"]],
    secondary = scale[["800"]], `secondary-foreground` = scale[["50"]],
    muted = scale[["800"]], `muted-foreground` = scale[["400"]],
    accent = scale[["800"]], `accent-foreground` = scale[["50"]],
    destructive = "oklch(0.704 0.191 22.216)", border = "oklch(1 0 0 / 10%)",
    input = "oklch(1 0 0 / 15%)", ring = scale[["500"]],
    `chart-1` = scale[["300"]], `chart-2` = scale[["500"]],
    `chart-3` = scale[["600"]], `chart-4` = scale[["700"]],
    `chart-5` = scale[["800"]], sidebar = scale[["900"]],
    `sidebar-foreground` = scale[["50"]],
    `sidebar-primary` = "oklch(0.488 0.243 264.376)",
    `sidebar-primary-foreground` = scale[["50"]], `sidebar-accent` = scale[["800"]],
    `sidebar-accent-foreground` = scale[["50"]], `sidebar-border` = "oklch(1 0 0 / 10%)",
    `sidebar-ring` = scale[["500"]]
  )
  list(light = light, dark = dark)
}

theme_presets <- lapply(theme_preset_scales, theme_preset_from_scale)

theme_preset_names <- function() {
  names(theme_presets)
}

validate_theme_preset <- function(preset) {
  if (is.null(preset)) {
    return(NULL)
  }
  if (!is.character(preset) || length(preset) != 1 || !nzchar(preset)) {
    stop("`preset` must be NULL or one supported palette name.", call. = FALSE)
  }
  if (!preset %in% theme_preset_names()) {
    stop(
      sprintf(
        "Unknown theme preset `%s`. Supported presets: %s.",
        preset,
        paste(sprintf("`%s`", theme_preset_names()), collapse = ", ")
      ),
      call. = FALSE
    )
  }
  preset
}

theme_preset <- function(preset) {
  theme_presets[[validate_theme_preset(preset)]]
}

merge_theme_values <- function(base, overrides) {
  if (length(base) == 0) {
    return(overrides)
  }
  utils::modifyList(as.list(base), overrides)
}
