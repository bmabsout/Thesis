// The thesis template (design/thesis.typ), bound to the thesis's style.
#import "design/thesis.typ": make-template as _make-template
#import "style.typ": default_style
#import "commands.typ": abbrv_table

#let make_template(style: default_style()) = {
  let t = _make-template(style: style)
  t + (assemble_thesis_document: t.assemble_thesis_document.with(abbreviations: abbrv_table))
}
