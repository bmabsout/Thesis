#import "../commands.typ": *
#import "../style.typ": *
#import "../../figures/mdp.typ": mdp
#import "../../figures/momdp.typ": momdp
#import "../../figures/transitions.typ": make_trajectory

= Background and Related Work <chap:background>

== Background <chap:background:background>

=== Reinforcement Learning <chap:background:background:rl>

==== Discrete-Time Markov Decision Processes <def:mdp>
The standard formalization in Reinforcement Learning of sequential decision making @SuttonBarto @barto2017some, defined by a tuple $(#S, #A, TT, #R, gamma)$, where:

#note(gradient: primary_gradient, title: [*Markov Decision Process*])[
  #table(
    columns: (auto, auto, auto),
    row-gutter: 2em,
    align: (right, left, left),
    stroke: none,
    column-gutter: (-0.5em, 0.5em),
    [#S], [: Set], [
      *State space*, the information we have about the world,\
      e.g. sensor readings and physical configurations
    ],
    [#A], [: Set], [
      *Action space*, the decision we can take,
      e.g. motor commands
    ], 
    [$TT$], [: #S $times$ #A $-> Delta(#S)$], [
      *Transition distribution function*,\
      e.g. the definition of (possibly stochastic) dynamics of our relevant system
    ],
    [#R], [: #S $times$ #A $times$ #S $-> RR$], [
      *Reward function*, the numerical representation of how "good" a transition is,\
      e.g. 0 if the robot falls over, 1 if it reaches the goal
    ],
    [$gamma$], [: $[0,1)$], [*Discount factor*, the decay rate of rewards],
  )
]

This abstraction captures a notion of process of moving through states in $#S$ using actions in $#A$.
==== Transitions <def:transitions>
The system _transitions_ from the current state $#st$ to the next state $#stp1$ using action $#at$. The $(#st, #at, #stp1)$ tuple is what we define as the *transition*.
==== Trajectories <def:trajectories>
A trajectory is a sequence of transitions:
#figure(
  make_trajectory(with_policy: false, with_reward: false),
  caption: $"trajectory" = ((state(s_0), action(a_0), state(s_1)), (state(s_1), action(a_1), state(s_2)), (state(s_2), action(a_2), state(s_3)), ...) $
)

==== The Memoryless Property <def:memoryless>
The key property is that the transition function $TT$ is only defined with respect to the current #state(state) and #action(action), with no _knowledge_ of the history of transitions. This property enables many of the techniques employed in RL.

==== Policies <def:policy>
A policy $pi : #S -> Delta(#A)$ defines the "decision maker", it maps states to a probability distribution over actions. For deterministic policies, this would be a function $pi : #S -> #A$.

#figure(
  mdp,
  caption: [The Markov Decision Process showing how a state #st in the state space #S and action $#at ~ pi(#st)$ determine the probability distribution $#stp1 ~ TT(#st,#at)$ over next states. Dashed arrows (#box[#{import "@preview/cetz:0.3.4"; cetz.canvas(cetz.draw.line((0,0), (0.6,0), mark: (end: "triangle"), stroke: (dash: "dashed", thickness: 0.7pt)))}]) indicate sampling from a distribution.]
)
==== Rewards <def:reward>
  The reward function $R : #S times #A times #S -> RR$ is a function that maps a transition to a real-valued reward, in RL it is our main interface for choosing which policies are better at solving the task at hand than others.
  #figure(
    make_trajectory(with_policy: true, with_reward: true),
    caption: [Transitions produced by a policy's actions results in a reward signal.]
  )

==== The Reward Hypothesis <def:reward_hypothesis>
Established in the foundational RL textbook by @SuttonBarto the hypothesis states: "all of what we mean by goals and purposes can be well thought of as maximization of the expected value of the cumulative sum of a received scalar signal." This hypothesis has provided a unifying framework for RL research, enabling the development of powerful algorithms like Q-learning, policy gradients, and actor-critic methods.


==== Returns <def:return>
The return is the discounted sum of rewards: $sum_(t=0)^infinity gamma^t rt$. The discount factor $gamma$ determines how much to prioritize immediate versus future rewards. Mapping a trajectory to a value in $RR$. The main goal in RL is to find policies that maximize the expected return. 


==== Value Functions <def:value_functions>
A #Q\-value function $#Q^pi$ represents the expected return when following policy $pi$ from state #state($s_0$) and action #action($a_0$):

$ #Q^(pi) (state(s_0), action(a_0)) = expect_#stack_math($at ~ pi(st)$, $stp1 ~ TT(st, at)$) [ sum_(t=0)^infinity gamma^t reward(R)(st, at, stp1) ] $

Similarly, a value function $#V^pi$ represents the expected return when in state #state($s_0$) and then following $pi$:

$ #V^(pi) (state(s_0)) = expect_(action(a_0) ~ pi(state(s_0))) [ #Q^(pi) (state(s_0), action(a_0)) ] $

Value functions form the basis of deep reinforcement learning @DQN_paper, capturing the specific notion of optimality emerging from the chosen reward function. They are commonly approximated by neural networks.

// ==== The Bellman Equations

// $ #V^pi (#state($s_0$)) = expect [ reward(R)(#st,#at,#stp1) + gamma #V^pi (#state($s_1$)) | #stp1 ~ TT(#st,#at), #at ~ pi(#st) ] $

// $ #Q^pi (#state($s_0$), #action($a_0$)) = reward(R)(#st,#at,#stp1) + gamma #V^pi (#state($s_1$)) $

// $ #Q^pi (#state($s_0$), #action($a_0$)) = reward(R)(#st,#at,#stp1) + gamma expect [ #Q^pi (#state($s_1$), #action($a_1$)) | #stp1 ~ TT(#st,#at), #at ~ pi(#st) ] $

==== Optimal Policy <def:optimal_policy>
A policy is considered optimal and denoted as $pi^*$ if it has the highest possible value in all states:
$forall_pi forall_(state(s) in #S) #V^(pi^*)(state(s)) >= #V^(pi)(state(s))$


=== Multi-Objective Reinforcement Learning (MORL) <chap:background:background:morl>

Multi-objective reinforcement learning extends standard MDPs with multiple reward signals simultaneously forming MOMDPs. 

==== Vector Reward Functions <def:vector_rewards>
Instead of a single scalar reward, MORL considers vector reward functions $reward(bold(arrow(R))) : S times A times S -> RR^n$ composed of $n$ reward functions $reward(bold(arrow(R)))(state(s), action(a), #sp) = (reward(R_1)(state(s), action(a), #sp), reward(R_2)(state(s), action(a), #sp), ..., reward(R_n)(state(s), action(a), #sp))$ where each $reward(R_i) : S times A times S -> RR$ represents a distinct objective @survey_seq_dec_morl @practical_guide.

  This extension fundamentally challenges the reward hypothesis in @def:reward_hypothesis, changing the optimization problem.

==== Vector Value Functions <def:vector_values>
Rather than maximizing a single expected return, the agent must now consider a vector of expected returns, making the value function a vector-value function:

$ reward(bold(arrow(V)))^(pi) (state(s)) = (reward(V_1)^(pi) (state(s)), reward(V_2)^(pi) (state(s)), ..., reward(V_n)^(pi) (state(s))) $

==== Partial Ordering <def:partial_ordering>
In the single valued case of standard MDPs, we can compare one value with another as the reals form a total order. This allows us to define the optimal policy as one forming the highest value. The multi-valued nature of MOMDPs, however, introduces a partial ordering instead. To highlight the issue consider the following example:
$#V^(pi_1)(state(s)) = (2.3, 4.5)$ and $#V^(pi_2)(state(s)) = (7.3, 6.5)$. It is clear the $pi_2$ is better than $pi_1$ on both objectives on state $s$, we can make the statement $#V^(pi_1)(state(s)) < #V^(pi_2)(state(s))$, this is known as *pareto dominance*. However, how do we judge $#V^(pi_3)(state(s)) = (1.3, 7.5)$? 

Policy $pi_3$ performs worse than $pi_1$ on the first objective but better on the second. Similarly, $pi_3$ is significantly worse than $pi_2$ on the first objective but superior on the second. Neither $pi_1$ nor $pi_2$ pareto dominates $pi_3$. This creates an incomparable relationship where we cannot definitively rank these policies without flattening the partial ordering, motivating the use of utility functions.

==== Utility Functions <def:utility_functions>
A utility function $U: RR^n -> RR$ is defined as a function that maps multi-objective returns to scalar values, flattenting the partial ordering introduced by having vector value functions, allowing us to recover optimality.

==== Linear Utilities <def:linear_utilities>
The most prevalent utility function in MORL based methods is the linear utility function, which combines objectives as weighted sums: $u_("linear")(bold(arrow(G))) = sum_(i=1)^n w_i G_i$. Using this approach, we can define flattened Q-value functions as follows:

$ #Q^(pi) (state(s_0), action(a_0)) = expect[ sum_(t=0)^infinity gamma^t sum_(i=1)^n w_i reward(r_(t,i))] = sum_(i=1)^n w_i reward(Q)_(i)^(pi) (state(s_0), action(a_0)) $

Note that linear utilitilities enjoy the property that a utility function over the rewards produces the same value as a utility function over the value functions.



==== Pareto Optimality in Policy Space <def:pareto_optimality>
MORL adapts the foundational concept of Pareto optimality to policy space. A policy $pi^*$ is Pareto optimal if no other policy $pi'$ exists such that $reward(V_i)^(pi')(state(s)) >= reward(V_i)^(pi^*)(state(s))$ for all objectives $i$ and states $s$, with strict inequality for at least one objective-state pair. The Pareto frontier represents the set of all Pareto optimal policies, providing a complete characterization of optimal trade-offs in policy space.


== Related Work <chap:background:related>

The following review is organised around the four recurring challenges that motivate this thesis.

=== Objective Specification <chap:background:related:obj_spec>

Designers must translate rich, often conflicting intentions into a reward signal that an optimiser can process.

==== Reward Design <rel:reward_design>
Reward design strategies fall into two flavours that serve distinct purposes.

+ *Reward engineering* designs the reward function itself.  The most common pattern is a weighted sum of heuristics (progress, energy, safety, constraint penalties) whose coefficients are adjusted by hand, though other handcrafted scalarisations appear.  A successful departure from simple weighting is the *tokamak plasma controller* @tokamak: seven normalised terms—shape, stability margins, coil limits, etc.—were combined with a geometric mean (rather than a weight vector) to stabilise a fusion plasma. This pattern of practitioners gravitating toward structured compositional approaches is also seen in other multi-objective domains like @radiotherapy, @pianosi2013tree, and @VERSTRAETEN2019428. In contrast, much of applied RL simply re-uses reward templates from prior papers and then tweaks the weights after eyeballing a few roll-outs; this copy-paste approach may pass benchmarks but rarely transfers or generalises.

+ *Reward shaping* tackles *optimisability* rather than preference expression.  When the true task reward is sparse (e.g. goal reached), potential-based shaping @Hu2020 introduces a dense auxiliary signal that guides exploration while provably preserving the optimal policy.  Shaping eases credit assignment but does not relieve designers from specifying their ultimate objectives.  In practice many robotics papers conflate shaping with engineering, mixing potentials and weighted preferences and thereby obscuring intent.


==== Imitation Learning <rel:imitation>
Methods that rely on behavioral demonstrations as specification act as an alternative to manual reward design and fall under the umbrella of imitation learning.

+ *Behavior Cloning* (BC) @pomerleau1989alvinn completely avoids reward engineering by framing policy learning as supervised learning, directly mapping observed states to expert actions with no reward signal.  This simplicity is attractive, but BC suffers from covariate-shift: once the learned policy visits states absent from the demonstrations, errors can compound.

+ *Inverse Reinforcement Learning* (IRL) avoids manual reward engineering by automatically inferring reward functions from expert demonstrations @inverse_rl_survey rather than requiring explicit design. The work of @ng2000algorithms established the theoretical foundations, while @abbeel2004apprenticeship demonstrated practical applications. However, IRL approaches still typically result in scalar reward functions and face challenges in multi-objective scenarios where expert demonstrations may represent complex trade-offs between competing objectives.

==== Automating Specification with Large Language Models <rel:llm_spec>
Methods such as Eureka @eureka and other similar approaches @yu2023language make use of an LLM to emit reward code, using a vision model to evaluate the adherence of the final policy to the original intentions representing in the textual description. This reduces the *manual* burden of writing and iteratively checking reward code after every run, but it merely relocates the specification problem: now the *LLM* must itself carry out the reward-engineering step, inheriting the same structural difficulties. Because this translation is intrinsically hard, success is unpredictable—some tasks work zero-shot, others fail entirely—so the fundamental challenge remains.

==== Multi-Objective Reinforcement Learning <rel:morl>
Multi-objective reinforcement learning (MORL) aims to solve problems with multiple, often competing, objectives. The dominant paradigm, known as _a-posteriori_ MORL, focuses on learning a Pareto front of optimal trade-offs, from which a user can later select a policy.

However, validation of these methods is often limited to simpler, discrete domains like Deep Sea Treasure, and they rarely address complex continuous control tasks. Common techniques include evolutionary algorithms @xu2020prediction, hypernetwork-based sampling @shu2024learning, and coverage-set methods like GPI-PD @alegre2023sample. Beyond their limited domain of application, these approaches often rely on linear scalarization, which fails to capture non-linear objective relationships @survey_seq_dec_morl, and can scale poorly with numerous objectives or large memory requirements.

==== Logical Specifications <rel:logic_spec>
A more structured approach replaces numeric weights with *compositions of predicates*, drawing from formal methods.
+ Temporal Logics such as: Signal Temporal Logic (STL) @kress2009temporal and its variants like BLTL @lahijanian2011temporal and SPECTRL @jothimurugan2019composable allow for specifying complex temporal behaviors like "eventually reach" or "always avoid." For use in learning-based control, their boolean semantics are relaxed into a continuous "robustness" metric, which creates a signed distance field around the satisfaction boundary @aksaray2016q. However, this formulation has a key limitation: the "robustness" value has a clear semantic meaning only near the zero-crossing. Far from this boundary, the logic is fundamentally discontinuous, making optimization challenging.
+ Robustification of STL and similar logics, such as the work on using the generalized mean robustness for STL @generalized_mean_robustness, "robustify" the involved logic by generalizing the underlying `min/max` operators with smooth alternatives. This allows for differentiation over the robstness value. However, these approaches still operate in the service of the original logic creating signed-distance fields that are discontinuous, inheriting the core limitation of having a discontinuous satisfaction boundary.

=== Simulation-to-Reality Transfer <chap:background:related:sim2real>

==== Robust and Smooth Control <rel:robust_control>
A primary failure mode for controllers transferred from simulation is behavioral brittleness, especially high-frequency oscillations in the control signal that lead to inefficiency and hardware damage @Sim2multi. One line of defense is to make policies inherently robust to the "reality gap". *Domain randomization* achieves this by training across a wide range of simulated dynamics @Sim2Real, though this can degrade peak performance. Similarly, robust optimization algorithms like TRPO and PPO limit the magnitude of policy updates to prevent divergence but do not specifically target smoothness.

A more direct approach is to explicitly regularize for smoothness, and these techniques have been applied at different levels of the learning process. Some approaches directly regularize the policy network to penalize sharp changes in actions with respect to state perturbations @shen2020deep. Others focus on the value function, enforcing Lipschitz continuity on the critic network to improve robustness to state noise @he2024elve. In model-based RL, similar constraints are applied to the learned dynamics model to improve multi-step prediction stability @asadi2018lipschitz. However, these methods often focus only on spatial smoothness (similar states lead to similar actions) and overlook temporal smoothness (similar subsequent actions over time), which is critical for dynamic control. This thesis introduces a regularization method that addresses both spatial and temporal smoothness directly at the policy level.

=== Mitigating Catastrophic Forgetting <chap:background:related:forgetting>
Fine-tuning with limited real data can erase behaviors learned in simulation.

Replay-based rehearsal, elastic weight consolidation and regularisation methods slow forgetting @catastrophic-forgetting-wolczyk, but still require careful task sequencing.  Conservative Policy Optimization (CPO) bounds performance drops via constraints.

=== Sample Efficiency <chap:background:related:sample_eff>
Modern model-free RL (e.g. @SAC) needs millions of transitions, prohibitive for on-hardware learning.

Ensemble critics (@REDQ, @TQC, @CrossQ) reduce variance, while model-based roll-outs (DreamerV3, MuZero) trade simulation for computation.

