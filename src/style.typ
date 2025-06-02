#let primary_hue = 5deg
#let accent1_hue = 140deg
#let accent2_hue = 200deg
#let accent3_hue = -60deg
#let accent4_hue = 48deg
#let ref_hue = -20deg

#let primary_gradient = gradient.linear(
  space: oklch,
  oklch(0%, 60%, primary_hue),
  oklch(100%, 5%, primary_hue+15deg)
)

#let accent1_gradient = gradient.linear(
  space: oklch,
  oklch(0%, 50%, accent1_hue),
  oklch(70%, 70%, accent1_hue+20deg)
)

#let accent2_gradient = gradient.linear(
  space: oklch,
  oklch(0%, 50%, accent2_hue),
  oklch(70%, 70%, accent2_hue+20deg)
)

#let accent3_gradient = gradient.linear(
  space: oklch,
  oklch(0%, 50%, accent3_hue),
  oklch(70%, 70%, accent3_hue+20deg)
)

#let accent4_gradient = gradient.linear(
  space: oklch,
  oklch(0%, 50%, accent4_hue),
  oklch(70%, 70%, accent4_hue+10deg)
)

#let ref_gradient = gradient.linear(
  space: oklch,
  oklch(0%, 0%, ref_hue),
  oklch(0%, 0%, ref_hue+10deg)
)


// Accent color variables
#let accent-1-start = oklch(0%, 0.112, 196deg)
#let accent-1-end = oklch(100%, 0.112, 196deg)
#let accent-2-start = oklch(0%, 0.116, 136deg)
#let accent-2-end = oklch(100%, 0.116, 136deg)
#let accent-3-start = oklch(0%, 0.116, 256deg)
#let accent-3-end = oklch(100%, 0.116, 256deg)
#let accent-4-start = oklch(0%, 0.124, 46deg)
#let accent-4-end = oklch(100%, 0.124, 46deg)
#let accent-5-start = oklch(0%, 0.124, -14deg)
#let accent-5-end = oklch(100%, 0.124, -14deg)
#let accent-6-start = oklch(0%, 0.104, 166deg)
#let accent-6-end = oklch(100%, 0.104, 166deg)

// Gradient definitions
#let accent1_gradient = gradient.linear(space: oklch, accent-3-start, accent-3-end)
#let accent2_gradient = gradient.linear(space: oklch, accent-5-start, accent-5-end)
#let accent3_gradient = gradient.linear(space: oklch, accent-6-start, accent-6-end)


#let long_line = line(
  length: 100%,
  stroke: (
    paint: primary_gradient.sample(90%),
    thickness: 3pt,
    dash: ("dot", 6pt),
    cap: "round",
  )
)

#let diamond(spacing: 0.4em) = {
  h(spacing)
  box(
    baseline: -10%,
    rotate(
      45deg,
      rect(
        width: 0.4em,
        height: 0.4em,
        radius: 0.15em,
        fill: shade_color,
        stroke: 0.1em + primary_gradient.sample(92%)
      )
    ),
  )
  h(spacing)
}


#let font_options = (
  libertinus_serif: (
    font: "Libertinus Serif",
    size: 12.4pt,
    weight: 400,
  ),
  new_computer_modern: (
    font: "New Computer Modern",
    size: 11.5pt,
  ),
  eb_garamond: (
    font: "EB Garamond",
    size: 13pt,
  ),
  merriweather: (
    font: "Merriweather",
    size: 10.2pt,
  ),
  source_serif_4: (
    font: "Source Serif 4",
    size: 11.3pt,
  ),
  crimson_pro: (
    font: "Crimson Pro",
    size: 12.5pt,
    weight: 400,
  ),
  garamontio: (
    font: "Garamontio",
    size: 13pt,
    weight: 400,
  ),
  libre_baskerville: (
    font: "Libre Baskerville",
    size: 9.9pt,
    weight: 400,
  ),
  baskervillef: (
    font: "BaskervilleF",
    size: 12pt,
    weight: 400,
  ),
  dejavu_serif: (
    font: "Dejavu Serif",
    size: 10pt,
    weight: 400,
  ),
  lato: (
    font: "Lato",
    size: 11.5pt,
  ),
)


#let colors = (
  primary: primary_gradient,
  ref: ref_gradient,
  accent1: accent1_gradient,
  accent2: accent2_gradient,
  accent3: accent3_gradient,
  accent4: accent4_gradient,
)

#let default_style(colors: colors) = (
  colors: colors,
  // Page-level layout properties
  page: (
    margins: (left: 1.5in, right: 1in, top: 1.5in, bottom: 1in),
  ),

  // Body text properties
  body: (
    text: font_options.libertinus_serif,
  ),

  // Paragraph-specific styling
  paragraph: (
    leading: 1.5em,
  ),

  // Heading styles
  heading: (
    text: font_options.libertinus_serif,
    levels: (
      // Level 1 ~ Chapter
      (
        text: (size: 1.5em, weight: "bold", fill: colors.primary.sample(30%)),
        spacing: (above: 2em, below: 2em)
      ),
      // Level 2 ~ Section
      (
        text: (size: 1.4em, weight: "bold", fill: colors.primary.sample(45%)),
        spacing: (above: 2em, below: 2em)
      ),
      // Level 3 ~ Subsection
      (
        text: (size: 1.3em, weight: "bold", fill: colors.primary.sample(60%)),
        spacing: (above: 2em, below: 1.5em)
      ),
      // Level 4 ~ Subsubsection
      (
        text: (size: 1em, weight: "bold", fill: black),
      ),
    )
  ),
  radius: 12pt,
)

#let heading_style(style, level: 0) = {
  return style.heading.text + style.heading.levels.at(level).text
}



#let note(content) = align(center, box(
  stroke: (paint: primary_gradient.sample(90%),
    thickness: 3pt,
    dash: ("dot", 6pt),
    cap: "round",),
  radius: 12pt,
  fill: primary_gradient.sample(97%),
  inset: 1em,
  align(left, [
    #set text(fill: primary_gradient.sample(40%))
    #content
  ])
))

#let manual_sampler(fill: none, width: 10em, height: 2em, samples: 100) = {
  let filler(i) = {
    if type(fill) == gradient {
      return fill.sample(i*1%)
    }
    return fill
  }

  stack(dir: ltr, spacing: 0em, ..range(samples).map(i => rect(fill: filler(i), width: width/samples, height: height)))
}


// #let todo(message) = {
//   locate(loc => ())
//   text(red, [TODO: #message])
// }