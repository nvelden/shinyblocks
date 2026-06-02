# Built-in visual style profiles.
#
# A style profile is a curated pack of visual-feel tokens (control sizing,
# spacing, shadows, focus/disabled treatment, motion) emitted as `--sb-*`
# custom properties. This is separate from `block_theme()`, which owns
# semantic *colour* tokens. See ADR 0021.
#
# The `default` profile's values live in the runtime stylesheet
# (`frontend/src/styles/runtime.css`) as the `--sb-*` defaults, so its built-in
# override list here is empty: selecting `default` changes nothing unless the
# caller supplies explicit overrides.
#
# Each non-default profile lists only the curated shared `--sb-*` tokens that
# differ from the default. block_page() emits those as a scoped <style> and also
# stamps `data-sb-style="<profile>"` on `.sb-app`, which activates the
# profile-scoped component CSS in the stylesheets for differences that cannot be
# expressed by a shared token (radii, pill geometry, slider/switch metrics).
#
# `luma` mirrors official upstream Radix Luma
# (apps/v4/registry/styles/style-luma.css). The shared tokens below capture
# Luma's tighter control padding/gap, flat (shadow-less) controls, heavier card
# elevation (shadow-md), wider dialog gap, lighter overlay shadow (shadow-lg),
# and softer 30% focus ring. Luma's larger radii are now expressed as the
# per-component `*_radius` tokens (the default runtime CSS reads each from a
# `--sb-<component>-radius` custom property with a fallback to its historical
# value), so the only remaining `[data-sb-style="luma"]` CSS is the
# genuinely-structural geometry (pill/translucent surfaces, slider/switch
# metrics). See docs/research/2026-06-01-upstream-luma-comparison.md.
style_profiles <- list(
  default = list(),
  luma = list(
    control_padding_x = "0.75rem",
    control_gap = "0.375rem",
    control_shadow = "none",
    surface_shadow = "0 4px 6px -1px rgb(0 0 0 / 0.1), 0 2px 4px -2px rgb(0 0 0 / 0.1)",
    overlay_gap = "1.5rem",
    overlay_shadow = "0 10px 15px -3px rgb(0 0 0 / 0.1), 0 4px 6px -4px rgb(0 0 0 / 0.1)",
    focus_ring_opacity = "30%",
    # Radii (data, not CSS). Tailwind equivalents: 4xl = 2rem, 3xl = 1.5rem,
    # 2xl = 1rem, xl = 0.75rem, [5px] = 5px, code frame = 1.25rem.
    card_radius = "2rem",
    value_box_radius = "2rem",
    button_radius = "2rem",
    badge_radius = "1.5rem",
    input_radius = "1.5rem",
    textarea_radius = "1rem",
    select_radius = "1.5rem",
    select_content_radius = "1.5rem",
    select_item_radius = "1rem",
    checkbox_radius = "5px",
    alert_radius = "1rem",
    empty_radius = "1rem",
    skeleton_radius = "1rem",
    code_radius = "1.25rem",
    dialog_radius = "2rem",
    popover_radius = "1.5rem",
    tooltip_radius = "0.75rem",
    # Translucent-surface recipe: flat, borderless controls on a color-mixed
    # `--input` surface. Inputs/select use a 50% mix; the small toggles use 90%.
    input_surface = "color-mix(in oklch, var(--input) 50%, transparent)",
    input_border = "transparent",
    input_shadow = "none",
    textarea_surface = "color-mix(in oklch, var(--input) 50%, transparent)",
    textarea_border = "transparent",
    textarea_shadow = "none",
    select_surface = "color-mix(in oklch, var(--input) 50%, transparent)",
    select_border = "transparent",
    checkbox_surface = "color-mix(in oklch, var(--input) 90%, transparent)",
    checkbox_border = "transparent",
    checkbox_shadow = "none",
    switch_surface = "color-mix(in oklch, var(--input) 90%, transparent)",
    switch_shadow = "none",
    radio_surface = "color-mix(in oklch, var(--input) 90%, transparent)",
    radio_border = "transparent",
    radio_shadow = "none",
    slider_track_surface = "color-mix(in oklch, var(--input) 90%, transparent)",
    # Foreground-ring recipe: transparent border, base elevation plus a 1px
    # foreground ring (5% light). Card's stronger dark-mode ring stays in CSS.
    card_border = "transparent",
    card_shadow = "var(--sb-surface-shadow), 0 0 0 1px color-mix(in oklch, var(--foreground) 5%, transparent)",
    value_box_border = "transparent",
    value_box_shadow = "0 4px 6px -1px rgb(0 0 0 / 0.1), 0 2px 4px -2px rgb(0 0 0 / 0.1), 0 0 0 1px color-mix(in oklch, var(--foreground) 5%, transparent)",
    select_content_border = "transparent",
    select_content_shadow = "var(--sb-overlay-shadow), 0 0 0 1px color-mix(in oklch, var(--foreground) 5%, transparent)",
    dialog_border = "transparent",
    dialog_shadow = "0 20px 25px -5px rgb(0 0 0 / 0.1), 0 8px 10px -6px rgb(0 0 0 / 0.1), 0 0 0 1px color-mix(in oklch, var(--foreground) 5%, transparent)",
    popover_border = "transparent",
    popover_shadow = "var(--sb-overlay-shadow), 0 0 0 1px color-mix(in oklch, var(--foreground) 5%, transparent)"
  )
)

style_profile_names <- function() {
  names(style_profiles)
}

# Two token tiers (ADR 0021).
#
# `style_token_map()` is the small, curated PUBLIC allowlist: ergonomic
# snake_case names a caller may pass to `block_style(...)`. Raw CSS-variable
# names are deliberately not a public API, so internal CSS stays free to evolve.
#
# `style_internal_token_map()` is the finer per-component geometry vocabulary
# (radii, surfaces, borders, shadows) that *profiles* set as data but callers
# cannot pass via `...`. Keeping these internal lets a profile express component
# geometry as data (collapsing bespoke `[data-sb-style]` CSS) without enlarging
# the stable public surface. block_style() emits both tiers; `...` validates
# against the public tier only.
style_token_map <- function() {
  c(
    font_body = "sb-font-body",
    font_heading = "sb-font-heading",
    font_mono = "sb-font-mono",
    control_font_size = "sb-control-font-size",
    control_font_weight = "sb-control-font-weight",
    control_height = "sb-control-height",
    control_height_sm = "sb-control-height-sm",
    control_height_lg = "sb-control-height-lg",
    control_padding_x = "sb-control-padding-x",
    control_gap = "sb-control-gap",
    surface_padding = "sb-surface-padding",
    surface_gap = "sb-surface-gap",
    overlay_padding = "sb-overlay-padding",
    overlay_gap = "sb-overlay-gap",
    control_shadow = "sb-control-shadow",
    surface_shadow = "sb-surface-shadow",
    overlay_shadow = "sb-overlay-shadow",
    focus_ring_width = "sb-focus-ring-width",
    focus_ring_opacity = "sb-focus-ring-opacity",
    disabled_opacity = "sb-disabled-opacity",
    transition_duration = "sb-transition-duration"
  )
}

# Internal per-component geometry tokens. Set by profiles (style_profiles), not
# accepted from `block_style(...)`. The default runtime CSS reads each as
# `var(--sb-<token>, <historical default>)` so an unset token is a no-op.
style_internal_token_map <- function() {
  c(
    # Per-component radii.
    card_radius = "sb-card-radius",
    value_box_radius = "sb-value-box-radius",
    button_radius = "sb-button-radius",
    badge_radius = "sb-badge-radius",
    input_radius = "sb-input-radius",
    textarea_radius = "sb-textarea-radius",
    select_radius = "sb-select-radius",
    select_content_radius = "sb-select-content-radius",
    select_item_radius = "sb-select-item-radius",
    checkbox_radius = "sb-checkbox-radius",
    alert_radius = "sb-alert-radius",
    empty_radius = "sb-empty-radius",
    skeleton_radius = "sb-skeleton-radius",
    code_radius = "sb-code-radius",
    dialog_radius = "sb-dialog-radius",
    popover_radius = "sb-popover-radius",
    tooltip_radius = "sb-tooltip-radius",
    # Translucent-surface recipe (border + background + shadow per control).
    input_surface = "sb-input-surface",
    input_border = "sb-input-border",
    input_shadow = "sb-input-shadow",
    textarea_surface = "sb-textarea-surface",
    textarea_border = "sb-textarea-border",
    textarea_shadow = "sb-textarea-shadow",
    select_surface = "sb-select-surface",
    select_border = "sb-select-border",
    checkbox_surface = "sb-checkbox-surface",
    checkbox_border = "sb-checkbox-border",
    checkbox_shadow = "sb-checkbox-shadow",
    switch_surface = "sb-switch-surface",
    switch_shadow = "sb-switch-shadow",
    radio_surface = "sb-radio-surface",
    radio_border = "sb-radio-border",
    radio_shadow = "sb-radio-shadow",
    slider_track_surface = "sb-slider-track-surface",
    # Foreground-ring recipe (border + composed shadow per surface).
    card_border = "sb-card-border",
    card_shadow = "sb-card-shadow",
    value_box_border = "sb-value-box-border",
    value_box_shadow = "sb-value-box-shadow",
    select_content_border = "sb-select-content-border",
    select_content_shadow = "sb-select-content-shadow",
    dialog_border = "sb-dialog-border",
    dialog_shadow = "sb-dialog-shadow",
    popover_border = "sb-popover-border",
    popover_shadow = "sb-popover-shadow"
  )
}

# All tokens block_style() may emit: public allowlist plus internal geometry.
style_emit_token_map <- function() {
  c(style_token_map(), style_internal_token_map())
}

# Public override names accepted by `block_style(...)`. Internal geometry tokens
# are intentionally excluded.
style_override_names <- function() {
  names(style_token_map())
}

validate_style_profile <- function(profile) {
  if (!is.character(profile) || length(profile) != 1 || !nzchar(profile)) {
    stop("`profile` must be a single supported style-profile name.", call. = FALSE)
  }
  if (!profile %in% style_profile_names()) {
    stop(
      sprintf(
        "Unknown style profile `%s`. Supported profiles: %s.",
        profile,
        paste(sprintf("`%s`", style_profile_names()), collapse = ", ")
      ),
      call. = FALSE
    )
  }
  profile
}

style_profile <- function(profile) {
  style_profiles[[validate_style_profile(profile)]]
}
