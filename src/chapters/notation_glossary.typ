#import "../commands.typ": *

= Notation and Glossary

This appendix provides a comprehensive reference for the mathematical notation and terminology used throughout this thesis.

== Mathematical Symbols

=== General Notation

#table(
  columns: (auto, auto),
  align: (left, left),
  [*Symbol*], [*Description*],
  [$S$], [State space],
  [$A$], [Action space],
  [$s, s'$], [Current and next states],
  [$a$], [Action],
  [$pi$], [Policy function: $S -> A$],
  [$pi^*$], [Optimal policy],
  [$gamma$], [Discount factor, a value between 0 and 1],
  [$tau$], [Trajectory: sequence of states and actions],
  [$theta$], [Policy parameters (e.g., neural network weights)],
  [$expect[dot]$], [Expectation operator],
  [$n$], [Number of objectives],
  [$t$], [Time step],
  [$bold(x)$], [Bold denotes vector quantities],
  [$RR$], [Real numbers],
  [$RR_+$], [Non-negative real numbers],
  [$Delta$], [Distribution over a set],
  [$cal(L)$], [Loss function, what we are minimizing],
  [$EE$], [Expectation over a random variable],
)

=== Fulfillment-Specific Notation

#table(
  columns: (auto, auto),
  align: (left, left),
  [*Symbol*], [*Description*],
  [$f_i$], [Fulfillment function for objective $i$, $f_i: S times A times S -> [0,1]$],
  [$f$], [Composed fulfillment value],
  [$arrow(f)$], [Vector of fulfillment values $(f_1, ..., f_n)$],
  [$M_p$], [Generalized mean with parameter $p$],
  [$u(phi)$], [Fulfillment value of FPL formula $phi$],
  [$"FQ"_i$], [Fulfillment Q-value for objective $i$],
  [$Q_Psi$], [Source domain Q-values (anchor critics)],
  [$Q_pi$], [Target domain Q-values],
  [$w_Psi$], [Priority weight for source domain],
)

=== FPL Operators

#table(
  columns: (auto, auto, auto),
  align: (left, left, left),
  [*Symbol*], [*Name*], [*Description*],
  [$and_p$], [Conjunction], [AND operator with parameter $p <= 0$ (typically)],
  [$or_p$], [Disjunction], [OR operator, derived from $and_p$ via De Morgan's laws ($not(not phi_1 and_p not phi_2)$), thus uses the same $p$ (typically $p <= 0$) as the $and_p$ in its definition. Note: Generalized mean $M_q$ with $q >= 1$ can also directly produce OR-like semantics but is distinct from FPL's $or_p$ definition.],
  [$not$], [Negation], [Logical NOT: $not phi = 1 - u(phi)$],
  [$[phi]_delta$], [Priority offset], [Offset operator with $delta in [-1,1]$],
  [$tack$], [Turnstile], [Type judgment: $Gamma tack phi : tau$],
)

=== Power Mean Parameters

#table(
  columns: (auto, auto, auto),
  align: (left, left, left),
  [*Parameter*], [*Name*], [*Semantic Interpretation*],
  [$p -> -infinity$], [Minimum], [Strict AND (all must be satisfied)],
  [$p = -2$], [Harmonic mean], [Conservative AND],
  [$p = -1$], [Harmonic mean], [Conservative AND],
  [$p = 0$], [Geometric mean], [Balanced AND],
  [$p = 1$], [Arithmetic mean], [Linear combination],
  [$p = 2$], [Quadratic mean], [Optimistic OR],
  [$p -> +infinity$], [Maximum], [Strict OR (any can be satisfied)],
)

=== CAPS Notation

#table(
  columns: (auto, auto),
  align: (left, left),
  [*Symbol*], [*Description*],
  [$L_T$], [Temporal smoothness loss],
  [$L_S$], [Spatial smoothness loss],
  [$lambda_T$], [Temporal regularization weight],
  [$lambda_S$], [Spatial regularization weight],
  [$D_T$], [Temporal distance measure],
  [$D_S$], [Spatial distance measure],
  [$"Sm"$], [Smoothness metric (mean weighted normalized frequency)],
)

== Key Terms and Concepts

=== Core Concepts

*Fulfillment Function*: A mathematical function that quantifies the degree to which a specific objective is satisfied, mapping a relevant set of inputs (which could include states, actions, trajectories, policy parameters, etc.) to a value in $[0,1]$. This value, the *fulfillment*, represents the level of satisfaction, where 0 indicates complete failure and 1 indicates complete satisfaction. Fulfillment functions serve as a *semantic bridge* by translating high-level intentions into these quantifiable values.

*Fulfillment Reward Function*: A specific type of fulfillment function, typically denoted $f_i: S times A times S -> [0,1]$, that provides a per-timestep fulfillment value based on the current state, action, and next state. These values, sometimes called *fulfillment rewards* or *immediate fulfillments*, are analogous to rewards in traditional RL and form the basis for calculating Fulfillment Q-values (FQs). For instance, $f_"smoothness"(s,a,s') = 0.8$ means "this specific transition yields 80% of the desired smoothness."

*Semantic Bridge*: The property that fulfillment functions (especially Fulfillment Reward Functions when used in an RL context) preserve the natural meaning of objectives throughout the optimization process, enabling practitioners to specify their true intentions directly while maintaining mathematical rigor for optimization.

*Fulfillment*: The degree to which an objective is satisfied, represented as a value in $[0,1]$ where 0 indicates complete failure and 1 indicates complete satisfaction. Unlike traditional rewards, fulfillment values maintain their individual semantic meaning when composed.

*Intent-to-Reality Gap*: The discrepancy between what practitioners intend their robots to do and what they actually learn to do, consisting of both expressivity and deployment components. Stems from the semantic mismatch between human requirements and machine optimization.

*Semantic Preservation*: The property that individual objective meanings are maintained throughout the learning process, enabling interpretability and debugging. Contrasts with traditional linear scalarization which destroys individual semantic information.

*Continuous Logic*: A mathematical framework that extends Boolean logic to continuous values in [0,1], enabling smooth reasoning about partial constraint satisfaction while preserving semantic relationships between objectives.

*Deployment Crisis*: The fundamental challenge that learned policies fail to maintain performance when transferred from training to deployment environments.

=== Objective Taxonomy

*Objective*: Any quantity that can be included in an optimization scheme, regardless of its relationship to robot behavior or domain specificity. This includes regularization terms, computational constraints, and meta-objectives.

*Behavioral Objective*: A subset of objectives that directly relate to the controller's actions and resulting robot behavior in the environment. These have clear semantic meaning in terms of robot performance and can be observed in state-action trajectories.

*Universal Behavioral Objective (UBO)*: A subset of behavioral objectives that are desirable across virtually all robotics applications, transcending specific tasks or domains. Examples include smoothness, stability, basic safety, and robustness.

*Universal Behavioral Fulfillment (UBF)*: The quantified degree of satisfaction, typically on a scale of $[0,1]$, of a Universal Behavioral Objective. UBFs result from applying a fulfillment function to a UBO.

*Architectural Integration*: The design principle of encoding universal behavioral objectives directly into policy architectures rather than requiring explicit specification in reward functions or FPL formulas. This is often a preferred method for promoting high UBFs.

=== Theoretical Components

*Minimum Fulfillment Bound*: The guarantee that achieving a certain composed fulfillment value ensures minimum satisfaction levels for all individual objectives.

*Power Mean Conservation*: The property that improvements in one objective can be traded against reductions in another while maintaining the same overall fulfillment.

=== Framework Components

*Fulfillment Priority Logic (FPL)*: A formal language for expressing complex objective relationships using continuous logic operators based on generalized means.

*Balanced Policy Gradient (BPG)*: The algorithmic implementation that optimizes FPL specifications through FQ-value composition.

*CAPS (Conditioning for Action Policy Smoothness)*: Architectural integration of universal behavioral objectives through policy regularization.

*Anchor Critics*: Multi-fulfillment adaptation framework that preserves source domain behaviors during target domain adaptation.

*SwaNNFlight*: Open-source firmware enabling live neural network updates during quadrotor flight operations.

=== Mathematical Properties

*Idempotence*: The property that $M_p(x, x, ..., x) = x$ for any $p$ and $x$.

*Monotonicity*: The property that improving any input improves the output.

*Range Preservation*: The property that outputs remain in $[0,1]$ when inputs are in $[0,1]$.

*Differentiability*: The property enabling gradient-based optimization.

== Acronyms

#table(
  columns: (auto, auto),
  align: (left, left),
  [*Acronym*], [*Full Form*],
  [BPG], [Balanced Policy Gradient],
  [CAPS], [Conditioning for Action Policy Smoothness],
  [CSP], [Constraint Satisfaction Problem],
  [DDPG], [Deep Deterministic Policy Gradient],
  [FPL], [Fulfillment Priority Logic],
  [FQ], [Fulfillment Q-value],
  [LTL], [Linear Temporal Logic],
  [MAE], [Mean Absolute Error],
  [MORL], [Multi-Objective Reinforcement Learning],
  [PPO], [Proximal Policy Optimization],
  [RL], [Reinforcement Learning],
  [SAC], [Soft Actor-Critic],
  [STL], [Signal Temporal Logic],
  [TD3], [Twin Delayed Deep Deterministic Policy Gradient],
  [TLTL], [Truncated Linear Temporal Logic],
  [UBO], [Universal Behavioral Objective],
  [IRL], [Inverse Reinforcement Learning],
  [LLM], [Large Language Model],
  [MCDM], [Multi-Criteria Decision Making],
  [MDP], [Markov Decision Process],
  [NSGA-II], [Non-dominated Sorting Genetic Algorithm II],
)

== Common Usage Examples

*Fulfillment Composition*:
$ f_"total" = M_0(f_"safety", f_"performance", f_"efficiency") $

*FPL Formula*:
$ phi = "safety" and_(-infinity) ("tracking" and_0 "smoothness") $

*FQ-Value Update*:
$ "FQ"_i(s,a) arrow.l r_i + gamma "FQ"_i(s', pi(s')) $

*Anchor Critics Objective*:
$ J_"adapt" = Q_pi(s_T, pi(s_T)) and^0 (Q_Psi(s_S, pi(s_S))^(w_Psi)) $

*CAPS Regularization*:
$ J_theta^"CAPS" = J_theta - lambda_T L_T - lambda_S L_S $ 