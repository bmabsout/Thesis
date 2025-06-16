#import "../commands.typ": *
#import "../style.typ": *

= Encoding Intent with fulfillments <chap:encoding_intentionality>

== Introduction <chap:encoding_intentionality:intro>
This chapter addresses the *intent-to-specification gap* (first defined in @chap:intent_to_reality:gaps:intent_to_spec): the challenge of translating a human's high-level goal into a formal specification that a machine can optimize. At its core, this gap arises from a fundamental mismatch. Humans think in terms of _requirements to be satisfied_---"the robot must move smoothly," "the drone must not crash"---while traditional machine learning frameworks think in terms of _scores to be maximized_. The process of converting nuanced, semantic requirements into a single, scalar reward function is often brittle, counter-intuitive, and the primary cause of "reward hacking," where an agent achieves a high score without fulfilling the human's actual intent. As motivated by @def:reward_eng_as_optimizer, it is important for the language we use for describing intent to be one where expressing one's intent is made easier. 

This chapter introduces a framework designed to bridge this gap. We start by formalizing the concept of a *fulfillment function*, a mapping from any relevant aspect of the world to an interpretable $[0,1]$ value representing the degree of satisfaction with an objective. We then introduce *fulfillment Priority Logic* (FPL), a formal language that uses the mathematical foundation of the generalized mean to compose these individual fulfillment values. FPL allows a designer to express complex, hierarchical, and non-linear relationships between objectives in a way that preserves their semantic meaning, moving beyond the limitations of simple weighted sums. By doing so, we transform intent specification from a dark art of reward tuning into a principled engineering discipline.

== fulfillments <chap:encoding_intentionality:fulfillments>

=== Formalizing Intuitive Judgment <chap:encoding_intentionality:formalize>
The core of our framework is the *fulfillment function*. A fulfillment function, $f$, is any mapping from a set of relevant system variables, $X$, to a continuous value in the range $[0,1]$:
$ f: X -> [0,1] $
This value represents the degree to which a specific objective is satisfied. A value of $1.0$ represents perfect fulfillment, while a value of $0.0$ represents complete failure. In the context of reinforcement learning, we often define these as *fulfillment Reward Functions* that map a state-action transition to a fulfillment value: $f(state(s), action(a), #sp) -> [0,1]$.

The key principle is *semantic alignment*: the function's output should align with the human designer's intuitive judgment. If a designer observes a behavior and judges it to be "about 70% successful," the corresponding fulfillment function should output a value close to 0.7.


=== Examples <chap:encoding_intentionality:examples>
- *Safety fulfillment*: For an autonomous vehicle, a safety fulfillment function might map the distance to the nearest obstacle, $d$, to a fulfillment value.
  $ f_"safety"(d) = "saturate"((d - d_"min") / (d_"safe" - d_"min")) $
  Here, any distance below $d_"min"$ results in a fulfillment of 0, any distance above $d_"safe"$ results in a fulfillment of 1, and the value is linearly interpolated in between.

- *Smoothness fulfillment*: For a robot arm, a smoothness objective could be defined as the negative exponential of the joint acceleration, $theta$.
  $ f_"smoothness"(theta) = exp(-lambda ||theta||^2) $
  Small accelerations result in a fulfillment near 1, while large, jerky accelerations result in a fulfillment near 0.

=== Important Properties for a Logic of Differentiable Objectives <chap:encoding_intentionality:properties>
Once individual objectives are defined as fulfillment functions, we need a way to compose them. We posit that a logical system for composing fulfillments should possess several key properties to be intuitive and effective:

- *Idempotence*: Composing an objective with itself should not change its value. A system where $"safety" and "safety"$ is not equivalent to $"safety"$ is counter-intuitive.
- *Monotonicity*: Improving the fulfillment of one objective should never cause the overall fulfillment to decrease.
- *Range Preservation*: The result of any composition must remain an interpretable value in the $[0,1]$ range as it must remain type safe within the space of the logic.
- *Differentiability*: The logic must be differentiable, allowing for gradient-based optimization.
- *Semantic Preservation*: The logic must preserve the semantic meaning of the connectors between objectives, therefore, at the limits it should generalized boolean logic.

These desired properties are precisely what motivate the use of the generalized mean as the foundation for FPL, as we will show in the next section.

== fulfillment Priority Logic (FPL) <chap:encoding_intentionality:fpl>

=== The Generalized Mean As a Logic Operator <chap:encoding_intentionality:generalized_mean>

The power of FPL comes from its use of the *generalized mean* (or power mean) as the basis for its logical operators. For a set of fulfillment values $f_1, ..., f_n$, the generalized mean is defined as:

$ pmean(p)(f_1, ..., f_n) = (1/n sum_(i=1)^n f_i^p)^(1/p) $ <eq:generalized-mean>

The parameter $p$ continuously tunes the behavior of the mean, allowing it to represent a spectrum of logical operations:

#align(center)[
#table(
  stroke: (thickness: 0.4pt),
  columns: (auto, auto, auto),
  inset: 1em,
  align: horizon,
  [*Parameter*], [*Name*], [*Operation*],
  [$p -> -infinity$], [Minimum], $min(x_1, ..., x_n)$,
  [$p = -1$], [Harmonic Mean], $n/(sum_(i=1)^n 1/x_i)$,
  [$p = 0$], [Geometric Mean], $(product_(i=1)^n x_i)^(1/n)$,
  [$p = 1$], [Arithmetic Mean], $1/n sum_(i=1)^n x_i$,
  [$p -> infinity$], [Maximum], $max(x_1, ..., x_n)$
)
]

The generalized mean enjoys several key properties that make it ideal for fulfillment composition:
==== Range Preservation <def:range_preservation>
$ forall_i x_i in [0,1] => pmean(p)(x_1, ..., x_n) in [min(x_1, ..., x_n), max(x_1, ..., x_n)] subset [0,1] $
This ensures that the composed fulfillment value always remains within the valid and interpretable $[0,1]$ range.

==== Monotonicity in Values <def:monotonicity_values>
$ forall_i x_i <= y_i => pmean(p)(x_1, ..., x_n) <= pmean(p)(y_1, ..., y_n) $
This property guarantees that improving an individual fulfillment value will never harm the overall composition, ensuring predictable behavior.

==== Monotonicity in Parameter <def:monotonicity_parameter>
$ p < q => pmean(p)(x_1, ..., x_n) <= pmean(q)(x_1, ..., x_n) $
The parameter $p$ provides a continuous lever to adjust the logical operator, smoothly transitioning from pessimistic (low $p$, like AND) to optimistic (high $p$, like OR).

==== Idempotence <def:idempotence>
$ pmean(p)(x, ..., x) = x $
This means that composing an objective with itself doesn't change its value, a crucial property for avoiding the counter-intuitive behavior seen in some systems like fuzzy logic where $x and x = x^2$.

==== Continuity <def:continuity>
The generalized mean is continuous with respect to both its arguments $x_i$ and its parameter $p$.

- *Continuity in Arguments*: For a fixed parameter $p$, the function is continuous in its arguments.
  $ forall_(p in RR, bold(arrow(x)), bold(arrow(x))' in RR^(n+), epsilon in RR^+), exists_(delta > 0) space "s.t." space ||bold(arrow(x))' - bold(arrow(x))|| < delta => |pmean(p)(bold(arrow(x))') - pmean(p)(bold(arrow(x)))| < epsilon $

- *Continuity in Parameter*: For a fixed set of arguments $bold(arrow(x))$, the function is continuous in its parameter $p$.
  $ forall_(bold(arrow(x)) in RR^(n+), p, p' in RR, epsilon in RR^+), exists_(delta > 0) space "s.t." space |p' - p| < delta => |pmean(p')(bold(arrow(x))) - pmean(p)(bold(arrow(x)))| < epsilon $

This joint continuity is essential for stable, gradient-based optimization, ensuring that small adjustments to either fulfillment values or the logical operator itself lead to smooth, predictable changes in the composed objective.


=== Formal Definition: Syntax and Semantics <chap:encoding_intentionality:formal>
==== Syntax <def:fpl_syntax>
The syntax of FPL formulas is defined by the following grammar:

$ phi ::= f | phi and_p phi | phi or_p phi | not phi | [phi]_delta $

where:
- $f$ is a base fulfillment value in $[0,1]$.
- $p$ is the parameter for the generalized mean, with $p <= 0$.
- $not$ is logical negation.
- $[phi]_delta$ is the priority offset operator, with $delta in [-1,1]$.

This grammar provides the building blocks for expressing complex yet well-defined objective relationships.

==== Semantics <def:fpl_semantics>
The semantics of FPL define how each operator transforms fulfillment values. We define an evaluation function $u$ that maps an FPL formula $phi$ to its fulfillment value $u(phi) in [0,1]$.

#note(title: [*FPL Semantics*])[
  #table(
    columns: (auto, auto),
    row-gutter: 2em,
    align: (right, left),
    stroke: none,
    column-gutter: (0.5em),

    $and_p$,
    [$u(phi_1 and_p phi_2) := pmean(p)(u(phi_1), u(phi_2))$\
      A *Conjunction* that combines two fulfillment values with AND-like semantics. The parameter $p$ tunes the pessimism of the operator, with lower values corresponding to a stricter AND.
    ],

    $or_p$,
    [$u(phi_1 or_p phi_2) := 1 - pmean(p)(1-u(phi_1), 1-u(phi_2))$\
      A *Disjunction* that combines two fulfillment values with OR-like semantics. It is defined via the De Morgan law.
    ],

    $not$,
    [$u(not phi) := 1 - u(phi)$\
      A *Negation* that inverts a fulfillment value. Perfect fulfillment becomes zero, and vice-versa.
    ],

    $[...]_delta$,
    [$u([phi]_delta) := (u(phi) + max(delta,0))/(1+delta)$\
      A *Priority Offset* that changes the perceived fulfillment of an objective. This is used to give one objective priority over another lexicographically.
    ],
  )
]
=== Theoretical Guarantees <chap:encoding_intentionality:guarantees>

The mathematical properties of the generalized mean provide FPL with several strong theoretical guarantees. These ensure that specifications behave in a predictable and interpretable manner.

==== Semantic Preservation <def:semantic_preservation>

The most fundamental guarantee is that of semantic preservation, which follows directly from the monotonicity property of the generalized mean. It ensures that the optimization process is always coherent.

#theorem( title: [Semantic Preservation])[
  
  For any FPL formula $phi$ evaluated with fulfillment values $bold(arrow(f))$, improving any individual fulfillment value $f_i$ while keeping others constant will result in a monotonic improvement of the overall composed fulfillment $u(phi)$.
  $
  forall i: f_i <= f'_i ==> u(phi(..., f_i, ...)) <= u(phi(..., f'_i, ...))
  $
] <thm:semantic-preservation>

This guarantee is critical: it ensures that the process of optimizing an individual objective never unexpectedly harms the overall goal. An agent can greedily improve any single aspect of its task with the confidence that it is not acting against its overall objective.

==== Minimum fulfillment Bounds <def:min_fulfillment_bounds>

For conjunctive compositions, FPL provides a powerful guarantee about the minimum level of fulfillment for all objectives. @thm:semantic-preservation

#theorem( title: [Minimum fulfillment Bound])[

  For a composition of $n$ fulfillment values $bold(arrow(f))$, achieving an overall fulfillment of $y = pmean(p)(bold(arrow(f)))$ guarantees that the fulfillment of every individual objective $f_i$ is at least:
  $
  min_i f_i >= (n y^p - n + 1)^(1/p)
  $
] <thm:min-fulfillment-bound>

This theorem provides a concrete, quantifiable link between the overall performance and the worst-case performance of any single objective. It allows a designer to set a target for the composed fulfillment, $y$, and derive a strict lower bound on the performance of all constituent parts. For example, if a robot achieves 90% overall fulfillment on a task composed with $p=-1$, this theorem can provide a guaranteed minimum fulfillment for the safety objective. The proof of this theorem lies in the @fpl2025 paper.

=== Example Specifications <chap:encoding_intentionality:example_specs>

To build intuition for how FPL translates high-level intent into precise, computable formulas, we present two common scenarios from robotics.

==== Safety-First Composition <def:safety_first_composition>
A common requirement is to enforce a strict safety constraint while optimizing for other performance metrics. For example: "The robot must always remain safe, and, conditioned on being safe, it should balance tracking a target and moving smoothly."

This translates directly into an FPL formula:

$ phi = "safety" and_(-infinity) ["tracking" and_0 "smoothness"]_0.5 $

Here's the breakdown:
- The inner term, `["tracking" and_0 "smoothness"]_0.5`, composes the two performance objectives and then applies a priority offset.
- According to the semantics, this offset term will always evaluate to a value in the range $[1/3, 1]$, since its minimum value is $(0 + 0.5) / 1.5 = 1/3$.
- The outer $and_(-infinity)$ is the minimum operator. This means that if the `safety` fulfillment drops below $1/3$, it becomes the sole bottleneck for the entire expression, effectively creating a critical safety threshold.

==== Lexicographical-Style Priorities <def:lexicographical_priorities>
The priority offset operator, $[phi]_delta$, allows for specifying "soft" priorities. It boosts the baseline fulfillment of an objective, ensuring it is prioritized. For instance: "Prioritize tracking performance, but also try to be efficient."

We can express this using a priority offset on the tracking objective:
$ phi = ["tracking"]_(0.2) and_(-1) "efficiency" $

The breakdown:
- The $["tracking"]_(0.2)$ term gives the tracking objective a baseline fulfillment of $0.2 / (1+0.2) approx 0.167$. This means even if the raw tracking fulfillment is 0, it contributes a small positive value to the composition.
- The $and_(-1)$ (harmonic mean) creates a conservative trade-off. Because of the priority offset, the `efficiency` objective only becomes influential once the `tracking` objective is already well-fulfilled.

==== Optimistic Signals <def:optimistic_signals>
Sometimes, an agent has multiple ways to achieve a goal, and success in any one of them is sufficient. This is common in systems with redundant components or multiple valid solutions. The FPL $or$ operator is designed for these scenarios.

Consider a robot equipped with two independent localization systems: a satellite-based GPS and a vision-based SLAM system. The robot is considered well-localized if *either* system is confident. We can express this as:

$ phi_"localization" = "gps" or_0 "slam" $

Here's the breakdown:
- If the GPS has a strong signal ($"gps" = 0.95$) but the camera is occluded ($"slam" = 0.1$), the overall fulfillment $u(phi_"localization") approx 0.79$. The robot correctly assesses that it is well-localized.
- This allows the agent to opportunistically rely on whichever system is performing better at any given moment, without being penalized for the poor performance of the other.

This sub-formula can then be part of a larger objective, such as navigating to a goal:
$ phi_"total" = phi_"localization" and_0 "navigate_to_goal" $

=== Semantic Calibration vs. Compositional Priority <chap:encoding_intentionality:calibration>

FPL provides two fundamentally different types of refinements to specifications. Understanding their distinction is crucial for effective specification design.

==== Semantic Calibration of Individual Fulfillments <def:semantic_calibration>

Sometimes a fulfillment function correctly identifies what to measure but doesn't quite capture your intended mapping from performance to satisfaction. A *calibration function* is any monotonic function $g: [0,1] -> [0,1]$ that preserves the range—that is, $g(0) = 0$ and $g(1) = 1$. Such functions recalibrate the meaning of intermediate values while maintaining the interpretation that 0 means complete failure and 1 means perfect satisfaction.

Exponentiation ($f^w$) is a particularly useful calibration function because:
- It preserves the range for any $w > 0$
- It's parameterized by a single intuitive "strictness" parameter
- It's smooth and differentiable everywhere

The key insight is that calibration transforms *what fulfillment values mean for a single objective* without changing the fundamental bounds of satisfaction.

==== Compositional Priority via Offset <def:compositional_priority>

The priority offset operator $[phi]_delta$ is fundamentally different—it explicitly *breaks* range preservation. The transformation $u([phi]_delta) = (u(phi) + max(delta,0))/(1+delta)$ creates a new minimum value of $delta/(1+delta)$ when $u(phi) = 0$. This is not a bug but the entire point: by changing the baseline, we create compositional priority.

This range violation is what enables soft lexicographic ordering. When two objectives have low fulfillment, the offset one maintains a higher baseline contribution, causing the optimizer to focus on the non-offset objective first. Unlike calibration, this is inherently about *relationships between objectives*.

==== Orthogonal Mechanisms in Practice <def:orthogonal_mechanisms>

These mechanisms serve distinct purposes and are often combined:

$ phi = [f_"tracking"^2]_(0.2) and_(-1) f_"efficiency"^(0.5) $

Here:
- The exponents (2 and 0.5) are calibrations that preserve range while adjusting strictness
- The offset (0.2) breaks range preservation to establish priority

This separation—range-preserving semantic calibration versus range-breaking compositional priority—provides the mathematical clarity needed to express complex intents within the logic.

== Building an Optimizer for FPL Specifications <chap:encoding_intentionality:optimizer>

A formal language for specifying intent is only useful if we can build an agent that optimizes for it. The key insight of our approach is to apply FPL composition not to the immediate fulfillment rewards, but to their expected long-term values. This allows the agent to reason about and make complex temporal trade-offs, such as sacrificing immediate fulfillment for a greater long-term outcome. This section introduces the core components for building such an optimizer.

=== fulfillment Q-Values ($f$Q-Values) <chap:encoding_intentionality:optimizer:fq_values>

In standard reinforcement learning, a Q-value represents the expected, discounted, cumulative future reward. We introduce a direct analogue for fulfillments: the *fulfillment Q-Value*, or $f$Q-Value. For a given objective $i$, its $f$Q-Value is the expected, discounted, cumulative future fulfillment.

Formally, for a policy $pi$, the $f$Q-Value for objective $i$ is:
$ f"Q"_i^(pi)(state(s_0), action(a_0)) = expect_#stack_math($at ~ pi(st)$, $stp1 ~ TT(st, at)$) [sum_(t=0)^infinity gamma^t f_(i)(st, at, stp1)](1-gamma) $
where $f_(i)(st, at, stp1)$ is the immediate fulfillment reward from the transition at time $t$.

Since fulfillment rewards are in $[0,1]$, the raw Q-value lies in $[0, 1/(1-gamma)]$. To turn them into $f$Q-values, which are in $[0,1]$, we normalize them by dividing by $1/(1-gamma)$ as $1/(1-gamma)$ is the maximum possible value of the raw Q-value when the reward is bounded by 1.

These $f$Q-values, $bold(arrow(f"Q"))(s,a)$, represent a vector of fulfillments one for objective $i$ and can be used directly as a base fulfillment values in an FPL formula.
$  f_phi = u_(phi)(bold(arrow(f"Q"))(s,a)) $



=== The Balanced Policy Gradient (BPG) Algorithm <chap:encoding_intentionality:optimizer:bpg_algorithm>

The Balanced Policy Gradient (BPG) algorithm is our implementation of the $#`opt`$ operator, which takes an FPL specification $phi$ and produces a policy $pi$ that fulfills it. It extends the Deep Deterministic Policy Gradient (DDPG) framework, using a single critic network that outputs a vector of $f$Q-values. A key feature of BPG is a novel regularization method to combat overestimation bias.

#algorithm(title: [Balanced Policy Gradient (BPG)])[
  + *Critic Update*: The critic is updated by minimizing the combined loss $L$:
  $
  L = L_("TD") + alpha_(f"V") L_(f"V")
  $

  + *Composition*: The vector of learned $f$Q-values is composed using the FPL formula $phi$:
  $
  f_phi = u_(phi)(bold(arrow(f"Q"))(s,a))
  $

  + *Actor Update*: The deterministic actor is updated using the policy gradient of the batch's root mean square composed $f_phi$, $J$:
  $
  J = pmean(2)(f_phi)
  $
]

The critic's loss function, $L$, is composed of two key parts. The first is a standard multi-dimensional Temporal Difference (TD) loss, which serves as the primary learning signal:
$
L_("TD") = pmean(2)(bold(y)^"TD" - bold(f"Q")(state(s), action(a)))
$
The second component is our fulfillment value regularization loss, $L_(f"V")$. This is a supervised loss that compares the critic's prediction to the observed, discounted fulfillment returns ($f"V"_"obs"$) stored in the replay buffer. These observed returns are calculated from the rollouts and serve as a conservative, experience-based target to counteract overestimation bias.
$
L_(f"V") = pmean(2)(f"V"_("obs") - bold(f"Q")(state(s), action(a)))
$
This regularization term combats overestimation bias, which is particularly harmful when composing objectives based on their values. By separating objective learning (in the critic) from composition (in the actor update), BPG allows the agent to learn the long-term consequences of its actions for each objective *before* considering the trade-offs specified by the FPL formula, leading to more stable and sample-efficient learning.

== Empirical Validation <chap:encoding_intentionality:bpg_empirical_validation>

We conducted a comprehensive empirical evaluation of BPG across multiple continuous control environments from the Farama-Foundation Gymnasium benchmark suite. Our evaluation assesses two primary aspects: (1) the sample efficiency of BPG compared to state-of-the-art algorithms, and (2) its ability to prevent the kind of "reward hacking" that often emerges from poorly specified reward functions.

It is important to note that while BPG is trained using an FPL specification derived from the environment's objectives, its performance is evaluated using the original scalar reward function of the environment. This ensures a fair comparison against baselines and demonstrates that the structured, semantic approach of FPL generalizes to improved performance on conventional metrics.

=== Benchmark Performance and Sample Efficiency <chap:encoding_intentionality:bpg_empirical_validation:benchmark_performance>

Our results show that BPG achieves significant improvements in sample efficiency over its baseline (DDPG) and other state-of-the-art methods like SAC, TQC, and CrossQ.

- *LunarLanderContinuous-v2*: BPG reaches the performance threshold 6.4x faster than DDPG and 1.8x faster than the prior state-of-the-art, CrossQ.
- *Hopper-v4*: BPG achieves a 5.6x speedup over DDPG and a 2.4x speedup over CrossQ.
- *Pendulum-v1* & *Reacher-v4*: BPG demonstrates similar or superior performance, including a 2x speedup over CrossQ in Pendulum.

#figure(
  image("/figures/violin_plots_timesteps.svg", width: 100%),
  caption: [Sample efficiency comparison across benchmark environments. Violin plots show the distribution of timesteps required to reach performance thresholds across 10 random seeds. The red horizontal line separates seeds failing to reach the threshold. BPG consistently requires fewer samples with lower variance.]
) <fig:fpl_violin_plots>

#figure(
  image("/figures/progress_plots.svg", width: 100%),
  caption: [Learning curves showing smoothed training progress of rewards versus environment steps for each algorithm. Shaded regions represent standard deviation across seeds, and dashed lines indicate reward thresholds for each environment. BPG demonstrates steeper learning curves and more consistent improvement.]
) <fig:fpl_progress_plots>

=== Behavioral Analysis: Preventing Reward Hacking <chap:encoding_intentionality:bpg_empirical_validation:behavioral_analysis>

A key advantage of FPL is its ability to mitigate "reward hacking," where an agent finds a loophole in the reward function to achieve a high score without accomplishing the intended task. Standard reward functions often suffer from semantic ambiguity, where different behaviors can produce identical scores.

The Hopper-v4 environment provides a classic example. An agent can achieve a moderate reward by learning to stand perfectly still, which exploits a loophole in the "aliveness" bonus without achieving the intended goal of forward locomotion.

BPG, guided by a proper FPL specification, avoids this trap. The FPL formula requires fulfillment of forward progress for *all* limbs. The "standing still" behavior, while not explicitly penalized, yields a near-zero fulfillment value because it fails to satisfy this conjunctive requirement.

#table(
  columns: 3,
  align: center,
  inset: 1em,
  [*Metric*], [*With FPL (BPG)*], [*Without FPL (DDPG)*],
  
  [_FPL Value ($phi_"hopper"$)_], [0.625], [0.194],
  [_Hopper Reward_], [2288.80], [750.35],
)

The table above shows the performance of BPG with and without an FPL specification after 48k steps. While the DDPG agent achieves a respectable reward of ~750, much of this comes from learning to stand still. The BPG agent, guided by FPL, achieves a much higher reward because it correctly learns to hop forward, demonstrating that the semantically precise specification led to the desired behavior.

=== Empirical Examples <chap:encoding_intentionality:bpg_empirical_validation:empirical_examples>

A core tenet of FPL is that it simplifies the process of reward engineering. By focusing on the semantics of each objective rather than their relative weights, a practitioner can create more robust and interpretable specifications. Below, we compare the original, hand-tuned reward functions from several benchmark environments to their FPL counterparts.

==== Pendulum-v1 <def:pendulum_example>

#table(
  columns: 2,
  align: center,
  inset: 1em,
  [*Original Reward*], [*FPL Specification*],
  [
    $ -theta^2 - 0.1 dot(theta)^2 - 0.001 "torque"^2 $
  ],
  [
    $ F_"angle"^2 and_p F_"actuation" $
  ],
)

The original reward is a finely-tuned weighted sum. In contrast, the FPL specification clearly states the two objectives: stay upright ($F_"angle"$, squared for emphasis) and minimize effort ($F_"actuation"$). The conjunctive operator $and_p$ (with $p=0$ or $p=-1$) creates a direct trade-off without brittle weighting factors.

==== Reacher-v4 <def:reacher_example>

#table(
  columns: 2,
  align: center,
  inset: 1em,
  [*Original Reward*], [*FPL Specification*],
  [
    $ -"distance" - 0.1||"torque"||^2 $
  ],
  [
    $ F_"distance"^2 and_p (vecand_(p)bold(arrow(F))_"torque") $
  ],
)

Here again, the FPL specification is clearer. The primary objective is to minimize the distance to the target ($F_"distance"$, squared for emphasis). The secondary objective is to minimize the torque on all joints, which is expressed by applying a nested conjunctive operator to the vector of torque fulfillments, $bold(arrow(F))_"torque"$.

==== Hopper-v4 <def:hopper_example>

#table(
  columns: 2,
  align: center,
  inset: 1em,
  [*Original Reward*], [*FPL Specification*],
  [
    $ 1 + (d x)/(d t) - 0.001 ||"action"||_2^2 $
  ],
  [
    $ (vecand_(p) bold(arrow(F))_"speed") and_p (vecand_(p)bold(arrow(F))_"action") $
  ],
)

For Hopper, the intent is to move forward quickly while minimizing actuation effort. The FPL spec captures this by composing two vector-level fulfillments. The first, $vecand_p(bold(arrow(F))_"speed")$, ensures all limbs are contributing to forward velocity. The second, $vecand_p(bold(arrow(F))_"action")$, ensures the actuation of all joints is minimized. This is what prevents the reward hacking behavior of standing still.

==== LunarLanderContinuous-v2 <def:lunarlander_example>

#table(
  columns: 2,
  align: center,
  inset: 1em,
  [*Original Reward*], [*FPL Specification*],
  [
    A complex, hand-tuned sum of distance, velocity, angle, leg contact, engine penalties, and terminal rewards.
  ],
  [
    #set text(size: 0.8em)
    $vecand_(p)(F_"near", [F_"very_near"]_0.1,[F_"legs"]_0.1, [F_"landed"]_0.1, [F_"fuel"]_0.5 )$
  ],
)

The original LunarLander reward is notoriously complex and difficult to interpret. The FPL specification, however, lays out a clear, hierarchical set of priorities. The priority offsets create a natural curriculum: the agent first learns to get close ($F_"near"$), then focuses on the more precise actions of getting very close, touching down, and landing successfully. Finally, once the primary landing objectives are being met, it learns to optimize for fuel. The top-level conjunction ensures all objectives must ultimately be satisfied.

==== General Locomotion Tasks <def:general_locomotion>

The pattern seen in Hopper-v4 generalizes across most MuJoCo locomotion tasks, such as `HalfCheetah-v4`, `Walker2d-v4`, and `Ant-v4`. The core intent is always to move forward while maintaining efficiency and stability.

#table(
  columns: 1,
  align: center,
  inset: 1em,
  [
    $ F_"forward" and_p vecand_(p)(bold(arrow(F))_"ctrl_cost") $
  ],
)

The standard approach is to subtract a control cost from a forward reward, requiring careful tuning of the control cost coefficient. The FPL specification is more direct: it defines a conjunctive relationship between moving forward ($F_"forward"$) and minimizing the control cost of each actuator ($vecand_(p)bold(arrow(F))_"ctrl_cost"$). This structure consistently produces forward progression across various agent morphologies without the need for environment-specific weight tuning.

== A Hitchhiker's Guide to Fulfillment <chap:encoding_intentionality:fulfillment_guide>

Applying fulfillment-style thinking transforms reward engineering from an art into a principled, two-phase process. The cornerstone of this methodology is the *separation of concerns*: first, you must validate that your individual fulfillment functions correctly capture your semantic intent for each objective in isolation. Only then should you compose them and optimize for the combined behavior. This guide provides a practical walkthrough of this process.

=== Phase 1: Capturing Intent for a Single Objective <chap:encoding_intentionality:fulfillment_guide:phase1>

The goal of this phase is to create and validate a fulfillment reward function, $f_(i)(s,a,s')$, for each of your objectives, $O_i$. At the end of this phase, you should have high confidence that the resulting fulfillment value, $f"V"_i$, accurately reflects your intuitive assessment of performance for that single objective.

==== Step 1: Define the Semantic Mapping <def:guide_phase1_step1_semantic_mapping>
Before writing any code, clearly articulate what you mean by an objective. For an objective like "smoothness":
- What does 100% smooth behavior look like for one timestep? (e.g., zero change in control action)
- What does 0% smooth behavior look like? (e.g., a control change so large it would damage the hardware)
- How do intermediate behaviors map to the $[0,1]$ range? Is the mapping linear, exponential, sigmoidal? For smoothness, an exponential decay is often a good fit. For safety margins, a sigmoid is often appropriate.

==== Step 2: Implement the fulfillment Reward Function <def:guide_phase1_step2_implement>
Translate your semantic map into a function $f_(i)(s,a,s') -> [0,1]$. This function should be stateless and only consider the information within a single transition.

==== Step 3: Validate with a Single-Objective Agent <def:guide_phase1_step3_validate>
This is the most critical step. *Before* attempting to solve your full multi-objective problem, validate each fulfillment function in isolation.
1.  Create a single-objective agent that learns to optimize *only* for $f_i$.
2.  Train this agent. Its purpose is not to solve the final task, but to act as a validation tool for your fulfillment function.
3.  Monitor the learned fulfillment Value, $f"V"_i$, which represents the agent's expected long-term satisfaction for that objective.
4.  Ask the key question: *Does the behavior of the agent align with the learned $f"V"_i$?* If the agent learns a policy that achieves an average $f"V"_"smoothness" = 0.8$, does its behavior look "80% smooth" to you? If $f"V"_"safety" = 0.3$, does it look unacceptably dangerous?
5.  If there is a mismatch, your fulfillment reward function is not correctly capturing your intent. Go back to Step 1 and refine the function's parameters or shape until the learned value and observed behavior align with your intuition.

Repeat this process for every objective. It is a debugging cycle that isolates the semantic definition of an objective from the exponential complexity of multi-objective trade-offs.

==== Step 4: Calibrate if Necessary <def:guide_phase1_step4_calibrate>
After validation, you may find that while your fulfillment function correctly identifies what to measure, the numerical mapping doesn't quite match your intuition. For instance, behaviors you judge as "moderately good" might yield fulfillment values that are too high (e.g., 0.8 when you feel they should be 0.5).

This is where *calibration* comes in. Apply a calibration function like exponentiation to adjust the strictness:
- If fulfillments feel too generous, use $f^w$ with $w > 1$ (e.g., $f^2$ makes it harder to achieve high fulfillment)
- If fulfillments feel too harsh, use $f^w$ with $w < 1$ (e.g., $f^{0.5}$ makes moderate performance more satisfying)

The key is that calibration preserves the endpoints (0 remains complete failure, 1 remains perfect success) while adjusting the mapping in between. This is purely about single-objective semantics—you're refining what the numbers mean for this objective alone.

=== Phase 2: Composing fulfillments and Optimizing Behavior <chap:encoding_intentionality:fulfillment_guide:phase2>

Once you have a set of validated fulfillment functions that you trust, you can proceed to the composition phase.

==== Step 1: Define the Semantic Relationships <def:guide_phase2_step1_relationships>
Consider how your objectives relate to one another.
- Is one a hard constraint? (e.g., "safety must always be satisfied") -> This implies a strict AND, $and_(-infinity)$.
- Do they represent a balanced trade-off? (e.g., "balance speed and efficiency") -> This implies a balanced AND, $and_0$.
- Is one a clear priority? (e.g., "prioritize tracking, but also be efficient") -> This implies a priority offset, `["tracking"]_delta and_p "efficiency"`.
- Are they alternative paths to success? (e.g., "use GPS or SLAM for localization") -> This implies an OR, $or_p$.

Note the distinction from calibration: Priority offsets change *which objectives get attention first* in a composition, while calibration (done in Phase 1) changes *what fulfillment values mean* for individual objectives. Both may appear in your final formula, serving their distinct purposes.

==== Step 2: Construct the FPL Formula <def:guide_phase2_step2_construct>
Translate these semantic relationships into an FPL formula using the operators discussed in this chapter. It is best practice to start with a simple composition and add complexity iteratively.

==== Step 3: Train the Multi-Objective Agent <def:guide_phase2_step3_train>
With the FPL formula defined, train the full BPG agent. The agent will learn individual $f"Q"$-values for each of your validated objectives and then use the FPL formula to compose them for its actor update, as described in the BPG algorithm.

==== Step 4: Debug via Interpretable Components <def:guide_phase2_step4_debug>
If the final behavior is not what you intended, you can now debug with confidence. Because you validated each fulfillment in Phase 1, you can trust the meaning of each individual $f"Q"$-value. By monitoring the learned $f"Q"$-values during training, you can directly see what trade-offs the agent is making.

For example, you might observe that the agent is achieving a low `f"Q"_"tracking"` and a high `f"Q"_"efficiency"`. Since you know what both of those values mean in terms of behavior, you can immediately diagnose the problem: your FPL formula is encouraging the agent to sacrifice too much tracking for efficiency. The solution is to adjust the FPL formula—perhaps by changing the `p`-parameter or adding a priority offset—not to go back and blindly tune reward weights.

=== Implementation Note: Numerical Stability <chap:encoding_intentionality:fulfillment_guide:numerical_stability>
A naive implementation of the generalized mean, $pmean(p)(bold(f)) = (1/n sum f_i^p)^(1/p)$, is prone to numerical instability in practice. Two main issues arise:
1.  *Infinite Gradients*: For any $p < 1$, the gradient with respect to an input $f_i$ involves the term $f_i^(p-1)$. If $f_i$ is zero, this term becomes infinite, causing training to fail.
2.  *Overflow/Underflow*: When inputs $f_i$ are far from 1 or when $|p|$ is large, the exponentiation $f_i^p$ can easily result in values that exceed the representational capacity of floating-point numbers (overflow) or become indistinguishable from zero (underflow).

A robust implementation must address both issues. This is typically done with two techniques: *input shifting* to handle gradients at zero, and *input scaling* to prevent overflow.

*Input Shifting with Slack:*
To prevent infinite gradients, we shift all inputs by a small positive constant, $epsilon$ (i.e., `slack`). The mean is then computed on the shifted values, and the slack is subtracted from the final result. The effective computation becomes:
$ y' = pmean(p)(f_1+epsilon, ..., f_n+epsilon) - epsilon $
This ensures that the base of any exponentiation is strictly positive. While this introduces a small approximation, we can prove that this operation still respects the critical range-preservation property.

#theorem(title: [Range Preservation of Slacked Mean])[
  The slacked generalized mean computation, $y' = pmean(p)(bold(f)+epsilon) - epsilon$, produces a result that is guaranteed to be within the range of the original inputs, $[min(bold(f)), max(bold(f))]$.


  _Proof._ The standard range preservation property states that for any vector $bold(x)$, $min(bold(x)) <= pmean(p)(bold(x)) <= max(bold(x))$. Let our input vector to the mean be $bold(x) = bold(f) + epsilon$.
    
  Therefore, we have:
  $ min(bold(f)+epsilon) <= pmean(p)(bold(f)+epsilon) <= max(bold(f)+epsilon) $
  This is equivalent to:
  $ min(bold(f)) + epsilon <= pmean(p)(bold(f)+epsilon) <= max(bold(f)) + epsilon $
  Subtracting $epsilon$ from all parts of the inequality yields:
  $ min(bold(f)) <= pmean(p)(bold(f)+epsilon) - epsilon <= max(bold(f)) $
  Thus, the result $y'$ is bounded by the minimum and maximum of the original inputs.
] <thm:range-preservation>

  *Input Scaling for Stability:*
  To prevent overflow and underflow, we can leverage the homogeneity property of the generalized mean: $pmean(p)(c dot bold(f)) = c dot pmean(p)(bold(f))$. By choosing a scaling constant $C$ (the `stabilizer`), we can compute the mean on a rescaled version of the inputs and then scale the result back.
  $ pmean(p)(bold(f)) = C dot pmean(p)(bold(f)/C) $
  If we choose $C$ to be $max(bold(f))$ or $min(bold(f))$, the inputs to the internal mean, $f_i/C$, will be clustered around 1.0, which is the safest range for exponentiation. A robust implementation combines both shifting and scaling.

== Related Work <chap:encoding_intentionality:related_work>
=== Linear Scalarization <chap:encoding_intentionality:related_work:linear_scalarization>
The most common method for handling multiple objectives in reinforcement learning is *linear scalarization*, where the total reward is a weighted sum of individual objective rewards: $R_"total" = sum_i w_i R_i$. This corresponds to using the arithmetic mean ($p=1$) in our framework.

While simple, this approach has two critical flaws. First, it is well-known that linear scalarization cannot find solutions in non-convex regions of the Pareto front @Limitations_of_Scalarisation, meaning entire classes of optimal trade-offs are inaccessible. Second, and more importantly, it fails on expressivity. While it is idempotent and differentiable, it represents only a single point in the spectrum of possible logical compositions and cannot express the rich, non-linear relationships like prioritization or conditional objectives that are core to human intent. The weights $w_i$ lack clear semantic meaning and are notoriously brittle, often requiring extensive, environment-specific tuning.

=== Robustifications of Existing Logics <chap:encoding_intentionality:related_work:robust_logics>
Formal methods, particularly temporal logics like Linear Temporal Logic (LTL) and Signal Temporal Logic (STL) @Belta_Temporal, provide a rich, mathematically rigorous way to specify complex behaviors over time. However, their application in gradient-based reinforcement learning has been limited because their discrete, boolean semantics are not differentiable.

Recent work has begun to bridge this gap by creating robustness measures for these logics, where satisfaction forms a signed distance field. However, these approaches face a dilemma. To maintain formal soundness with the original logic, their semantics often rely on non-differentiable `min` and `max` operators. To achieve differentiability, they must resort to smooth approximations (like log-sum-exp), but these approximations break the strict logical equivalence and sacrifice soundness. Even work that uses specific mean operators for this purpose, like the arithmetic-geometric mean @mehdipour2019arithmetic or even the generalized power mean itself @generalized_mean_robustness, does so in service of this signed-distance semantic. More fundamentally, the logic itself is designed around the zero-crossing where a state transitions from unsatisfying to satisfying. This concept of a hard boundary is discontinuous, and it means the "robustness" value has a clear meaning near the boundary but loses its semantic power far from it.

FPL avoids this issue entirely. Instead of defining satisfaction relative to a boundary, fulfillment is defined over the continuous $[0,1]$ range, where every value has a consistent semantic meaning. This makes it inherently more suitable for gradient-based methods and avoids the soundness-differentiability trade-off that plagues robustified temporal logics.

=== Fuzzy Logic <chap:encoding_intentionality:related_work:fuzzy_logic>
Fuzzy logic also extends boolean operators to the continuous $[0,1]$ domain, but it addresses a fundamentally different question. Fuzzy logic is concerned with *uncertainty of membership*—for example, "To what degree is this object a member of the set 'tall'?" In contrast, FPL is concerned with *preference and satisfaction*— "To what degree are we satisfied with the robot's performance on the 'tracking' objective?"

This conceptual distinction leads to different mathematical properties, and fuzzy logic's t-norm operators @tnorm force a trade-off between our desired criteria. Operators like the *minimum t-norm* (`min(x,y)`) are idempotent but not differentiable. Conversely, operators like the *product t-norm* (`x*y`) are differentiable but fail the idempotence property ($x and x = x^2$). FPL's use of the generalized mean is unique in that it satisfies both idempotence and differentiability simultaneously across its parameter range.

=== Continuous logic <chap:encoding_intentionality:related_work:continuous_logic>
The term "continuous logic" also refers to a specific subfield of model theory that focuses on extending first-order logic to continuous-valued structures. The primary goal of this field is to preserve formal properties like compactness and completeness for the purpose of mathematical analysis. While it shares the name, its purpose is distinct from FPL's. FPL is an engineering tool designed to create practical, optimizable specifications for agent behavior. As such, continuous logic does not prioritize differentiability, which is a critical requirement for our use case of gradient-based optimization.

=== Probabilistic Reasoning <chap:encoding_intentionality:related_work:probabilistic_reasoning>
While both FPL and probability theory operate on values in $[0,1]$, their interpretation of these values is fundamentally different. In probability theory, a value represents the *likelihood of an event occurring*. In FPL, it represents the *degree of satisfaction* with a current state or action.

This leads to different composition rules. The probabilistic "AND" for independent events is multiplication, which is not idempotent ($P(A) and P(A) = P(A)^2$). This violates a core intuitive requirement for composing objectives: combining a fulfillment with itself should not change the level of satisfaction. While conceptually distinct, the two frameworks are not mutually exclusive; one could imagine a system where FPL operates on fulfillment values that are themselves expectations of a probabilistic model.
