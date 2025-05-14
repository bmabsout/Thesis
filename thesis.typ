#import "src/lib_cv.typ": primary_color, long_line, diamond, state_color, action_color, reward_color
#import "@preview/cetz:0.3.1"
#import "thesis_template.typ": (
  make_template,
  default_style,
    // Constants (if still needed directly in thesis.typ, otherwise they are used by template functions)
  BU_NAME, GRS_NAME
)

#let template = make_template(style: default_style + (
  fonts: (
    body: "Crimson Pro",
    heading: "Crimson Pro",
  ),
  font_sizes: (
    body: 12.5pt,
  ),
)
)

#let thesis_title_val = par(leading: 1em, [
  Minimizing the _#text(fill: reward_color)[Intent]-to-#text(fill: action_color)[Reality]_ Gap in Robot Learning:\
  A Fulfillment-Centric Perspective
])

#let author_name_val = "Bassel EL Mabsout"
#let submission_year_val = "2025"
#let degree_type_val = "Doctor of Philosophy"

#let prospectus_committee_val = (
  (name: "DR. RENATO MANCUSO", role: "First Reader"),
  (name: "DR. SABRINA NEUMAN", role: ""),
  (name: "DR. KATE SAENKO", role: ""),
  (name: "DR. BINGZHUO ZHONG", role: "")
)

#let approval_readers_val = (
  (ordinal: "First", name: "Dr. Renato Mancuso", academic_title: "Professor of Computer Science", institution: none),
  (ordinal: "Second", name: "Dr. Sabrina Neuman", academic_title: "Associate Professor of Computer Science", institution: none),
  (ordinal: "Third", name: "Dr. Kate Saenko", academic_title: "Professor of Computer Science", institution: none),
  (ordinal: "Fourth", name: "Dr. Bingzhuo Zhong", academic_title: "Assistant Professor of Computer Science", institution: none)
)

#let major_professors_val = (name: "Renato Mancuso, Ph.D.", title: "Professor of Computer Science")

// ===== Generate Thesis Components =====

#let title_page = (template.make_bu_title_page)(
  thesis_title_val,
  author_name_val,
  degree_type_val,
  submission_year_val,
  BU_NAME, // School name for title page
  GRS_NAME, // GRS name for title page
  degree_submission_text: "Dissertation"
)

#let copyright_page = (template.make_bu_copyright_page)(author_name_val, submission_year_val)

#let approval_page = (template.make_bu_approval_page)(approval_readers_val)

#let abstract = (template.make_bu_abstract_section)(
  thesis_title_val,
  author_name_val,
  BU_NAME, // School name for abstract
  GRS_NAME, // GRS name for abstract
  degree_type_val,
  submission_year_val,
  (template.make_major_professor_block)(major_professors_val),
  [#include "src/chapters/abstract.typ"] // Abstract body content
)

#let table_of_contents = (template.make_table_of_contents)(title: "Contents", depth: 2)

// Optional: Generate List of Figures/Tables if you have them
// #let list_of_figures = make_list_of_figures(title: "List of Figures")
// #let list_of_tables = make_list_of_tables(title: "List of Tables")

#let main_body = [
  #include "src/chapters/problem_statement.typ"
  #include "src/chapters/background.typ"
  #include "src/chapters/published_results.typ"
  #include "src/chapters/current_work.typ"
  #include "src/chapters/timeline.typ"
]

// Optional: Generate Appendices content if you have them
// #let appendices_body = [
//   #include "src/appendices/appendix_a.typ"
// ]
// #let appendices = format_appendices(appendices_body, title: "Appendices")

#let bibliography = (template.format_bibliography)("megaref.bib", options: (:), title: "References")

#let vita = (template.format_vita)([
  *Full Name:* Bassel El Mabsout \
  *Year of Birth:* XXXX \
  *Contact Address:* XXXX \
], title: "Vita")


// ===== Assemble the Document =====
#show: (template.assemble_thesis_document).with(
  // Pass metadata
  thesis_title: thesis_title_val,
  author_name: author_name_val,

  // Pass generated content blocks
  title_page: title_page,
  copyright_page: copyright_page,
  approval_page: approval_page,
  // acknowledgments: ack, // Optional, if generated
  // dedication: dedic, // Optional, if generated
  abstract: abstract,
  table_of_contents: table_of_contents,
  // list_of_figures: list_of_figures, // Optional
  // list_of_tables: list_of_tables,   // Optional
  main: main_body,
  // appendices: appendices, // Optional
  bibliography: bibliography,
  vita: vita,
)