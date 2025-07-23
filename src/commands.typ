#import "style.typ": *
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
#let vecor = math.or.big
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

#let make_abbrv(short, full) = (
  (short) : context box([
    #let first_check = counter(full).get().first()
    #if first_check == 0 {
      [#full (#short)#counter(full).step()]
    } else {
      link(label(short), [#short])
    }
  ]),
  (short+"_full"): link(label(short), box[#full (#short)]),
  (short+"_long"): box(full),
  (short+"_short"): link(label(short), box(short))
)


#let abbrv = (
  make_abbrv("RL", "Reinforcement Learning")+
  make_abbrv("FPL", "Fulfillment Priority Logic")+
  make_abbrv("EOE", "Encode-Optimize-Execute")+
  make_abbrv("CAPS", "Conditioning for Action Policy Smoothness")+
  make_abbrv("PID", "Proportional-Integral-Derivative")+
  make_abbrv("PPO", "Proximal Policy Optimization")+
  make_abbrv("DDPG", "Deep Deterministic Policy Gradient")+
  make_abbrv("MORL", "Multi-Objective Reinforcement Learning")+
  make_abbrv("BC", "Behavior Cloning")+
  make_abbrv("IRL", "Inverse Reinforcement Learning")+
  make_abbrv("LLM", "Large Language Model")+
  make_abbrv("STL", "Signal Temporal Logic")+
  make_abbrv("MDP", "Markov Decision Process")+
  make_abbrv("MOMDP", "Multi-Objective Markov Decision Process")+
  make_abbrv("IL", "Imitation Learning")+
  make_abbrv("IMU", "Inertial Measurement Unit")+
  make_abbrv("GPS", "Global Positioning System")+
  make_abbrv("SLAM", "Simultaneous Localization and Mapping")+
  make_abbrv("UBO", "Universal Behavioral Objective")+
  make_abbrv("UBF", "Universal Behavioral Fulfillment")+
  make_abbrv("FFT", "Fast Fourier Transform")+
  make_abbrv("MAE", "Mean Absolute Error")+
  make_abbrv("TRPO", "Trust Region Policy Optimization")+
  make_abbrv("SAC", "Soft Actor-Critic")+
  make_abbrv("RAM", "Random-Access Memory")+
  make_abbrv("SRAM", "Static Random-Access Memory")+
  make_abbrv("GPU", "Graphics Processing Unit")+
  make_abbrv("AOT", "Ahead-Of-Time")+
  make_abbrv("XLA", "Accelerated Linear Algebra")+
  make_abbrv("CCM", "Core-Coupled Memory")+
  make_abbrv("CRC", "Cyclic Redundancy Check")+
  make_abbrv("UART", "Universal Asynchronous Receiver-Transmitter")+
  make_abbrv("RF", "Radio Frequency")+
  make_abbrv("OS", "Operating System")+
  make_abbrv("TFLite", "TensorFlow Lite")+
  make_abbrv("TD3", "Twin Delayed Deep Deterministic Policy Gradient")+
  make_abbrv("DQN", "Deep Q-Network")+
  make_abbrv("Ab", "Abrasion")
)

#let abbrv_table_stroke = (
  paint: primary_gradient.sample(95%),
  thickness: 3pt,
  dash: ("dot", 6.1pt),
  cap: "round",
)

#let abbrv_table = {
  let entries = ()
  for (key, value) in abbrv {
    if key.ends-with("_short") {
      let short = key.slice(0, -6)
      let full_key = short + "_long"
      if full_key in abbrv {
        entries.push([#value #label(short)])
        entries.push([#abbrv.at(full_key)])
      }
    }
  }
  
  note(title: [Abbreviations], table(
    align: (left, left),
    columns: (0.4fr, 1fr),
    stroke:none,
    fill: (_, y) => (
      if calc.odd(y) {
        primary_gradient.sample(96%)
      }
    ),
    
    [*Abbreviation*], [*Full Form*#v(1em)],
    ..entries,
  ))
}