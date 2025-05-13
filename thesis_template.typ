#import "src/lib_cv.typ": primary_color, long_line, diamond

// ===== BU Constants =====
#let BU_NAME = "BOSTON UNIVERSITY"
#let GRS_NAME = "GRADUATE SCHOOL OF ARTS AND SCIENCES"

#let thesis_styling = (
  fonts: (
    body: "Libertinus Serif",
    heading: "Source Serif 4",
  ),
  heading_fonts: (
    (size: 17pt, weight: "bold", spacing: (above: 1.5em, below: 1em)),       // Level 1 (Chapter ~ \Large, \bf)
    (size: 14pt, weight: "bold", spacing: (above: 1.0em, below: 1em)),  // Level 2 (Section ~ \large, \bf)
    (size: 12pt, weight: "bold", spacing: (above: 0.8em, below: 1em)),    // Level 3 (Subsection ~ \normalsize, \bf)
    (size: 11pt, weight: "bold", spacing: (above: 0.5em, below: 0.2em)),      // Level 4 (Subsubsection - kept)
  ),
  font_sizes: (
    body: 12.4pt,
  ),
  weights: (
    body: 400,
    heading: "bold",
  ),
  colors: (
    primary: primary_color,
  ),
  spacing: (
    paragraph_leading: 1.5em,
    signature_line_length: 3.7in,
  ),
  margins: (
    left: 1.5in, right: 1in, top: 1.5in, bottom: 1in,
  ),
)

#let thesis_styling = {
  thesis_styling.fonts.body = "New Computer Modern"
  thesis_styling.font_sizes.body = 11.5pt
  thesis_styling
}

#let thesis_styling = {
  thesis_styling.fonts.body = "EB Garamond"
  thesis_styling.font_sizes.body = 13pt
  thesis_styling
}

#let thesis_styling = {
  thesis_styling.fonts.body = "Merriweather"
  thesis_styling.font_sizes.body = 10.2pt
  thesis_styling.weights.body = 300
  thesis_styling
}

#let thesis_styling = {
  thesis_styling.fonts.body = "Source Serif 4"
  thesis_styling.font_sizes.body = 11.3pt
  thesis_styling.weights.body = 400
  thesis_styling
}

#let thesis_styling = {
  thesis_styling.fonts.body = "Garamontio"
  thesis_styling.font_sizes.body = 13pt
  thesis_styling.weights.body = 400
  thesis_styling
}


#let thesis_styling = {
  thesis_styling.fonts.body = "Crimson Pro"
  thesis_styling.font_sizes.body = 12.5pt
  thesis_styling.weights.body = 400
  thesis_styling
}

#let thesis_styling = {
  thesis_styling.fonts.body = "Libre Baskerville"
  thesis_styling.font_sizes.body = 9.9pt
  thesis_styling.weights.body = 400
  thesis_styling
}



#let roman_numbering(content) = {
  counter(page).update(1)
  set page(
    numbering: "i",
    header: [],
    footer: context {
      let page_num_str = counter(page).display("i")
      align(center, text(size: 10pt, page_num_str))
    }
  )
  content
}

// ===== Page Numbering Transition Function =====
#let arabic_numbering(numbering: "1", content) = {
  counter(page).update(1)
  set page(numbering: numbering, footer: [], header: context align(right, text(size: 10pt, counter(page).display(numbering))))
  content
}

#let ignore_page_numbering(content) = {
  set page(footer: [])
  content
}

#let assemble_thesis_document(
  doc, // Accept the document body (required by #show rule)
  thesis_title: none,
  author_name: none, 
  title_page: none,
  copyright_page: none,
  approval_page: none,
  acknowledgments: none, // Optional
  dedication: none, // Optional
  abstract: none,
  table_of_contents: none,
  list_of_figures: none, // Optional
  list_of_tables: none, // Optional
  main: none,
  appendices: none, // Optional
  bibliography: none,
  vita: none
) = {

  // --- Document Setup ---
  set document(title: thesis_title, author: author_name)

  set page(
    width: 8.5in,
    height: 11in,
    margin: thesis_styling.margins,
  )

  set text(
    font: thesis_styling.fonts.body,
    size: thesis_styling.font_sizes.body,
    weight: thesis_styling.weights.body,
    hyphenate: false,
  )
  set par(justify: true, leading: thesis_styling.spacing.paragraph_leading, spacing: 3em)

  let heading_font_family = thesis_styling.fonts.heading
  let current_primary_color = thesis_styling.colors.primary

  show heading: it => {
    let level_idx = it.level - 1
    let style_props = thesis_styling.heading_fonts.at(level_idx)
    let text_color = (
      current_primary_color, // Level 1
      current_primary_color.lighten(20%), // Level 2
      current_primary_color.lighten(30%), // Level 3
      black // Level 4 (default color)
    ).at(level_idx)

    block(
      above: style_props.spacing.above,
      below: style_props.spacing.below,
      text(
        font: heading_font_family,
        weight: style_props.weight,
        size: style_props.size,
        fill: text_color,
        it
      )
    )
  }

  // Commented out old/specific heading rules, including special L4 formatting
  // show heading.where(level: 4): it => { ... }

  set heading(numbering: "1.1")
  set math.equation(numbering: "(1)")
  // --- Assemble Document Parts ---

  let build_pages = (pages) => {
    for page in pages.filter(page => page != none and page != []).intersperse(pagebreak()) {
      page
    }
  }

  roman_numbering(
    build_pages((
      ignore_page_numbering(title_page),
      ignore_page_numbering(copyright_page),
      ignore_page_numbering(approval_page),
      dedication,
      acknowledgments,
      abstract,
      table_of_contents,
      list_of_figures,
      list_of_tables
    ))
  )
  arabic_numbering(
    build_pages((
      main,
      appendices,
      bibliography,
      vita
    ))
  )
}

// ===== Page-Specific Construction Functions =====

#let make_bu_title_page(
  title_text,
  author_name,
  degree_type,
  submission_year,
  school_name_on_title_page, 
  grs_name_on_title_page,    
  degree_submission_text: "Dissertation submitted in partial fulfillment" // Default, can be overridden
) = {
  // This content will be on page 'i', number not printed due to footer logic in setup_thesis_document
  set text(font: thesis_styling.fonts.heading, features: ("dlig": 0, "liga": 1, "calt": 1, "clig": 0))
  align(center, stack(
    spacing: 0pt,
    text(size: 18pt)[#upper(school_name_on_title_page)],
    v(0.2fr),
    text(size: 14pt)[#upper(grs_name_on_title_page)],
    v(0.6fr),
    text(size: 14pt)[#degree_submission_text], 
    v(0.6fr),
    text(size: 22pt, weight: 800, font:thesis_styling.fonts.heading, title_text),
    v(0.3fr),
    text(size: 14pt)[By],
    v(0.3fr),
    text(size: 18pt)[#upper(author_name)],
    v(0.6fr),
    text(size: 12pt)[
      Submitted in Partial Fulfillment of the\
      Requirements for the Degree of\
      #degree_type
    ],
    v(0.6fr),
    text(size: 12pt)[#submission_year]
  ))
}

#let make_bu_copyright_page(author_name, copyright_year) = {
  set text(size: thesis_styling.font_sizes.body+3pt, font: thesis_styling.fonts.heading)
  // This content will be on page 'ii', number not printed
  v(1fr)
  align(center,
    stack(
      dir: ltr,
      spacing: 10pt,
      h(1fr),
      sym.copyright,
      align(left,par(leading: 10pt)[
        #copyright_year by\
        #author_name\
        all rights reserved
      ]),
      h(0.3fr)
    )
  )
}

#let make_reader_block(reader) = {
  v(1.3em)
  line(length: thesis_styling.spacing.signature_line_length, stroke: 0.5pt)
  v(-2em)
  stack(spacing: 10pt, reader.name, reader.academic_title, reader.institution)
}
#let make_bu_approval_page(readers_list) = {
  set text(size: thesis_styling.font_sizes.body, font: thesis_styling.fonts.heading)
  align(center)[#text(20pt, weight: "bold")[Approved by]]
  v(1fr)
  grid(
    columns: (1.7in, auto),
    rows: 8em,
    ..readers_list.map(reader => (reader.ordinal + " Reader", make_reader_block(reader))).flatten()
  )
  v(1fr)
}

#let make_major_professor_block(professor) = {
  stack(
    dir: ltr,
    spacing: 10pt,
    [*Major Professor:*],
    par(leading: 10pt)[
      #professor.name\
      #professor.title
    ]
  )
}

#let make_bu_abstract_section(
  thesis_title,
  author_name,
  school_name_for_abstract,
  grs_name_for_abstract,
  degree_type,
  submission_year,
  major_professors, // Expected: array of dictionaries, each with "name" and "department" (or "title")
  abstract_body_content
) = {
  align(center)[
    #text(thesis_styling.heading_fonts.at(1).size, weight: 700, upper(thesis_title))
    #text(thesis_styling.heading_fonts.at(2).size, weight: "bold", upper(author_name))
    #v(0em)
    #text(thesis_styling.heading_fonts.at(3).size)[#school_name_for_abstract, #grs_name_for_abstract, #submission_year]
  ]
  major_professors

  align(center)[ // Continue with centered ABSTRACT heading
    #v(1.5em) // Spacing after professors (if any) or before ABSTRACT heading
    #text(thesis_styling.font_sizes.body, weight: "bold")[ABSTRACT] // Restored original line
  ]
  v(1.5em) // Spacing after ABSTRACT heading, before the body
  abstract_body_content
}

#let make_table_of_contents(title: "Contents", depth: 2) = {
  block(above:1em, below:1em)[#outline(title: text(thesis_styling.font_sizes.body, weight: "bold", title), indent: auto, depth: depth)]
}

#let make_list_of_figures(title: "List of Figures") = {
  block(above:1em, below:1em)[#outline.supplement(figure.caption, title: text(thesis_styling.font_sizes.body, weight: "bold", title))]
}

#let make_list_of_tables(title: "List of Tables") = {
  block(above:1em, below:1em)[#outline.supplement(table.caption, title: text(thesis_styling.font_sizes.body, weight: "bold", title))]
}

#let format_main_content(body_content) = {
  body_content
}

#let format_appendices(body_content, title: "Appendices") = {
  if body_content != none {
    block({
      heading(level: 1, numbering: none)[#title]
      set par(justify: true, leading: thesis_styling.spacing.paragraph_leading)
      body_content
    })
  } else {[]}
}

#let format_bibliography(file_path, options: none, title: "Bibliography") = {
  if file_path != none {
    heading(level: 1, numbering: none)[#title]
    let style = options.at("style", default: none)
    let bib_title_opt = options.at("title", default: none)
    bibliography(
        file_path,
        title: if bib_title_opt != none {bib_title_opt} else {none},
        style: if style != none {style} else {"ieee"}
    )
  } else {[]}
}

#let format_vita(vita_content, title: "Vita") = {
  if vita_content != none {
    block({
      heading(level: 1, numbering: none)[#title]
      set par(justify: true, leading: thesis_styling.spacing.paragraph_leading)
      vita_content
    })
  } else {[]}
}
