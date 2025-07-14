#import "style.typ": accent2_gradient, accent1_gradient, accent3_gradient, accent4_gradient
// Color definitions for consistent visualization
#let state_color = accent1_gradient.sample(55%)
#let action_color = accent2_gradient.sample(55%)
#let reward_color = accent3_gradient.sample(55%)

#let state(body) = text(fill: state_color, $#body$)
#let action(body) = text(fill: action_color, $#body$)
#let reward(body) = text(fill: reward_color, $#body$)

// Define colored math variables
#let st = state($s_t$)
#let stp1 = state($s_(t+1)$)
#let S = state($S$)
#let a = action($a$)
#let at = action($a_t$)
#let A = action($A$)
#let R = reward($R$)
#let rt = reward($r_t$)
#let Q = reward($Q$)
#let V = reward($V$)
#let pmean(p) = $overline(mu)_#p$

#let fbox(p) = math.op(limits: true, box(inset: 0em, grid(line(length: 0.2em, stroke: 0.5pt), text(box(inset: 0.2em, $#p$), size: 0.75em, top-edge: "bounds", bottom-edge: "bounds"), line(length: 0.2em, stroke: 0.5pt), align: horizon+center, columns: 3), stroke: 0.5pt))

#let vecand = math.and.big
#let loss = math.op($cal(L)$)
#let expect = math.op($EE$, limits: true)
#let policy = math.op($pi$, limits: true)
#let todo(message) = {
  text(red, [TODO: #message])
}

#let sigmoid(x) = $phi(x)$

#let sp = state($s'$)

#let stack_math(..mathes) = {
  set text(size: 9pt)
  stack(dir: ttb, spacing: 1em, ..mathes)
}