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

// Accent Gradients
// #let accent1_gradient = gradient.linear(
//   oklch(0%, 44%, 89deg),
//   oklch(100%, 44%, 89deg)
// )
// #let accent2_gradient = gradient.linear(
//   oklch(0%, 36%, 257deg),
//   oklch(100%, 36%, 257deg)
// )
// #let accent3_gradient = gradient.linear(
//   oklch(0%, 55%, 137deg),
//   oklch(100%, 55%, 137deg)
// )
#let accent5_gradient = gradient.linear(
  oklch(0%, 73%, 43deg),
  oklch(100%, 73%, 43deg)
)
// #let accent5_gradient = gradient.linear(
//   oklch(0%, 74.44695113486235%, 317deg),
//   oklch(100%, 74.44695113486235%, 317deg)
// )



#let long_line = line(
  length: 100%,
  stroke: (
    paint: primary_gradient.sample(90%),
    thickness: 3pt,
    dash: ("dot", 6.1pt),
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
  par: (
    leading: 1.5em,
    spacing: 2em,
    first-line-indent: 0em,
    // hanging-indent: 0em,
    justify: true,
  ),

  // Heading styles
  heading: (
    text: font_options.libertinus_serif,
    levels: (
      // Level 1 ~ Chapter
      (
        text: (size: 1.8em, weight: "bold", fill: colors.primary.sample(30%)),
        spacing: (above: 2em, below: 2em)
      ),
      // Level 2 ~ Section
      (
        text: (size: 1.5em, weight: "bold", fill: colors.primary.sample(45%)),
        spacing: (above: 2em, below: 1.5em)
      ),
      // Level 3 ~ Subsection
      (
        text: (size: 1.2em, weight: "bold", fill: colors.primary.sample(60%)),
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


#let seamless-block(
    title: none,
    content,
    stroke: 1pt,
    fill: blue.lighten(80%),
    radius: 6pt,
    inset: 1em
) = {
  let special_stroke = (..stroke, paint: gradient.linear(stroke.paint.transparentize(100%), stroke.paint.transparentize(0%), stroke.paint.transparentize(0%), angle: 90deg).sharp(3))
  let special_fill = gradient.linear(fill.transparentize(100%), fill.transparentize(0%), fill.transparentize(0%), angle: 90deg).sharp(3)
    let vertical-adjust = stroke.thickness / 2
      v(1.5em, weak: true)
      block(
        spacing: -2pt,
          sticky: true,  // Critical for keeping top with content
          radius: (top-left: radius, top-right: radius),
          stroke: (top: stroke, left: stroke, right: stroke),
          fill: fill,
          height: radius*2+1em,  // Collapse to border thickness
          width: 100%,
          inset: inset,
          v(0.5em)+title
      )
      block(
        spacing: -2pt,
        // sticky: true,
          stroke: (left: stroke, right: stroke),
          fill: fill,
          inset: inset,
          width: 100%,
          outset: (top: -vertical-adjust, bottom: -vertical-adjust),
          // sticky: true,
          breakable: true,
          content
      )
      v(-1em)
      block(
        spacing: -2pt,
          radius: (bottom-left: radius, bottom-right: radius),
          stroke: (bottom: special_stroke, left: special_stroke, right: special_stroke),
          outset: (top: 0em),
          fill: special_fill,
          width: 100%,
          height: radius*2,
      )
      v(1.5em, weak: true)
}


// #show figure.where(kind: "theorem"): it => {
//   theorem(title: it.title, body: it.content, gradient: it.gradient)
// }

// #figure(kind: "theorem", caption: "Theorem", gradient: accent2_gradient)[pompe]

#let note(content, gradient: primary_gradient, title: none, engine: seamless-block) = align(center, {
  if title != none {
    engine = engine.with( 
      title: if title != none {
        show text: it => text(size: default_style().heading.text.size*1.2, weight: "bold", style: "italic", fill: gradient.sample(35%), it)
        title
      }
    )
  }
  [
    #engine(
      stroke: (paint: gradient.sample(80%).desaturate(50%).lighten(50%),
        thickness: 3pt,
        dash: ("dot", 6pt),
        cap: "round",),
      radius: 12pt,
      fill: gradient.sample(80%).desaturate(85%).lighten(85%),
      inset: 1em,
      align(left, [
        #set text(fill: gradient.sample(15%))
        #content
      ])
    )
    
  ]
})

#let theorem_counter = counter("theorem")

#let theorem(title: none, body, gradient: accent2_gradient) = {
  theorem_counter.step()
  context {
    let theorem_num = theorem_counter.get().first()
    let title = if title != none {
      [*Theorem #theorem_num: #title*]
    } else {
      [*Theorem #theorem_num*]
    }
    note(gradient: gradient, title: title)[
      
      #body
    ]
  }
}

#let algorithm_counter = counter("algorithm")

#let algorithm(title: none, body, gradient: accent1_gradient) = {
  algorithm_counter.step()
  context {
    let algorithm_num = algorithm_counter.get().first()
    let title = if title != none {
      [*Algorithm #algorithm_num: #title*]
    } else {
      [*Algorithm #algorithm_num*]
    }
    note(gradient: gradient, title: title)[
      
      #body
    ]
  }
}

#let notice(content, gradient: accent5_gradient) = {
  note([#text(fill: gradient.sample(50%))[_*Notice:*_] #content], gradient: gradient, engine: block)
}


#let manual_sampler(fill: none, width: 10em, height: 2em, samples: 100) = {
  let filler(i) = {
    if type(fill) == gradient {
      return fill.sample(i*1%)
    }
    return fill
  }

  stack(dir: ltr, spacing: 0em, ..range(samples).map(i => rect(fill: filler(i), width: width/samples, height: height)))
}


#let local_outline(style: default_style()) = context {
  outline(target: selector(heading.where(level: 2).or(heading.where(level: 3))).after(here()).before(heading.where(level: 1).after(here())), title: none)
}