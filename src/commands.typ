#import "style.typ": *
#import "@local/typst-design:0.1.0" as design
#import design.rlmath: pmean, fbox, vecand, vecor, loss, expect, policy, todo, sigmoid, abbreviation-table

// The role colors as the dissertation was set: each role ramp at 55%.
#let state_color = accent1_gradient.sample(55%)
#let action_color = accent2_gradient.sample(55%)
#let reward_color = accent3_gradient.sample(55%)
#let state(body) = text(fill: state_color, $#body$)
#let action(body) = text(fill: action_color, $#body$)
#let reward(body) = text(fill: reward_color, $#body$)

#let st = state($s_t$)
#let stp1 = state($s_(t+1)$)
#let sp = state($s'$)
#let S = state($S$)
#let a = action($a$)
#let at = action($a_t$)
#let A = action($A$)
#let R = reward($R$)
#let rt = reward($r_t$)
#let Q = reward($Q$)
#let V = reward($V$)

#let stack_math(..mathes) = design.stack-math(..mathes)
#let make_abbrv = design.make-abbrv

#let abbrv = (
  make_abbrv("Ab", "Abrasion")+
  make_abbrv("AOT", "Ahead-Of-Time")+
  make_abbrv("BC", "Behavior Cloning")+
  make_abbrv("CAPS", "Conditioning for Action Policy Smoothness")+
  make_abbrv("CCM", "Core-Coupled Memory")+
  make_abbrv("CRC", "Cyclic Redundancy Check")+
  make_abbrv("DDPG", "Deep Deterministic Policy Gradient")+
  make_abbrv("DQN", "Deep Q-Network")+
  make_abbrv("EOE", "Encode-Optimize-Execute")+
  make_abbrv("FFT", "Fast Fourier Transform")+
  make_abbrv("FPL", "Fulfillment Priority Logic")+
  make_abbrv("GPS", "Global Positioning System")+
  make_abbrv("GPU", "Graphics Processing Unit")+
  make_abbrv("IL", "Imitation Learning")+
  make_abbrv("IMU", "Inertial Measurement Unit")+
  make_abbrv("IRL", "Inverse Reinforcement Learning")+
  make_abbrv("LLM", "Large Language Model")+
  make_abbrv("MAE", "Mean Absolute Error")+
  make_abbrv("MDP", "Markov Decision Process")+
  make_abbrv("MOMDP", "Multi-Objective Markov Decision Process")+
  make_abbrv("MORL", "Multi-Objective Reinforcement Learning")+
  make_abbrv("OS", "Operating System")+
  make_abbrv("PID", "Proportional-Integral-Derivative")+
  make_abbrv("PPO", "Proximal Policy Optimization")+
  make_abbrv("RAM", "Random-Access Memory")+
  make_abbrv("RF", "Radio Frequency")+
  make_abbrv("RL", "Reinforcement Learning")+
  make_abbrv("SAC", "Soft Actor-Critic")+
  make_abbrv("SLAM", "Simultaneous Localization and Mapping")+
  make_abbrv("SRAM", "Static Random-Access Memory")+
  make_abbrv("STL", "Signal Temporal Logic")+
  make_abbrv("TD3", "Twin Delayed Deep Deterministic Policy Gradient")+
  make_abbrv("TFLite", "TensorFlow Lite")+
  make_abbrv("TRPO", "Trust Region Policy Optimization")+
  make_abbrv("UART", "Universal Asynchronous Receiver-Transmitter")+
  make_abbrv("UBF", "Universal Behavioral Fulfillment")+
  make_abbrv("UBO", "Universal Behavioral Objective")+
  make_abbrv("XLA", "Accelerated Linear Algebra")
)

#let abbrv_table = if compliance == "bu" { abbreviation-table(abbrv) } else {
  note(title: [Abbreviations], abbreviation-table(abbrv, stripe: main_gradient.sample(96%)))
}
