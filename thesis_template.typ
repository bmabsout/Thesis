#import "src/lib_cv.typ": primary_color, long_line, diamond

// ===== BU Constants =====
#let BU_NAME = "BOSTON UNIVERSITY"
#let GRS_NAME = "GRADUATE SCHOOL OF ARTS AND SCIENCES"

// ===== Core Document Setup Function =====
#let setup_thesis_document(doc_title, doc_author) = {
  // 1. Set document metadata
  let final_title = if type(doc_title) == str { doc_title } else if type(doc_title) == content { doc_title.text } else { "Untitled" }
  let final_author = if type(doc_author) == str { doc_author } else if type(doc_author) == content { doc_author.text } else { "Unknown Author" }
  set document(title: final_title, author: final_author)

  // Margins from guidelines
  set page(
    width: 8.5in,
    height: 11in,
    margin: (left: 1.5in, right: 1in, top: 1.5in, bottom: 1in),
    numbering: "i",
    header: [],
    footer: context {
      let page_num_str = counter(page).display("i")
      // Suppress for first three logical pages (i, ii, iii) by convention.
      // Actual content functions for these pages will produce no visible page number area.
      // For pages like abstract, toc (iv, v, etc.) this footer will show the number.
      if page_num_str == "i" or page_num_str == "ii" or page_num_str == "iii" {
        []
      } else {
        align(center, text(size: 10pt, page_num_str))
      }
    }
  )

  // Basic font settings (User can override with more specific `set text` calls in their doc)
  set text(
    font: "Source Serif 4", // Default body font
    size: 12pt, // Guideline: 10, 11, or 12pt.
    weight: 400,
    hyphenate: false
  )
  // Double spacing for general paragraphs
  set par(justify: true, leading: 1.0em)

  // Enable heading numbering globally
  set heading(numbering: "1.1")

  // Enable equation numbering globally
  set math.equation(numbering: "(1)")

  // Basic Heading styles (User can override with `show heading` rules in their doc)
  // Forcing heading fonts/sizes here makes it less flexible.
  // Providing a base style, user can customize.
  let heading_font_family = "Jost*" // Default heading font
  let current_primary_color = rgb("#0033A0") // Default BU Blue

  show heading: set text(font: heading_font_family, weight: "bold")
  show heading.where(level: 1): it => {
    set text(fill: current_primary_color, size: 12pt, weight: "bold")
    block(above: 1.5em, below: 0.7em)[#it]
  }
  show heading.where(level: 2): it => {
    set text(fill: current_primary_color.lighten(20%), size: 12pt, weight: "semibold")
    block(above: 1em, below: 0.5em)[#it]
  }
  show heading.where(level: 3): it => {
    set text(fill: current_primary_color.lighten(30%), size: 12pt, weight: "medium")
    block(above: 0.8em, below: 0.3em)[#it]
  }
  show heading.where(level: 4): it => {
    // Adopted from old prospectus.typ to ensure numbering and referenceability
    // The v() call is correct here as 'show heading' body is a code context
    v(0.5em) 
    box(inset: (right: 0.1em, bottom: 0em))[#text(font: heading_font_family, weight: "bold", size: 11pt, it)]
    // Retaining the colon for now, can be removed if numbers make it redundant
    box(inset: (right: 0em, bottom: 0em))[#text(font: heading_font_family, weight: "bold", size: 11pt, ":")]
  }
}

// ===== Page Numbering Transition Function =====
#let start_main_content_numbering() = {
  counter(page).update(1) // Reset page counter to 1 for Arabic numbering
  set page(
    numbering: "1",
    footer: [], // Clear Roman numeral footer
    header: context align(right, text(size: 10pt, counter(page).display("1"))) // Top right Arabic numbers
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
  set text(font: "Jost*", features: ("dlig": 1, "liga": 1, "calt": 1, "clig": 1))
  align(center, stack(
    spacing: 0pt,
    text(size: 18pt)[#upper(school_name_on_title_page)],
    v(0.2fr),
    text(size: 14pt)[#upper(grs_name_on_title_page)],
    v(0.6fr),
    text(size: 14pt)[#degree_submission_text], 
    v(0.6fr),
    text(size: 25pt, weight: 800, font:"Jost*")[#title_text],
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
  set text(size: 12pt, font: "Jost*")
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
  #line(length: 3.7in, stroke: 0.5pt)
  #v(-0.5em)
  #reader.name\
  #reader.academic_title
]
#let make_bu_approval_page(readers_list) = {
  set text(size: 12pt, font: "Jost*")
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
    #text(12pt, weight: "bold", upper(thesis_title))
    #v(2em)
    #text(12pt, weight: "bold", upper(author_name))
    #v(1em)
    #text(12pt)[#school_name_for_abstract]
    #v(0.5em)
    #text(12pt)[#grs_name_for_abstract]
    #v(0.5em)
    #text(12pt)[#degree_type, #submission_year]
    // v(2em) removed from here; spacing handled before/after professor list
  ]

  // Major Professors list - Left Aligned as per guidelines
  if type(major_professors_list) == array and major_professors_list.len() > 0 {
    v(1.5em) // Spacing before this section
    align(left)[ // Align this whole block left
      #text(if major_professors_list.len() > 1 {"Major Professors:"} else {"Major Professor:"}, size: 12pt, weight: "bold")
      #v(0.5em)
      #for prof in major_professors_list {
        let name = prof.at("name", default: "Unnamed Professor")
        // Use "department" if available, otherwise fallback to "title", then to an empty string or "No Department"
        let role_info = prof.at("department", default: prof.at("title", default: ""))
        [#text(12pt)[#name#if role_info != "" {", " + role_info}]] // Each prof on a new line, left aligned
        v(0.3em) // Small space between professor lines
      }
    ]
  }

  align(center)[ // Continue with centered ABSTRACT heading
    #v(1.5em) // Spacing after professors (if any) or before ABSTRACT heading
    #text(12pt, weight: "bold")[ABSTRACT]
  ]
  v(1.5em) // Spacing after ABSTRACT heading, before the body
  block({ // Ensure abstract body also adheres to document par settings (e.g. double spacing)
    abstract_body_content
  })
}

#let make_table_of_contents(title: "Contents", depth: 2) = {
  block(above:1em, below:1em)[#outline(title: text(12pt, weight: "bold", title), indent: auto, depth: depth)]
}

#let make_list_of_figures(title: "List of Figures") = {
  block(above:1em, below:1em)[#outline.supplement(figure.caption, title: text(12pt, weight: "bold", title))]
}

#let make_list_of_tables(title: "List of Tables") = {
  block(above:1em, below:1em)[#outline.supplement(table.caption, title: text(12pt, weight: "bold", title))]
}

#let format_main_content(body_content) = {
  // Global paragraph/text settings from setup_thesis_document apply here.
  // Redundantly ensure heading numbering is active for this content block
  // to address issues with references in included chapter files.
  set heading(numbering: "1.1") 
  // Redundantly ensure equation numbering is active as well for included chapters.
  set math.equation(numbering: "(1)")
  body_content
}

#let format_appendices(body_content, title: "Appendices") = {
  if body_content != none {
    heading(level: 1, numbering: none)[#title]
    body_content
  } else {[]}
}

#let format_bibliography(file_path, options: (:), title: "Bibliography") = {
  if file_path != none {
    heading(level: 1, numbering: none)[#title]
    let bib_options_dict = if type(options) == dictionary { options } else { (:)}
    // Check for common options and pass them if present
    // More robust would be to check specific allowed keys for bibliography style
    let style = bib_options_dict.at("style", default: none)
    let bib_title_opt = bib_options_dict.at("title", default: none)

    if style != none and bib_title_opt != none {
       bibliography(file_path, title: bib_title_opt, style: style)
    } else if style != none {
       bibliography(file_path, style: style)
    } else if bib_title_opt != none {
       bibliography(file_path, title: bib_title_opt)
    } else if bib_options_dict.len() > 0 and bib_options_dict.keys().len() > 0 { // If other options exist, try spreading
        // This was the problematic part, ensure options are simple strings/bools if spreading
        // For now, stick to explicit known options to avoid the previous error.
        // If generic spreading is needed, options must be carefully validated by the caller.
        bibliography(file_path) // Fallback if only unknown options
    } else {
      bibliography(file_path)
    }
  } else {[]}
}

#let format_vita(vita_content, title: "Vita") = {
  if vita_content != none {
    heading(level: 1, numbering: none)[#title]
    block({ // Ensure vita content also adheres to document par settings
      set par(leading: 1.0em) 
      vita_content
    })
  } else {[]}
}

// NO #show rule in the template file itself. 
// The main document (e.g., prospectus.typ) will import these functions and construct the document.