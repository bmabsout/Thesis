// The thesis's look, from the shared design system (bmabsout/typst-design).
// This file only binds the names the chapters use.
#import "@local/typst-design:0.1.0" as design
#import design: ramps, ref-ramp, hues, font-options, seamless-block, swatch, callouts, thesis-colors, thesis-style, heading-style, thesis-rule, local-outline

#let primary_hue = hues.maroon
#let accent1_hue = 140deg
#let accent2_hue = 200deg
#let accent3_hue = -60deg
#let accent4_hue = hues.amber
#let ref_hue = -20deg

#let main_gradient = ramps.maroon
#let accent1_gradient = ramps.blue
#let accent2_gradient = ramps.rose
#let accent3_gradient = ramps.teal
#let accent4_gradient = ramps.amber
#let accent5_gradient = ramps.orange
#let ref_gradient = ref-ramp

// The thesis in its colors. Set to "bu" for Boston University's black
// headings and plain front matter.
#let compliance = none
#let colors = thesis-colors(compliance: compliance)
#let primary_gradient = colors.primary

#let font_options = font-options
#let default_style(colors: colors) = thesis-style(colors: colors)
#let heading_style = heading-style
#let long_line = thesis-rule(default_style())
#let local_outline(style: none) = local-outline()
#let manual_sampler = swatch

#let diamond = design.diamond

// #let changed(content) = highlight(content, fill: accent1_gradient.sample(80%))
#let changed(content) = content

// The callouts as the dissertation was set (the original page-spanning
// block and its tones); titles at 1.2 × the default body size (12.4pt).
#let _callouts = callouts(title-size: font-options.libertinus_serif.size * 1.2, classic: true)
#let note = _callouts.note
#let theorem = _callouts.theorem
#let algorithm = _callouts.algorithm
#let notice = _callouts.notice
