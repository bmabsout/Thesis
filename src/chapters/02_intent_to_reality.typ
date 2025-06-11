#import "../style.typ": note, primary_gradient

#import "../commands.typ": *
#import "../style.typ": local_outline

= The Intent-to-Reality Gap <chap:problem_formulation>

The central challenge in deploying autonomous systems is the *Intent-to-Reality Gap*: the discrepancy between a practitioner's high-level goals and the robot's final, deployed behavior. This gap is not a single problem but a cascade of interconnected challenges that arise at each stage of translation---from the encoding of human intuition into a formal specification, to the optimization of a policy in an idealized model, to the execution of that policy on real embedded hardware subject to scheduling jitter and resource constraints, and finally to the interaction with noisy sensors and unpredictable physical world.

This chapter introduces a formal taxonomy to deconstruct this gap. By dissecting it into three primary components—the *Intent-to-Specification Gap*, the *Specification-to-Behavior Gap*, and the *Simulation-to-Reality Gap*—we can systematically communicate, analyze, measure, and ultimately mitigate the distinct failure modes that prevent reliable real-world robot learning. This framework provides the conceptual foundation for the solutions developed in this thesis.

== Defining Behavior: Trajectory Sets and Decorations

Before describing the gaps, we must first formalize what we mean by "behavior". While the term is often left undefined in the literature, it is fruitful to define it precisely within the context of MDPs.

==== Behavior
We define a *behavior* $beta$ as a set of trajectories, where each trajectory $tau$ is a sequence of state-action tuples:
$ beta = { tau | tau = ((s_0, a_0), (s_1, a_1), (s_2, a_2), ...)) } $

This definition allows us to treat behavior as a formal mathematical object. The power of this approach comes from *decorating* this set with different functions, which allows us to recover many fundamental concepts in robot learning as specific instances of a more general idea:

+ *Behavioral Metrics:* By attaching a *metric* $d(beta_1, beta_2)$ to pairs of behaviors, we can quantify the difference between them. This is crucial for measuring the simulation-to-reality gap, where we compare the behavior in simulation $beta_"sim"$ to the behavior in reality $beta_"real"$. Many imitation learning approaches can be understood as minimizing different kinds of metrics between the learned policy's behavior and an expert's. Instead of simple per-action losses, modern methods minimize sophisticated trajectory-level metrics (e.g., Chamfer distance) or distributional divergences (e.g., f-divergences) to better capture behavioral similarity. #todo[Citations for trajectory-level IL metrics, e.g., Chen 2023, Ke 2020]

+ *Probabilistic Views:* By decorating a behavior with a *probability distribution* $P(tau | pi)$, we can model the likelihood of different trajectories occurring under a given policy $pi$. This perspective is the foundation of methods like Behavioral Cloning (BC), which seeks to learn a policy that reproduces the trajectory distribution from a set of expert demonstrations.

+ *Value-Centric RL:* For any non-trivial robotic task, defining the set of all "good" behaviors is computationally intractable. The dominant paradigm in Reinforcement Learning provides a powerful, practical solution to this problem. Instead of defining the set of good behaviors directly, it creates a tractable proxy: decorating each potential trajectory $tau$ with a scalar *value*, defined via a function of a transition tuple forming the expected discounted return $E[sum gamma^t r_t | tau]$. The goal of an RL algorithm is then to find a policy whose behavior $beta$ maximizes this value. This reduces the intractable problem of enumerating good behaviors to the tractable one of finding a reward function that induces the desired behavior. However, because this structure leaves the value unbounded, it provides only a *relative* measure of performance; it can tell us if one behavior is better than another, but not whether a given behavior is good or bad at following our objectives in an absolute sense.

+ *Fulfillment-Centric Design:* This thesis introduces a new decoration: the *fulfillment function* $F(beta)$. In contrast to an unbounded value, fulfillment maps a behavior to a normalized score in $[0, 1]$, capturing the degree to which it satisfies a structured, logical objective. This provides a richer, more semantically grounded representation of policy performance, enabling absolute judgments about whether a behavior is satisfactory.

By defining behavior in this way, we create a unified lens from which to analyze different methods for learning robot behavior. In the context of the gaps, it allows us to formally represent the Specification-to-Behavior and Simulation-to-Reality gaps.

== The Three Gaps: A Formal Decomposition

We can formalize the *Intent-to-Reality Gap* by treating the development pipeline as a sequence of functional transformations. This allows us to precisely define each gap as an error introduced by these transformations.

Let's define the core operators in the pipeline:
=== Operators
#note(gradient: primary_gradient)[
  #table(
    columns: (auto, auto, auto),
    row-gutter: 2em,
    align: (right, left, left),
    stroke: none,
    column-gutter: (-0.5em, 0.5em),
    `enc`, [: $I -> "Spec"$], [
      An *Encoding* operation that translates intent to specification ($ #`spec` = #`enc`\("human intent")$). Usually a human process.
    ],
    $#`opt`_"c"$, [: $"Spec" -> pi$], [
      An *Optimize* operation that takes a specification and produces a policy by optimizing within a given context $c$ ($pi = #`opt`_(c)("spec")$).
    ],
    $#`exec`_"c"$, [: $(pi) -> beta$], [
      An *Execute* operation that runs a policy in a given context $c$, producing behavior ($beta = #`exec`_c(pi)$).
    ],
  )
]

=== Example Instantiations
These abstract operators can be instantiated in different ways depending on the learning paradigm:

+ If we instantiate the `opt` operation to be RL optimization, `Spec` becomes the set of reward functions. Setting the context to a simulator, the operation is in that case the familiar RL pipeline, with $pi = #`RL`_("sim")("reward function")$.

+ If we instantiate `Spec` to be an expert behavior $beta_"expert"$, we can see how this frames the problem for imitation learning. Given that the behavior of any policy $pi$ is $beta_pi = #`exec`_("sim")(pi)$, various imitation learning algorithms can be seen as operators that minimize some behavioral divergence $d(beta_pi, beta_"expert")$ to find the optimal policy: $pi^* = #`IL`\(beta_"expert")$.

+ The `enc` operator can also be instantiated as a composition of functions. We can see this in methods like Eureka @eureka, where the high-level `enc` operation is composed of two sub-stages: a human translating their intent into a textual prompt ($"text" = #`enc`_1("intent")$), and an LLM which acts as a second encoder to produce the final specification ($"spec" = #`enc`_2("text")$).

#todo[Add a diagram of the pipeline]

This functional decomposition provides the formal foundation for our analysis.

#figure(
  todo[Add diagram visualizing the compounding errors across the three gaps.],
  caption: [The Intent-to-Reality Gap, decomposed into its three primary components. Errors introduced at each stage cascade and compound, leading to a significant divergence between the original intent and the final deployed behavior.]
)

This decomposition into three critical, interconnected gaps provides the structure for our analysis.

=== The Intent-to-Specification Gap

The *Intent-to-Specification Gap* is the semantic error from the `enc` operator. It represents the loss of fidelity when translating human intent $I$ into the formal specification `spec` and is not typically easily quantifiable. This discrepancy is arguably the most significant and least addressed challenge in robot learning. It is fundamentally an *encoding error* that arises from a mismatch between the human's mental model and the resulting mathematical representation. This error typically stems from two sources:

+ *Limited Expressivity*: The specification language itself may be too restrictive to capture the rich, nuanced, and often qualitative nature of human intent.
+ *Flawed Translation*: The practitioner may struggle to correctly or completely translate their mental model into the formal language, a difficulty that is exacerbated by languages that are not intuitive or easy to use.

*Mathematical Characterization*: This gap quantifies the loss of fidelity when encoding intent $I$ into a specification `spec`. It occurs when `spec` fails to capture the semantic relationships, priorities, and logical structure inherent in $I$. For example, a utility function $U("spec")$ derived from the specification might not be a faithful representation of the practitioner's true utility $U(I)$.

*Manifestations in Practice*:
+ *Linear Scalarization Failure:* The most common specification method, a weighted sum of reward terms ($R = sum_i w_i R_i$), is a prime example of limited expressivity. When a practitioner says "prioritize safety above efficiency," the weights $w_"safety"$ and $w_"efficiency"$ cannot capture the lexicographical nature of this relationship. They treat all objectives as linearly tradeable, fundamentally misrepresenting the intent.
+ *Specification Brittleness:* Because the semantic structure is lost in translation, small changes in specification parameters (like weights) can lead to dramatically different and unexpected behaviors. A minor tweak to an efficiency weight might cause a mobile robot to skip essential safety checks, directly violating the original intent.
+ *Obscured Trade-offs:* Poorly expressive specifications, like linear combinations, hide the true nature of the trade-offs being made, making it impossible to verify that the system is behaving as intended. A total reward of 0.7 is meaningless without understanding the underlying performance on each constituent objective.

*Example: Quadrotor Navigation*: Consider the intent: "Fly efficiently to the target while maintaining safety and smoothness. Safety is non-negotiable." A traditional specification like $R = 0.5 R_"efficiency" + 0.3 R_"safety" + 0.2 R_"smoothness"$ is semantically hollow. It fails on both fronts of the intent-to-specification gap: the language of weighted sums is not expressive enough for the hard constraint, and the chosen weights are an arbitrary translation of "efficiently" and "smoothness." Our fulfillment framework, detailed in later chapters, directly addresses this by preserving semantic meaning through compositional logic.

=== The Specification-to-Behavior Gap
#label("gap:optimization")

The *Specification-to-Behavior Gap* is the optimization error from the `opt` operator. Given a policy optimized in simulation, $pi_"sim" = #`opt`_("sim")(#`spec`)$, this gap measures how well its resulting behavior, $#`exec`_("sim")(pi_"sim")$, adheres to the original specification. This discrepancy arises when a learning algorithm fails to produce a policy that behaves according to the intended specification, *even within the controlled confines of the idealized model*. Its sources include:

*Sources of the Gap*:
+ *Optimization Pathologies*: The optimization landscape may be fraught with poor local minima. An algorithm may find a policy that is locally optimal with respect to the specification `spec` but which is behaviorally flawed (e.g., exhibits high-frequency control oscillations that are not explicitly penalized).
+ *Reward Hacking*: Policies are notorious for finding loopholes in specifications. A delivery drone in simulation might learn to minimize flight time by flying through simulated walls if collision penalties are imperfectly specified, thus achieving a high reward for a behavior that violates unstated assumptions.
+ *Exploration Limitations*: Insufficient exploration during training may prevent the discovery of the globally optimal policy. The learned policy may perform well in visited states but fail in unexplored regions of the simulation.
+ *Function Approximation Errors*: Neural networks, as universal function approximators, still introduce inherent errors and biases. The learned policy $pi_"sim"$ is an approximation of the true optimal policy $pi^ast_text("spec")$, and this approximation error contributes to the gap.

=== The Simulation-to-Reality Gap
#label("gap:reality")

The *Simulation-to-Reality Gap* is the execution error from the `exec` operator. For a policy $pi_"sim" = #`opt`_("sim")("reward")$ trained in simulation, this gap is the behavioral divergence that arises when changing the execution context from simulation to reality: $d(#`exec`_("sim")(pi_"sim"), #`exec`_("real")(pi_"sim"))$. This is the classic "sim-to-real" problem, where the core failure is that the *behavior* generated in simulation is not a perfect proxy for the *behavior* that manifests in reality. We can decompose this gap into two fundamental types of mismatch:

+ *Dynamical Mismatch*: This can be quantified by attaching a dynamical systems-based divergence to the full behaviors ($beta_"sim"$ vs. $beta_"real"$). For example this can be the difference between differential equation gains arising from system identification and the ones estimated from information about the real system. This captures model errors, as it measures differences in how the system evolves on a trajectory-by-trajectory basis.

+ *Distributional Mismatch*: This can be quantified by first flattening the behaviors to their marginal state visitation probabilities and then measuring the divergence between these distributions. This precisely defines the gap between the distributions of states encountered in simulation versus reality.

==== Sources of Dynamical Mismatch
Prior work has identified several sources of dynamical mismatch:
+ *Dynamics & Model Discrepancies*: The core of the gap lies in the differences between the simulated physics and real-world dynamics. This includes both *aleatoric* uncertainty (inherent randomness in the world) and *epistemic* uncertainty, which represents gaps in our model's knowledge such as unmodeled effects like friction, air resistance, and motor delays. These correspond to the "dynamics shift" identified by @valassakis2020crossing and @jiang2024transic.
+ *Observation & Perception Discrepancies*: Real sensors have noise, latency, and calibration errors not perfectly modeled in simulation. This is the "observation shift" or "perception error gap".
+ *Embodiment and Control Mismatches*: Physical differences between the simulated robot model and the real hardware, or differences in the control interfaces, contribute significantly to the gap.

While dynamical mismatches are a classic focus of sim-to-real transfer, the *distributional mismatch* becomes especially critical during long-term operation. The real world is not static, and an agent must be able to adapt as the distribution of tasks and conditions evolves. This problem of *ongoing adaptation* is a primary focus of this thesis, particularly in the chapter on Anchor Critics, which treats adaptation itself as a specification problem.

*Example: Quadrotor Control*: A quadrotor policy trained in a simulation that assumes perfect state estimation, idealized motor responses, and simplified aerodynamics will inevitably produce a different behavior when deployed. In the real world, it must contend with noisy IMU data and true motor dynamics (dynamical mismatches), as well as unmodeled wind gusts that change over time (a distributional mismatch). These sources compound, creating a significant simulation-to-reality gap.

== Empirical Validation and Relation to Prior Work

The taxonomy presented here is not merely theoretical; it is grounded in the systematic analysis of real-world deployment failures and provides a more comprehensive alternative to existing frameworks.

=== Empirical Validation
Our taxonomy is grounded in the systematic analysis of real-world deployment failures. While precise quantification is difficult, empirical studies of robot failures reveal patterns that align with our proposed decomposition, particularly concerning the *Specification-to-Behavior* and *Simulation-to-Reality* gaps.

These gaps manifest as failures arising from policy execution in novel environments and mismatches between simulation and reality. Research into sim-to-real transfer provides a broad catalogue of such issues, generally categorizing them into perception, dynamics, and embodiment mismatches, and shows that systematically addressing them is key to improving performance @sim-to-real-survey. More detailed frameworks for analyzing policy failures demonstrate how specific environmental configurations can trigger execution failures that were not apparent during training, reinforcing the need for a structured understanding of the specification-to-behavior pipeline @robofail.

By providing a structured decomposition, our framework helps to categorize these disparate failure modes, underscoring that the challenge of building reliable robotic systems extends far beyond just sim-to-real transfer.

=== Relation to Prior Work and Its Limitations
Existing taxonomies, while valuable, offer a fragmented view of the problem.
+ *Sim-to-Real Taxonomies*: Frameworks like those from @valassakis2020crossing and @jiang2024transic provide a granular breakdown of the sources of the *Simulation-to-Reality Gap*. However, they do not address the preceding intent-to-specification and specification-to-behavior gaps, which our analysis shows are the largest source of failures.
+ *MORL Taxonomies*: Taxonomies in Multi-Objective Reinforcement Learning focus on algorithmic approaches (e.g., scalarization-based vs. Pareto-based) but treat the objective specification as a given. They optimize the formula they are handed, without questioning if the formula correctly captures the original intent.

Our unified framework addresses these limitations by:
1.  *Capturing the Full Pipeline*: It provides an end-to-end view from intent to deployment.
2.  *Prioritizing the Intent-to-Specification Gap*: It is the first to formally identify and name the intent-to-specification gap as the primary source of failures.
3.  *Connecting the Components*: It explicitly models how the gaps are interconnected and how failures cascade through the system.
