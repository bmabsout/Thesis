#import "src/lib_cv.typ": primary_color, long_line, diamond

// ===== BU Constants =====
#let BU_NAME = "BOSTON UNIVERSITY"
#let GRS_NAME = "GRADUATE SCHOOL OF ARTS AND SCIENCES"


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
)

#let default_style(primary_color: primary_color) = (
  // Page-level layout properties
  page: (
    margins: (left: 1.5in, right: 1in, top: 1.5in, bottom: 1in),
  ),

  // Body text properties
  body: (
    text: font_options.libertinus_serif, // This already has font, size, weight
  ),

  // Paragraph-specific styling
  paragraph: (
    leading: 1.5em,
  ),

  // Heading styles
  heading: (
    text: ( // Base text properties for all headings
      font: "Libertinus Serif",
    ),
    levels: (
      // Level 1 ~ Chapter
      (
        text: (size: 1.2em, weight: "bold", fill: primary_color),
        spacing: (above: 2em, below: 2em)
      ),
      // Level 2 ~ Section
      (
        text: (size: 1.2em, weight: "bold", fill: primary_color.lighten(20%)),
        spacing: (above: 2em, below: 2em)
      ),
      // Level 3 ~ Subsection
      (
        text: (size: 1.2em, weight: "bold", fill: primary_color.lighten(30%)),
        spacing: (above: 2em, below: 1.5em)
      ),
      // Level 4 ~ Subsubsection
      (
        text: (size: 1em, weight: "bold", fill: black),
      ),
    )
  ),

  other: (
    signature_line_length: 3.7in,
  )
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

#let make_template(style: default_style()) = {
  
  let assemble_thesis_document(
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
    vita: none,
  ) = {

    // --- Document Setup ---
    set document(title: thesis_title, author: author_name)

    set page(
      width: 8.5in,
      height: 11in,
      margin: style.page.margins,
    )

    set text(
      ..style.body.text,
      hyphenate: false,
    )
    set par(justify: true, leading: style.paragraph.leading, spacing: 3em)

    let heading_font_family = style.heading.text.font

    show heading: it => {
      let level_idx = it.level - 1
      let style_props = style.heading.levels.at(level_idx)

      let final_heading_text_style = style.heading.text + style_props.text

      let text_block = text(..final_heading_text_style, it)

      let spacing = style_props.at("spacing", default: (above: 0em, below: 0em))
      v(spacing.above, weak: true)
      text_block
      v(spacing.below, weak: true)
    }

    show heading.where(level: 4): it => {
      box(inset: (right: 0.1em, bottom: 0em))[#text(weight: "bold", it)]
      box(inset: (right: 0em, bottom: 0em))[#text(weight: "bold", ":")]
    }


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

  let make_bu_title_page(
    title_text,
    author_name,
    degree_type,
    submission_year,
    school_name_on_title_page, 
    grs_name_on_title_page,    
    degree_submission_text: "Dissertation submitted in partial fulfillment" // Default, can be overridden
  ) = {
    // This content will be on page 'i', number not printed due to footer logic in setup_thesis_document
    set text(font: style.heading.text.font, features: ("dlig": 0, "liga": 1, "calt": 1, "clig": 0))
    align(center, stack(
      spacing: 0pt,
      text(size: 18pt)[#upper(school_name_on_title_page)],
      v(0.2fr),
      text(size: 14pt)[#upper(grs_name_on_title_page)],
      v(0.6fr),
      text(size: 14pt)[#degree_submission_text], 
      v(0.6fr),
      text(size: 22pt, weight: 800, font:style.heading.text.font, title_text),
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

  let make_bu_copyright_page(author_name, copyright_year) = {
    set text(size: style.body.text.size+3pt, font: style.heading.text.font)
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

  let make_reader_block(reader) = {
    v(1.3em)
    line(length: style.other.signature_line_length, stroke: 0.5pt)
    v(-2em)
    stack(spacing: 10pt, reader.name, reader.academic_title, reader.institution)
  }
  
  let make_bu_approval_page(readers_list) = {
    set text(size: style.body.text.size, font: style.heading.text.font)
    align(center)[#text(20pt, weight: "bold")[Approved by]]
    v(1fr)
    grid(
      columns: (1.7in, auto),
      rows: 8em,
      ..readers_list.map(reader => (reader.ordinal + " Reader", make_reader_block(reader))).flatten()
    )
    v(1fr)
  }

  let make_major_professor_block(professor) = {
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

  let make_bu_abstract_section(
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
      #text(style.heading.levels.at(1).text.size, weight: 700, upper(thesis_title))
      #text(style.heading.levels.at(2).text.size, weight: "bold", upper(author_name))
      #v(0em)
      #text(style.heading.levels.at(3).text.size)[#school_name_for_abstract, #grs_name_for_abstract, #submission_year]
    ]
    major_professors

    align(center)[ // Continue with centered ABSTRACT heading
      #v(1.5em) // Spacing after professors (if any) or before ABSTRACT heading
      #text(style.body.text.size, weight: "bold")[ABSTRACT] // Restored original line
    ]
    v(1.5em) // Spacing after ABSTRACT heading, before the body
    abstract_body_content
  }

  let make_table_of_contents(title: "Contents", depth: 2) = {
    heading(level: 2, numbering: none, outlined: false, title)
    outline(title: none, indent: auto, depth: depth)
  }

  let make_list_of_figures(title: "List of Figures") = {
    heading(level: 2, numbering: none, outlined: false, title)
    outline.supplement(figure.caption)
  }

  let make_list_of_tables(title: "List of Tables") = {
    heading(level: 2, numbering: none, outlined: false, title)
    outline.supplement(table.caption)
  }

  let format_main_content(body_content) = {
    body_content
  }

  let format_appendices(body_content, title: "Appendices") = {
    if body_content != none {
      block({
        heading(level: 1, numbering: none)[#title]
        set par(justify: true, leading: style.paragraph.leading)
        body_content
      })
    } else {[]}
  }

  let format_bibliography(file_path, options: none, title: "Bibliography") = {
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

  let format_vita(vita_content, title: "Vita") = {
    if vita_content != none {
      block({
        heading(level: 1, numbering: none)[#title]
        set par(justify: true, leading: style.paragraph.leading)
        vita_content
      })
    } else {[]}
  }

  (
    make_bu_title_page: make_bu_title_page,
    make_bu_copyright_page: make_bu_copyright_page,
    make_bu_approval_page: make_bu_approval_page,
    make_major_professor_block: make_major_professor_block,
    make_bu_abstract_section: make_bu_abstract_section,
    make_table_of_contents: make_table_of_contents,
    make_list_of_figures: make_list_of_figures,
    make_list_of_tables: make_list_of_tables,
    format_main_content: format_main_content,
    format_appendices: format_appendices,
    format_bibliography: format_bibliography,
    format_vita: format_vita,
    assemble_thesis_document: assemble_thesis_document
  )
}
