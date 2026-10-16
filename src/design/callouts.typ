// CALLOUTS: the callouts as the dissertation was set. The callout family is
// the design system's, and this file gives it the dissertation's engine (a
// block whose bottom edge fades out) and its tones, so the thesis prints as
// it was submitted.

#import "@local/typst-design:0.1.0": callouts as _callouts

/// A titled block whose bottom edge fades out, so a callout that breaks
/// across a page reads as continuing. The title is kept with the content.
#let seamless-block(
  title: none,
  content,
  stroke: 1pt,
  fill: blue.lighten(80%),
  radius: 6pt,
  inset: 1em,
) = {
  let special_stroke = (
    ..stroke,
    paint: gradient.linear(stroke.paint.transparentize(100%), stroke.paint.transparentize(0%), stroke.paint.transparentize(0%), angle: 90deg).sharp(3),
  )
  let special_fill = gradient.linear(fill.transparentize(100%), fill.transparentize(0%), fill.transparentize(0%), angle: 90deg).sharp(3)
  let vertical-adjust = stroke.thickness / 2
  v(1.5em, weak: true)
  block(
    spacing: -2pt,
    sticky: true,
    radius: (top-left: radius, top-right: radius),
    stroke: (top: stroke, left: stroke, right: stroke),
    fill: fill,
    height: radius * 2 + 1em,
    width: 100%,
    inset: inset,
    v(0.5em) + title,
  )
  block(
    spacing: -2pt,
    stroke: (left: stroke, right: stroke),
    fill: fill,
    inset: inset,
    width: 100%,
    outset: (top: -vertical-adjust, bottom: -vertical-adjust),
    breakable: true,
    content,
  )
  v(-1em)
  block(
    spacing: -2pt,
    radius: (bottom-left: radius, bottom-right: radius),
    stroke: (bottom: special_stroke, left: special_stroke, right: special_stroke),
    outset: (top: 0em),
    fill: special_fill,
    width: 100%,
    height: radius * 2,
  )
  v(1.5em, weak: true)
}

/// The callout tones the dissertation was set in.
#let classic-tones(g) = (
  wash: g.sample(80%).desaturate(85%).lighten(85%),
  line: g.sample(80%).desaturate(50%).lighten(50%),
  title: g.sample(35%),
  supplement: g.sample(40%),
  ink: g.sample(15%),
  notice: g.sample(50%),
)

/// The callout family in the dissertation's engine and tones. Arguments pass
/// through to the design system's `callouts`.
#let callouts(..args) = _callouts(engine: seamless-block, tones: classic-tones, ..args)
