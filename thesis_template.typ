#import "src/lib_cv.typ": primary_color, long_line, diamond

// ===== BU Constants =====
#let BU_NAME = "BOSTON UNIVERSITY"
#let GRS_NAME = "GRADUATE SCHOOL OF ARTS AND SCIENCES"

#let thesis_styling = (
  fonts: (
    body: "Source Serif 4",
    heading: "Jost*",
  ),
  heading_fonts: (
    (size: 12pt, weight: "bold", spacing: (above: 1.5em, below: 1em)),       // Level 1
    (size: 12pt, weight: "semibold", spacing: (above: 1.0em, below: 1em)),  // Level 2
    (size: 12pt, weight: "medium", spacing: (above: 0.8em, below: 1em)),    // Level 3
    (size: 11pt, weight: "bold", spacing: (above: 0.5em, below: 0.2em)),      // Level 4
  ),
  font_sizes: (
    body: 12pt,
  ),
  weights: (
    body: 400,
    heading: "bold",
  ),
  colors: (
    primary: primary_color,
  ),
  spacing: (
    paragraph_leading: 2.0em,
    signature_line_length: 3.7in,
  ),
  margins: (
    left: 1.5in, right: 1in, top: 1.5in, bottom: 1in,
  ),
)

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
  department_name_on_title_page,
  degree_submission_text: "Dissertation submitted in partial fulfillment" // Default, can be overridden
) = {
  // This content will be on page 'i', number not printed due to footer logic in setup_thesis_document
  set text(font: thesis_styling.fonts.heading, features: ("dlig": 1, "liga": 1, "calt": 1, "clig": 1))
  align(center, stack(
    spacing: 0pt,
    text(size: 18pt)[#upper(school_name_on_title_page)],
    v(0.2fr),
    text(size: 14pt)[#upper(grs_name_on_title_page)],
    v(0.6fr),
    text(size: 14pt)[#degree_submission_text], 
    v(0.6fr),
    text(size: 25pt, weight: 800, font:thesis_styling.fonts.heading)[#title_text],
    v(0.3fr),
    text(size: 14pt)[By],
    v(0.3fr),
    text(size: 18pt)[#upper(author_name)],
    v(0.6fr),
    text(size: 12pt)[
      Submitted in Partial Fulfillment of the\
      Requirements for the Degree of\
      #degree_type\
      In the #department_name_on_title_page
    ],
    v(0.6fr),
    text(size: 12pt)[#submission_year]
  ))
}

#let make_bu_copyright_page(author_name, copyright_year) = {
  set text(size: thesis_styling.font_sizes.body, font: thesis_styling.fonts.heading)
  // This content will be on page 'ii', number not printed
  v(2fr) 
  align(center)[
    © Copyright by #author_name \
    #copyright_year
  ]
  v(1fr)
}

#let make_reader_block(reader) = [
  #v(1.3em)
  #line(length: thesis_styling.spacing.signature_line_length, stroke: 0.5pt)
  #v(-0.5em)
  #reader.name\
  #reader.academic_title
  #if "institution" in reader and reader.institution != none [
    , #reader.institution
  ]
]
#let make_bu_approval_page(readers_list) = {
  set text(size: thesis_styling.font_sizes.body, font: thesis_styling.fonts.heading)
  align(center)[#text(20pt, weight: "bold")[Approved by]]
  v(1fr)
  grid(
    columns: (1.2in, auto),
    rows: 8em,
    ..readers_list.map(reader => (reader.ordinal + " Reader", make_reader_block(reader))).flatten()
  )
  v(1fr)
}

#let make_bu_abstract_section(
  thesis_title,
  author_name,
  school_name_for_abstract,
  grs_name_for_abstract,
  degree_type,
  submission_year,
  major_professors_list, // Expected: array of dictionaries, each with "name" and "department" (or "title")
  abstract_body_content
) = {
  align(center)[
    #text(thesis_styling.font_sizes.body, weight: "bold", upper(thesis_title))
    #v(2em)
    #text(thesis_styling.font_sizes.body, weight: "bold", upper(author_name))
    #v(1em)
    #text(thesis_styling.font_sizes.body)[#school_name_for_abstract]
    #v(0.5em)
    #text(thesis_styling.font_sizes.body)[#grs_name_for_abstract]
    #v(0.5em)
    #text(thesis_styling.font_sizes.body)[#degree_type, #submission_year]
  ]

  // Major Professors list - Left Aligned as per guidelines
  if type(major_professors_list) == array and major_professors_list.len() > 0 {
    v(1.5em) // Spacing before this section
    align(left)[ // Align this whole block left
      #let prof_label = if major_professors_list.len() > 1 {"Major Professors:"} else {"Major Professor:"}
      #text(thesis_styling.font_sizes.body, weight: "bold")[#prof_label]
      #v(0.5em)
      #for prof in major_professors_list {
        let name = prof.at("name", default: "Unnamed Professor")
        // Use "department" if available, otherwise fallback to "title", then to an empty string or "No Department"
        let role_info = prof.at("department", default: prof.at("title", default: ""))
        [#text(thesis_styling.font_sizes.body)[#name#if role_info != "" {", " + role_info}]] // Each prof on a new line, left aligned
        v(0.3em) // Small space between professor lines
      }
    ]
  }

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
