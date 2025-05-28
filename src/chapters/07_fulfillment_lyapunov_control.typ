#import "../commands.typ": *

= Fulfillment-Based Lyapunov Control: A Discovery Story

The mathematical foundation for fulfillment-centric learning emerged from an unexpected source: our attempts to incorporate stability guarantees into reinforcement learning through Lyapunov functions. This chapter tells the story of how classical control theory concepts led to the discovery that generalized means provide the mathematical framework needed for continuous logic operations in robot learning.

This discovery path is important because it reveals how fulfillment-centric learning connects to established control theory while providing new insights for multi-objective optimization. The journey from Lyapunov conditions to generalized means to the broader fulfillment framework demonstrates how fundamental mathematical insights can emerge from practical engineering challenges.

*The Original Discovery*: The fulfillment framework actually originated from our work on learning controllers that satisfy Lyapunov stability conditions. We initially used penalty-based formulations with manually tuned weights ($a_1, a_2$) to balance different constraint violations, but this approach suffered from semantic loss and composition difficulties. The breakthrough came when we reformulated these penalty terms as fulfillment variables that could be composed using geometric means, eliminating the need for weight tuning while preserving the semantic meaning of each stability condition. This success in the control domain revealed the broader applicability of fulfillment-based optimization to general robotics objectives.

== From Lyapunov Conditions to Fulfillment Variables

The mathematical foundation for fulfillment-centric learning emerged from our work on incorporating stability guarantees into reinforcement learning through Lyapunov functions. This work revealed that classical control concepts could be naturally expressed as fulfillment variables, leading to the broader insight that robotics objectives are fundamentally about satisfaction rather than maximization.

=== Classical Lyapunov Theory: From Proof to Optimization

Classical control theory uses Lyapunov functions to analyze system stability. A Lyapunov function $V: RR^n -> RR_+$ provides a certificate of stability if it satisfies:

1. *Positive Definiteness*: $V(x) > 0$ for all $x != 0$ and $V(0) = 0$
2. *Negative Definiteness of Derivative*: $dot(V)(x) = nabla V(x) dot f(x) < 0$ for all $x != 0$

where $f(x)$ represents the system dynamics.

Initially, control theorists used these conditions purely for **proving** stability—to verify that a given controller would be stable. However, the field evolved to recognize that the **size of the Lyapunov region** (the region of attraction) could serve as an **optimization criterion**. Rather than just proving stability, control theorists began optimizing controllers to achieve stability with the **largest possible region of attraction**.

This evolution was crucial: it transformed Lyapunov conditions from binary proof tools ("stable or not") into **quantitative optimization objectives** ("how stable, and over what region"). This shift from proof to optimization naturally leads to treating stability as a **fulfillment variable** that can be composed with other important controller objectives like performance, efficiency, and robustness.

=== From Learning Lyapunov Control with Fulfillments

Before discovering the fulfillment treatment, we were working on a direct approach to learning controllers that satisfy Lyapunov stability conditions. The high-level idea was simple: learn good controllers, where "good" means "stable."

*Control Lyapunov Function Learning*: We sought to learn both a control Lyapunov function $V$ and a controller $u$ such that:

$ V(x) >= 0, forall x in RR^n without p, V(p) = 0 $
$ V(f(x,u)) - V(x) < 0 $

where $p$ is the desired setpoint and $f(x,u)$ represents the system dynamics.

*The CLF Loss Function*: When learning $V$ and $u$, we used $N$ samples $cal(X)$ and optimized the loss:

$ cal(L)_"CLF" = V(p)^2 + a_1 1/N sum_(x in cal(X)) [epsilon + V(f(x,u)) - V(x)]_+ + a_2 1/N sum_(x in cal(X)) [epsilon - V(x)]_+ $

where $[dot]_+ = max(dot, 0)$ is the ReLU function.

*The Core Problem*: This penalty-based formulation treated stability as a **constraint** to be satisfied rather than an **objective** to be optimized. The approach led to several fundamental issues:

1. **Penalty Balancing**: The weights $a_1, a_2$ required careful tuning to balance the different constraint violations
2. **Semantic Loss**: The combined loss obscured whether individual Lyapunov conditions were actually satisfied
3. **Hard Constraints**: The ReLU penalties created discontinuous gradients and training instability
4. **Composition Difficulty**: Adding performance objectives required additional penalty terms and more weight tuning

*Safe Controller Sets*: While we could define safe controllers as:
$ S(p) = {pi | V(f(x,pi)) - V(x) < 0} $

The penalty-based learning approach made it difficult to ensure that learned controllers actually belonged to this safe set while achieving good performance.

This mathematical foundation revealed the need for a fundamentally different approach—one that treated stability not as a constraint to be penalized, but as a **fulfillment to be satisfied** and composed with other objectives.

=== The Fulfillment Treatment

Building on the control theory evolution from proof to optimization, our key insight was to reformulate the penalty-based CLF loss as **fulfillment variables** that could be composed using continuous logic operators. Instead of penalizing constraint violations, we measured the degree to which each condition was satisfied.

*From Penalties to Fulfillments*: The CLF penalty terms were transformed into fulfillment measures:

$ f_"zero" = "fulfillment measure of" V(p) = 0 $
$ f_"large" = "fulfillment measure of" V(x) >= 0 "elsewhere" $  
$ f_"pop" = "fulfillment measure of" V(f(x,u)) - V(x) < 0 $

*Hierarchical Fulfillment Composition*: Rather than linear combination with weights $a_1, a_2$, we used nested fulfillment composition with geometric means ($p = 0$):

$ f_"lyapunov" = M_0(f_"pop", f_"large", f_"zero", f_"reg") $

where:
- $f_"pop"$: proof of performance fulfillment $V(f(x,u)) - V(x) < 0$
- $f_"large"$: large elsewhere fulfillment $V(x) >= 0$ for $x != p$  
- $f_"zero"$: zero at setpoint fulfillment $V(p) = 0$
- $f_"reg"$: Lyapunov regularization fulfillment

*Multi-Objective Controller Composition*: The Lyapunov fulfillment was then composed with other controller objectives using geometric mean composition:

$ f_"controller" = M_0(f_"tracking", f_"efficiency", f_"lyapunov", f_"regularization") $

where:
- $f_"tracking"$: close to setpoints fulfillment
- $f_"efficiency"$: small actions fulfillment
- $f_"lyapunov"$: composed Lyapunov stability fulfillment
- $f_"regularization"$: actor regularization fulfillment

This transformation eliminated the need for manual weight tuning ($a_1, a_2$) and enabled semantic preservation—we could directly monitor whether each Lyapunov condition was satisfied while achieving balanced multi-objective performance.

=== The Composition Challenge

The critical challenge emerged when we needed to compose these stability fulfillment variables with other important controller objectives. A good controller must satisfy stability requirements **and** achieve good tracking performance **and** maintain energy efficiency **and** provide robustness to disturbances.

Traditional linear combination approaches failed at multiple levels:

*Within Stability*: Even for stability alone, linear combination of the Lyapunov conditions:
$ f_"stability" = w_1 f_"positive" + w_2 f_"decreasing" $
proved inadequate because it allowed trade-offs between the conditions—a system could achieve high overall "stability" by satisfying one condition well while completely violating the other.

*Across Objectives*: When composing stability with other controller objectives:
$ f_"total" = w_1 f_"stability" + w_2 f_"tracking" + w_3 f_"efficiency" $
the linear combination destroyed the semantic meaning of each objective and allowed the controller to sacrifice stability for performance.

This led us to explore alternative composition methods that could preserve the conjunctive nature of both stability requirements and multi-objective controller design while maintaining differentiability for optimization.

== The Generalized Mean Discovery

The breakthrough came when we discovered that generalized means provide exactly the mathematical framework needed for composing fulfillment variables while preserving their semantic meaning. (The detailed mathematical properties of generalized means are established in Chapter 3; here we focus on their discovery and application to control problems.)

=== Application to Lyapunov-Based Learning

For stability, we need both positive definiteness AND negative definiteness of the derivative. Using the geometric mean ($p = 0$) from the generalized mean family:

$ f_"stability" = M_0(f_"positive", f_"decreasing") = sqrt(f_"positive" dot f_"decreasing") $

This composition ensures that stability fulfillment is only high when both conditions are satisfied, but allows for smooth optimization through the continuous nature of the geometric mean.

More importantly, this stability fulfillment can now be composed with other controller objectives:

$ f_"controller" = M_0(f_"stability", f_"tracking", f_"efficiency") $

This enables the design of controllers that achieve **all** important objectives simultaneously—they are stable **and** track well **and** are energy efficient—rather than trading off between these critical requirements.

=== Convergence Benefits

The fulfillment-based formulation with generalized mean composition provided several unexpected benefits:

1. *Faster Convergence*: By directly optimizing for condition satisfaction rather than penalty minimization, the learning process converged significantly faster.

2. *Better Stability Margins*: The composed fulfillment naturally encouraged balanced satisfaction of all conditions, leading to more robust stability certificates.

3. *Interpretable Optimization*: Practitioners could monitor individual fulfillment values to understand which conditions were limiting performance.

=== Experimental Validation

We validated this approach on quadrotor attitude control, where stability is critical for safe operation but must be balanced with tracking performance and energy efficiency. The results demonstrated the power of treating stability as a fulfillment variable that can be composed with other controller objectives:

- *50% faster convergence* compared to penalty-based approaches
- *Larger regions of attraction* for the learned Lyapunov functions  
- *More robust performance* under model uncertainties
- *Balanced multi-objective performance*: Controllers achieved good stability **and** tracking **and** efficiency simultaneously
- *No objective sacrifice*: Unlike linear scalarization, no individual objective was sacrificed for others

These results provided the first empirical evidence that fulfillment-based optimization with generalized mean composition could outperform traditional approaches while achieving the control theory goal of designing controllers that satisfy **all** important conditions for good control performance.

== From Control Theory to General Robotics

The success of generalized means in the Lyapunov context revealed their broader applicability to fulfillment-based optimization in robotics.

=== Generalizing Beyond Stability

The mathematical properties that made generalized means suitable for Lyapunov conditions apply equally well to other robotics objectives:

*Conjunctive Requirements*: Many robotics objectives require joint satisfaction rather than trade-offs. Safety AND performance, accuracy AND efficiency, speed AND smoothness.

*Semantic Preservation*: Like stability conditions, robotics objectives have individual meanings that must be preserved during optimization.

*Continuous Optimization*: Robotics applications require gradient-based optimization, necessitating continuous and differentiable composition operators.

*Robustness*: Real-world deployment requires composition methods that are robust to parameter variations and distribution shift.

=== Connection to Multi-Objective Optimization

The geometric mean has a special relationship to multi-objective optimization theory. When maximizing multiple objectives, the hypervolume indicator—one of the most important metrics in multi-objective optimization—reduces to the product of the objectives being maximized when considering a single solution.

This means that maximizing the geometric mean of fulfillment values is equivalent to maximizing the hypervolume indicator, connecting our approach to established multi-objective optimization principles.

== Practical Implementation Considerations

The practical application of generalized means in reinforcement learning requires careful attention to several implementation details.

=== Normalization for Q-Value Composition

When applying generalized means to Q-values in reinforcement learning, proper normalization is crucial to maintain the $[0,1]$ range required for logical interpretation.

For Q-values $Q_i(s,a)$ representing different objectives, we normalize as:

$ hat(Q)_i(s,a) = (Q_i(s,a) - Q_"min") / (Q_"max" - Q_"min") $

The normalization ensures compatibility with generalized mean composition:

$ Q_"composed"(s,a) = M_p(hat(Q)_1(s,a), ..., hat(Q)_n(s,a)) $

=== Numerical Stability

For extreme values of $p$, direct computation of generalized means can be numerically unstable. We provide stable implementations:

*For $p -> -infinity$*: Use $min(x_1, ..., x_n)$
*For $p -> +infinity$*: Use $max(x_1, ..., x_n)$
*For $p = 0$*: Use $(product_i x_i)^(1/n)$ in log space to avoid underflow

=== Gradient Computation

The gradient of generalized means with respect to their arguments enables efficient backpropagation:

$ (partial M_p)/(partial x_i) = cases(
  (M_p(bold(x)))^(1-p) / n dot x_i^(p-1) & "if" p != 0,
  M_0(bold(x)) / (n x_i) & "if" p = 0
) $

=== Computational Complexity

The computational complexity of evaluating generalized means is $O(n)$ where $n$ is the number of objectives, making it practical for real-time applications with moderate numbers of objectives.

== Chapter Summary

This chapter has established the mathematical foundations for fulfillment-centric learning through the discovery path from Lyapunov control to generalized means. The key contributions include:

1. *Discovery Path*: The insight that generalized means provide continuous logic emerged from Lyapunov-based control learning, where stability conditions naturally expressed as fulfillment variables.

2. *Practical Validation*: Experimental results on quadrotor control demonstrated the effectiveness of fulfillment-based optimization with generalized mean composition.

3. *Generalization*: The mathematical properties that made generalized means suitable for stability conditions apply broadly to robotics objectives requiring joint satisfaction.

4. *Implementation Guidance*: Practical considerations for normalization, numerical stability, and gradient computation enable robust implementation.

The mathematical framework established here validates the formal specification language (FPL) developed in Chapter 4, demonstrating how these insights create a principled engineering discipline based on continuous logic. 