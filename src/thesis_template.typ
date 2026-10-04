// The thesis template lives in the shared design system; this file binds it
// to the thesis's style.
#import "@local/typst-design:0.1.0": make-template as _make-template
#import "style.typ": default_style
#import "commands.typ": abbrv_table

#let make_template(style: default_style()) = {
  let t = _make-template(style: style)
  t + (assemble_thesis_document: t.assemble_thesis_document.with(abbreviations: abbrv_table))
}
