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
#let pmean(p) = $mu_#p$
#let vecand = math.and.big
#let loss = math.op($cal(L)$)
#let expect = math.op($EE$, limits: true)
#let todo(message) = {
  text(red, [TODO: #message])
}

#let sigmoid(x) = $phi(x)$