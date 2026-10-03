#import "style.typ": *
#import "@local/typst-design:0.1.0" as design
#import design.rlmath: state, action, reward, state-color as state_color, action-color as action_color, reward-color as reward_color, pmean, fbox, vecand, vecor, loss, expect, policy, todo, sigmoid, abbreviation-table
#let (st, stp1, sp, S, a, at, A, R, rt, Q, V) = design.rlmath.rl

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

#let abbrv_table = abbreviation-table(abbrv)
