#import "mdp.typ" : draw_bell, draw_segment, style
#import "../src/commands.typ": *
#import "@preview/cetz:0.3.4"
#import cetz.draw: *

// Component creation functions (with their connections)
#let create_start_state(x, state_name) = {
  content((x, 0), state_name, name: "start_state", anchor: "west")
}

#let create_policy(x, state_name, action_name, source_element) = {
  group(name: "policy_" + str(x), {
    content((rel: (1.3, -0.8), to: source_element+".south"), $pi ($, name: "pi_open", anchor: "center")
    content("pi_open.east", state_name, name: "state", anchor: "west")
    content("state.east", $) ~#h(0.3em)$, name: "pi_close", anchor: "west")
    content("pi_close.east", action_name, name: "action", anchor: "west")
  })
  
  // Policy's action → Transition's action (value copying)
  bezier(
    "policy_" + str(x) + ".action.north",
    "transition_" + str(x) + ".action.south",
    (rel: (90deg, 0.2), to: "policy_" + str(x) + ".action.north"),
    (rel: (-90deg, 0.2), to: "transition_" + str(x) + ".action.south"),
    stroke: (thickness: style.stroke, paint: action_color)
  )
  
  // Source → Policy connection
  bezier(
    source_element + ".south",
    "policy_" + str(x) + ".state.north",
    (rel: (-90deg+20deg, 0.5), to: source_element + ".south"),
    (rel: (90deg+20deg, 0.5), to: "policy_" + str(x) + ".state.north"),
    stroke: (thickness: style.stroke, paint: state_color)
  )
}

#let create_transition(x, state_name, action_name, next_state_name, source_element) = {
  group(name: "transition_" + str(x), {
    content((rel: (1.5, 0), to: source_element), $TT ($, name: "t_open", anchor: "west")
    content("t_open.east", state_name, name: "state", anchor: "west")
    content("state.east", $,#h(0.1em)$, name: "comma1", anchor: "west")
    content("comma1.east", action_name, name: "action", anchor: "west")
    content("action.east", $)$, name: "t_close", anchor: "west")
    content((rel: (0.75, 0), to: "t_close.east"), next_state_name, name: "next_state", anchor: "west")
    line("t_close.east", "next_state.west", mark: (end: "triangle"),
         stroke: (thickness: style.stroke, dash: "dashed"))
  })
  
  // Source → Transition connection
  bezier(
    source_element + ".north",
    "transition_" + str(x) + ".state.north",
    (rel: (90deg-20deg, 0.6), to: source_element + ".north"),
    (rel: (90deg+20deg, 0.6), to: "transition_" + str(x) + ".state.north"),
    stroke: (thickness: style.stroke, paint: state_color)
  )
}

#let create_reward(x, state_name, action_name, next_state_name, step_index, source_element) = {
  group(name: "reward_" + str(x), {
    content((rel: (0.5, -2.5), to: source_element), reward($r_#step_index$), name: "r_value", anchor: "center")
    content("r_value.east", $#h(0.3em)=#h(0.3em)$, name: "equals", anchor: "west")
    content("equals.east", reward($R($), name: "r_open", anchor: "west")
    content("r_open.east", state_name, name: "state", anchor: "west")
    content("state.east", $,#h(0.1em)$, name: "comma1", anchor: "west")
    content("comma1.east", action_name, name: "action", anchor: "west")
    content("action.east", $,#h(0.1em)$, name: "comma2", anchor: "west")
    content("comma2.east", next_state_name, name: "next_state", anchor: "west")
    content("next_state.east", $)$, name: "r_close", anchor: "west")
  })
  
  // Transition → Reward connections (value copying)
  bezier(
    source_element + ".south",
    "reward_" + str(x) + ".state.north",
    (rel: (-90deg, 0.7), to: source_element + ".south"),
    (rel: (90deg, 0.7), to: "reward_" + str(x) + ".state.north"),
    stroke: (thickness: style.stroke, paint: state_color)
  )
  
  bezier(
    "policy_" + str(x) + ".action.south",
    "reward_" + str(x) + ".action.north",
    (rel: (-90deg, 0.5), to: "policy_" + str(x) + ".action.south"),
    (rel: (90deg, 0.5), to: "reward_" + str(x) + ".action.north"),
    stroke: (thickness: style.stroke, paint: action_color)
  )
  
  bezier(
    "transition_" + str(x) + ".next_state.south",
    "reward_" + str(x) + ".next_state.north",
    (rel: (-90deg, 0.3), to: "transition_" + str(x) + ".next_state.south"),
    (rel: (90deg, 0.3), to: "reward_" + str(x) + ".next_state.north"),
    stroke: (thickness: style.stroke, paint: state_color)
  )
}

#let create_dots(source_element) = {
  content((rel: (1.5, 0), to: source_element), $dots$, anchor: "west")
}

#let make_trajectory(num_steps: 3, with_policy: true, with_reward: true) = cetz.canvas({
  // Create all components with relative positioning
  create_start_state(0, state($s_0$))
  
  let prev_element = "start_state"
  for i in range(num_steps) {
    let step_state = state($s_#i$)
    let step_action = action($a_#i$)
    let next_state = state($s_#{i+1}$)
    
    create_transition(i, step_state, step_action, next_state, prev_element)
    if with_policy {
      create_policy(i, step_state, step_action, prev_element)
    }
    if with_reward {
      create_reward(i, step_state, step_action, next_state, i, prev_element)
    }
    
    prev_element = "transition_" + str(i) + ".next_state"
  }
  
  create_dots(prev_element)
})

