#import "style.typ": default_style, heading_style, long_line, local_outline, note

#let roman_numbering(content) = {
  counter(page).update(1)
  set page(
    numbering: "i",
    header: [],
    footer: context {
      let page_num_str = counter(page).display("i")
      align(center, text(size: 1em, page_num_str))
    }
  )
  content
}

// ===== Page Numbering Transition Function =====
#let arabic_numbering(numbering: "1", content) = {
  counter(page).update(1)
  set page(numbering: numbering, footer: [], header: context align(right, text(size: 1em, counter(page).display(numbering))))
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
    local_outlines: true,
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
    set par(..style.par)

    show heading: it => {
      set text(size: style.heading.text.size)
      let level_idx = it.level - 1
      let style_props = style.heading.levels.at(level_idx)
      set text(..heading_style(style, level: level_idx))

      let spacing = style_props.at("spacing", default: (above: 0em, below: 0em))
      v(spacing.above, weak: true)
      if it.level == 1 {
        colbreak(weak: true)
        if it.numbering != none [Chapter #counter(heading).display()\ ]
        it.body
        place(long_line, dy: -style.heading.levels.at(0).spacing.below/2)
        if local_outlines and it.numbering != none {
          local_outline(style: style)
          v(-0.2em)
          long_line
          v(-1em)
        }
      } else {
        it
      }
      v(spacing.below, weak: true)
    }
  
    show heading.where(level: 4): it => {
      parbreak()
      text(weight: "bold")[#box(it):#h(0.5em)]
    }

    set heading(numbering: "1.1")
    set math.equation(numbering: "(1)")
    show math.equation: it => box(it) 
    set figure(gap: 1.5em)
    show figure: set block(breakable: true)

    set ref(supplement: it => {
      if it.func() == heading and it.level == 1 {
        [Chapter]
      } else if it.func() == heading {
        if it.level == 4 {
          [Definition]
        } else {
          [Section]
        }
      } else if it.func() == figure {
        it.supplement
      }
    })


    show ref: it => {
      // set text(size: 0.9em)
      show text: it => smallcaps(lower(it))
      if it.element != none and it.element.func() == heading {
        set text(fill: heading_style(style, level: it.element.level - 1).fill)
        it
      } else {
        set text(fill: style.colors.ref.sample(60%))
        it
      }
    }

    show outline: it => {
      set text(size: style.heading.text.size)
      // long_line
      it
      // long_line
      // // v(12pt)
      // block(
      // it, breakable: true)
      // // v(5pt)
      // long_line
    }

    show outline.entry: it => {
      set text(..heading_style(style, level: it.level - 1), size: 1em)
      box(it)
    }


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
    set text(..style.heading.text, size: 1.2em, features: ("dlig": 0, "liga": 1, "calt": 1, "clig": 0))
    set align(center)
    [
      #upper(school_name_on_title_page)\
      #upper(grs_name_on_title_page)
      #v(0.6fr)
      #degree_submission_text 
      #v(0.6fr)
      *#text(size: 1.2em, title_text)*
      #v(0.3fr)
      By
      #v(0.3fr)
      #upper(author_name)
      #v(0.6fr)
      #text(size: 0.8em, style: "italic")[
        Submitted in Partial Fulfillment of the\
        Requirements for the Degree of\
        #degree_type
      ]
      #v(0.6fr)
      #submission_year
    ]
  }

  let make_bu_copyright_page(author_name, copyright_year) = {
    set text(..style.heading.text, size: 1.2em)
    // This content will be on page 'ii', number not printed
    v(1fr)
    stack(
      dir: ltr,
      spacing: 0.5em,
      h(1fr),
      sym.copyright,
      align(left,[
        #copyright_year by\
        #author_name\
        all rights reserved
      ]),
      // h(0.3fr)
    )
  }

  let make_reader_block(reader) = [
    #v(5em)
    #box(line(length: 100%, stroke: (thickness: 1pt, dash: "dashed", cap: "round")))\
    #reader.name\
    #reader.title\
    #reader.institution
  ]
  
  let make_bu_approval_page(readers_list) = {
    set text(..heading_style(style, level: 1), fill: black, weight: 400)
    align(center)[*Approved by*]
    set text(size: 0.8em)
    block(width: 100%, height: 1fr,
    grid(
      column-gutter: 2.2em,
      row-gutter: 1fr,
      columns: (auto, auto),
      ..readers_list.map(reader => ([#v(2.5em)#reader.ordinal Reader], make_reader_block(reader))).flatten()
    ))
    
  }
  let make_major_professor_block(professor) = {
    stack(
      dir: ltr,
      spacing: 1em,
      [*Major Professor:*],
      [
        #set align(left)
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
      #heading(level: 3, numbering: none, outlined: false, text(fill: black, upper(thesis_title)))
      #v(1em)
      #note(engine: block.with(width: 100%))[
        #set align(center)
        #text(size: 1.2em)[#upper(author_name)]\
        #school_name_for_abstract, #grs_name_for_abstract, #submission_year
        #major_professors
      ]
    ]
    align(center)[
      #heading(numbering: none, level: 2, outlined: false)[ABSTRACT]
    ]
    abstract_body_content
  }

  let make_table_of_contents(title: "Contents", depth: 2) = {
    heading(level: 2, numbering: none, outlined: false, title)
    long_line
    outline(title: none, indent: 3em, depth: depth)
    long_line
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

  let format_vita(vita_content, title: "Vita") = {
    if vita_content != none {
      block({
        heading(level: 1, numbering: none)[#title]
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
    format_vita: format_vita,
    assemble_thesis_document: assemble_thesis_document
  )
}

// Appendix: Notation and Glossary
#include "chapters/notation_glossary.typ"

// References
#show bibliography: set block(spacing: 1.5em)
