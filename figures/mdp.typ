#import "@preview/cetz:0.3.4"
#import "/src/commands.typ": *
#import cetz.draw: *

#import "@local/typst-design:0.1.0": figures
#let style = figures.figure-style
#let draw_bell(pos, color: black, name: "bell") = figures.bell(cetz, pos, color: color, name: name)
#let draw_segment(pos, tick_pos: 0.5, color: black, name: "segment") = figures.segment(cetz, pos, tick_pos: tick_pos, color: color, name: name)
    
#let state = group(name: "state", {
  draw_segment((0, 0), tick_pos: 0.3, color: state_color, name: "segment")
  content("segment.west", S+h(2pt), anchor: "east")
  content("segment.tick", st+v(2pt), anchor: "south")
})

#let pi_of_st = group(name: "pi_of_st", {
  draw_bell((rel: (0, -1.4), to: "state.segment"), color: action_color)
  content((rel: (0, 0), to: "bell.west"), $pi(#st)=$, anchor: "east")
})

#let action = group(name: "action", {
  draw_segment((rel: (0, -0.9), to: "pi_of_st.bell.south-west"), tick_pos: 0.6, color: action_color, name: "segment")
  content("segment.west", A+h(2pt), anchor: "east")
  content("segment.tick", v(2pt)+at, anchor: "north")
})

#let tuple = group(name: "tuple", {
  content((rel: (0.7, 0), to: "pi_of_st.bell.east"), $TT ($, name: "open_paren", anchor: "west")
  content("open_paren.east", $#st$, name: "st", anchor: "west")
  content("st.east", $,#h(0.2em)$, name: "comma", anchor: "west")
  content("comma.east", $#at$, name: "at", anchor: "west")
  content("at.east", $)=$, name: "close_paren", anchor: "west")
})

#let transition = group(name: "transition", {
  draw_bell((rel: (1, -0.3), to: "tuple.east"), color: state_color)
})

#let new_state = group(name: "new_state", {
  draw_segment((rel: (0, -0.9), to: "transition.bell.south-west"), tick_pos: 0.4, color: state_color, name: "segment")
  content("segment.west", S+h(2pt), anchor: "east")
  content("segment.tick", stp1+v(2pt), anchor: "north")
})

#let mdp = cetz.canvas({
    // Main components
    state
    pi_of_st
    action
    tuple
    transition
    new_state
    
    // Policy arrows
    line("state.segment.tick", "pi_of_st.bell.north",
         mark: (end: "triangle"),
         stroke: (thickness: style.stroke))
    
    line("pi_of_st.bell.south", "action.segment.tick",
         mark: (end: "triangle"),
         stroke: (thickness: style.stroke, dash: "dashed"))
         
    // tuple arrows
    bezier(
      "state.segment.tick",
      "tuple.st.north",
      (rel: (-90deg+20deg, 0.9), to: "state.segment.tick"),
      (rel: (90deg+20deg, 0.9), to: "tuple.st.north"),
      stroke: (thickness: style.stroke, paint: state_color)
    )
    
    bezier(
      "action.segment.tick",
      "tuple.at.south",
      (rel: (90deg-20deg, 1), to: "action.segment.tick"),
      (rel: (-90deg-20deg, 1), to: "tuple.at.south"),
      stroke: (thickness: style.stroke, paint: action_color)
    )
    
    // Transition to new state arrow
    line("transition.bell.south", "new_state.segment.tick",
         mark: (end: "triangle"),
         stroke: (thickness: style.stroke, dash: "dashed"))
})

