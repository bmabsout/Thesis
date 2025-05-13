#import "../lib_cv.typ": *
#let behavioral = "behavioral retention"
#let resource = "resource efficiency"

= Current Work

== Anchored Learning for On-the-Fly Adaptation <anchor-critics>
While direct on-robot training raises safety and cost concerns, making simulated training attractive, the transition from simulation to reality presents significant challenges @Muratore2022 @pmlr-v155-sandha21a.
Real-world control scenarios can generate distributions of trajectories where critical scenarios occur only in the tails.
This makes the expected discounted sum of rewards, and thus, the associated #Q\-value, an inadequate measure of agent performance across important tasks.
Recent works have identified that traditional fine-tuning approaches often result in #emph([catastrophic forgetting]), where policies lose their previously well-behaved performance when adapting to new environments @catastrophic-forgetting-wolczyk @catastrophic-forgetting-binici.
Indeed, we observed this phenomenon across every benchmark task we tested.


This challenge directly relates to #behavioral @def-retention - the ability of a policy to maintain its learned behaviors when transferred to new domains. Traditional approaches focus on average-case performance, but fail to preserve behavior in critical scenarios that occur rarely in real data but are crucial for safe operation.

We formalized this challenge through #Q\-value optimization:

==== Anchor Score
$ #reward($"O"^pi_"retention"$) = expect_(#state($s$) in #state($S_"critical"$)) [ #reward($Q^pi_"sim"$) (#state($s$), #action($a$)) | #action($a$) ~ pi(#state($s$)) ] $ <def-anchor-score>
where #reward($O_"retention"$) quantifies how well we satisfy the objective that the policy preserves behaviors learned in simulation across critical scenarios #state($S_"critical"$). We specifically use this value to "anchor" policies to the objective of satisfying good performance on critical scenarios in simulation.

==== Smoothness Loss
$ #reward($O^pi_"real"$) = pmean_0(#reward($Q^pi_"real"$), w_T/(w_T + loss_T), w_S/(w_S + loss_S), w_A/(w_A + pi^":-1")) $ <def-smooth-anchor>
where $loss_T$ and $loss_S$ are temporal and spatial smoothness terms from @temporal and @spatial, #reward($Q_pi$) is the critic's #Q\-value, $pi^":-1"$ is the pre-activation policy output, and $w_T$, $w_S$, $w_A$ are penalty thresholds that normalize the losses to [0,1]. The geometric mean ($pmean_0$) ensures all objectives must be satisfied simultaneously while maintaining the [0,1] bounds established in @def-q-norm.

This composition proved more effective for preserving smoothness during transfer, achieving:

- 47% reduction in control jerk compared to additive composition
- 52% lower power consumption on real hardware
- Maintained tracking performance within 5% of simulation baseline

==== Combined Objective
$ #reward($O^pi_"combined"$) = pmean_0 (#reward($O^pi_"real"$), #reward($O^pi_"critical"$) ) $ <def-combined-obj>
where #reward($O^pi_"combined"$) represents the overall objective that balances real-world adaptation with behavioral retention.

Building on our experience with CAPS, we also incorporate smoothness objectives multiplicatively:

This unifies our three key insights:
- Smoothness through direct policy regularization (CAPS)
- Behavioral retention through Q-value anchoring
- Objective composition through power-mean operators (AQS)

The multiplicative composition creates a natural AND relationship between objectives - both temporal and spatial smoothness must be satisfied simultaneously as well as performance on critical scenarios and performance in reality.

Thus we can preserve important behaviors learned in simulation while still allowing the policy to adapt to reality.

Another important aspect of this work is that we built an open-source system called SwaNNLake and a firmware called SwaNNFlight which enables on-board inference with efficient ground station communication for policy updates, making our approach viable for real-world applications requiring live adaptation and real-time control responses.

In this paper we show:
- 50% reduction in power consumption while maintaining stable flight
- Preservation of critical behaviors while adapting to real-world conditions
- Successful validation in both sim-to-sim and sim-to-real scenarios
- Experimental results which show how large of an issue catastrophic forgetting is even when the system dynamics are kept the same


== Algebraic Q-value Scalarization (AQS) <AQS>
Focusing specifically on the intent-to-behavior gap @def-intent-to-behavior, we developed an XRL @def-xrl  method called AQS, a novel domain-specific language that allows practitioners to express how different objectives should interact using the power-mean operator. Rather than focusing on reward engineering, AQS enables direct specification of when one objective should take priority over another based on their current satisfaction levels. Our contributions include:
1. Using the power-mean as a logical operator over normalized Q-values
2. Q-value scalarization instead of traditional reward scalarization
3. Q-value normalization for stable learning across objectives
4. Integration with a new DDPG-based algorithm called Balanced Policy Gradient (BPG)

This approach fundamentally changes how we express objectives in reinforcement learning. Rather than trying to encode complex behaviors through reward engineering, AQS encourages practioners to consider simple definitions at the reward level and composition rules at the Q-value level. This provides an intuitive language for specifying how objectives should be prioritized. For example, if one objective is nearly satisfied while another is not, AQS can naturally express that the unsatisfied objective should take priority - similar to the semantics of an AND operator, but generalized to continuous values as described in @def-pmean.

While the work in @CAPS and @anchor-critics showed the power of Q-values for preserving behaviors across domains, AQS demonstrates their potential in full generality for expressing complex objective relationships. By treating rewards as continuous constraints to be satisfied, we can then normalize #Q\-values so that we can treat them as continuous measures of objective satisfaction:

==== Q-value Normalization
$ #reward($Q_"norm"$) (#state($s$), #action($a$)) = (#Q (#state($s$), #action($a$)))/(1-gamma) $ <def-q-norm>
assuming that $forall_(#state($s$), #action($a$)),1 >= #R (#state($s$), #action($a$)) >= 0$ The normalized #Q\-value #reward($Q_"norm"$) is bounded to [0,1], representing the relative satisfaction of an objective.

This normalization enables the use of power-mean operators (see @power-mean) to express logical relationships between objectives.

Our results demonstrated comprehensive improvements across multiple dimensions. We achieved up to 600% improvement in sample efficiency compared to Soft Actor Critic, along with substantial reductions in policy variability. This reduces the need for reward engineering and speeds up the iteration loop for developing new behaviors.
