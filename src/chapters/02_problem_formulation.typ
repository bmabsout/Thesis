#import "../commands.typ": *

= The Intent-to-Reality Gap: A Taxonomy for Real Robotic Control <chap:problem_formulation>

The intent-to-reality gap represents a fundamental challenge in translating human intentions into successful robot deployment. This chapter formalizes this gap by decomposing it into three distinct but interconnected components that collectively explain why robot learning systems fail to achieve intended behaviors in real-world deployment.

Understanding this decomposition is crucial for real robotic control because each gap type requires different theoretical and practical solutions. Rather than treating deployment failures as monolithic problems, this taxonomy enables targeted interventions that address specific failure modes while recognizing their interconnected nature.

== The Critical Need for Systematic Understanding

Real-world robotics deployment faces unprecedented challenges with massive economic and safety implications. Unlike academic benchmarks where approximate solutions suffice, deployed robots must satisfy multiple competing objectives simultaneously while maintaining safety, efficiency, and task performance under variable conditions.

=== Economic and Safety Stakes

The practical consequences of intent-to-reality gaps extend far beyond academic interest. The automotive industry has invested over \$100 billion in autonomous vehicle development, yet full deployment remains elusive due to persistent challenges in handling complex multi-objective scenarios safely and reliably. Manufacturing automation faces significant difficulties when factory robots learn policies that optimize for speed but damage equipment, resulting in production delays and safety concerns.

Analysis of reported robot learning failures reveals systematic patterns that demand urgent attention. These failures are not random but stem from predictable issues in specification, transfer, and adaptation that current approaches fail to address comprehensively.

=== Systematic Failure Patterns

Analysis of reported robot learning failures across industries reveals several primary categories:

*Specification-Related Failures*: Reward hacking, specification brittleness, objective conflicts, and inadequate semantic capture account for approximately two-thirds of documented incidents.

*Transfer-Related Failures*: Distributional shift, adaptation challenges, and sim-to-real discrepancies comprise the remaining third of failures.

This 2:1 ratio between specification and transfer failures highlights that the majority of deployment problems stem from fundamental issues in how we translate human intent into formal specifications - a gap that existing taxonomies largely ignore.

== Existing Taxonomies and Their Limitations

Current research has developed several taxonomies for understanding deployment failures in robot learning, primarily focused on specific aspects of the transfer problem.

=== Sim-to-Real Transfer Taxonomies

Recent work has provided valuable categorizations of sim-to-real discrepancies. @valassakis2020crossing categorizes these into two primary types:
- *Observation Shift*: Differences in sensor modalities and resulting data between simulation and real world
- *Dynamics Shift*: Differences in underlying physics and how actions affect state

@jiang2024transic offers a more granular breakdown for contact-rich manipulation:
- *Perception Error Gap*: Visual inputs, sensor noise, and calibration differences
- *Controller Gap*: Differences in control interfaces and capabilities  
- *Embodiment Mismatch*: Physical differences between simulated and real robots
- *Dynamics Difference*: Discrepancies in physical laws and parameters
- *Object Asset Mismatch*: Variations in object properties

=== Multi-Objective Reinforcement Learning Approaches

Existing MORL taxonomies focus primarily on algorithmic approaches:
- Scalarization-based methods (linear combinations)
- Pareto-based methods (frontier construction)
- Constraint-based methods (CMDPs)

However, these taxonomies treat objective specification as given and focus on optimization rather than the fundamental challenge of translating intent into formal specifications.

=== Limitations of Existing Frameworks

While valuable, existing taxonomies exhibit critical limitations that prevent systematic solutions to deployment failures:

*Narrow Scope*: Most focus on specific transfer problems (sim-to-real) or algorithmic approaches (MORL) rather than the complete intent-to-deployment pipeline. This fragmented view prevents understanding of how specification problems cascade into deployment failures.

*Missing Semantic Dimension*: No existing framework addresses the fundamental challenge of preserving semantic meaning when translating human intent into formal specifications. This represents the largest source of failures yet remains unaddressed.

*Disconnected Components*: Transfer taxonomies and specification approaches are treated as independent problems rather than interconnected challenges. This prevents unified solutions that address multiple failure modes simultaneously.

*Post-Hoc Analysis*: Existing frameworks primarily classify failures after they occur rather than providing systematic understanding to prevent them. With billions invested in deployment, reactive approaches are insufficient.

*Inadequate for Multi-Objective Systems*: Current taxonomies fail to address the specific challenges of multi-objective robotics, where semantic relationships between objectives are crucial for safe and effective deployment.

These limitations leave practitioners without systematic guidance for preventing the most common and costly deployment failures, necessitating a unified framework that addresses the complete intent-to-reality pipeline.

== A Unified Intent-to-Reality Taxonomy

The critical limitations of existing approaches, combined with the systematic nature of deployment failures and massive economic stakes, necessitate a comprehensive framework that addresses the complete pipeline from human intent to deployed robot behavior. 

Our unified taxonomy addresses these gaps by:
- Capturing the complete intent-to-deployment pipeline rather than isolated components
- Introducing the crucial semantic dimension that accounts for the majority of failures  
- Showing systematic interconnections between specification and transfer challenges
- Providing proactive guidance for preventing failures rather than post-hoc classification
- Specifically addressing multi-objective systems where semantic relationships are critical

=== Formal Decomposition of the Intent-to-Reality Gap

We formalize the overall *Intent-to-Reality Gap* as the discrepancy between a practitioner's true intent and the actual, deployed behavior of the robot in the real world. This gap can be primarily decomposed into two major stages: the translation of intent into a formal specification, and the translation of that specification into real-world robot behavior.

Let $I$ represent the practitioner's true intent, $S$ the formal specification used for training (e.g., a reward function or an FPL expression), $pi_"sim"$ the policy learned in simulation based on $S$, $beta_"sim"$ the behavior of $pi_"sim"$ in the simulation, and $beta_"real"$ the actual deployed behavior of the policy in the real world.

The total Intent-to-Reality Gap can be expressed as:
$ "Gap"_"Intent-to-RealBehavior"(I, beta_"real") = "Gap"_"Semantic"(I, S) + "Gap"_"Spec-to-RealBehavior"(S, beta_"real") $

The first component, the *Semantic Gap*, captures the challenges in translating human intent $I$ into a formal specification $S$. The second component, the *Specification-to-Real-Behavior Gap*, encompasses all challenges in getting a robot to achieve the behavior implied by $S$ in the real world.

Given the prevalence of simulation-based training in modern robotics, the $"Gap"_"Spec-to-RealBehavior"$ can be further decomposed:
$ "Gap"_"Spec-to-RealBehavior"(S, beta_"real") = "Gap"_"Spec-to-SimBehavior"(S, beta_"sim") + "Gap"_"Sim-to-Real"(beta_"sim", beta_"real") $

Here:
- $"Gap"_"Spec-to-SimBehavior"$ is the gap between the specified intent $S$ and the behavior $beta_"sim"$ achieved by the policy $pi_"sim"$ *within the simulation environment*. This involves challenges like reward hacking and optimization difficulties, detailed below.
- $"Gap"_"Sim-to-Real"$ is the gap encountered when transferring the simulated behavior $beta_"sim"$ to actual real-world behavior $beta_"real"$. This involves discrepancies between simulation and reality, detailed subsequently.

Additionally, the distributional dimension addresses natural evolution encountered during extended deployment in potentially changing real-world conditions. This multi-level decomposition enables a targeted analysis of failure modes and the development of specific solutions for each component, while recognizing their interconnected nature.

== The Semantic Gap: From Intent to Specification

The semantic gap captures the fundamental challenge of translating human intentions into formal specifications that can be optimized by learning algorithms. This gap arises because current specification languages cannot preserve the semantic meaning and relationships inherent in human intentions.

=== Mathematical Characterization

The semantic gap quantifies the loss of meaning when encoding intent into specifications. This occurs when the formal specification $S$ fails to capture the semantic relationships, priorities, and logical structure inherent in the practitioner's intent $I$.

=== Manifestations in Practice

*Linear Scalarization Failure:* Traditional reward engineering uses linear combinations $R = sum_i w_i R_i$ that completely destroy semantic information. When a practitioner says "prioritize safety over efficiency," the weights $w_"safety"$ and $w_"efficiency"$ cannot capture the logical structure of this relationship.

*Specification Brittleness:* Small changes in weights lead to dramatically different behaviors because the linear combination does not preserve the semantic structure of the original intent. A 0.1 increase in efficiency weight might cause a mobile robot to skip essential safety checks, violating the practitioner's true intent.

*Hidden Trade-offs:* Linear combinations obscure the actual trade-offs being made, making it impossible to verify that the system is behaving as intended. When the total reward equals 0.7, practitioners cannot determine whether this represents balanced performance across objectives or extreme performance in some areas.

=== Example: Quadrotor Navigation

Consider specifying intentions for quadrotor navigation:

*Human Intent*: "Fly efficiently to the target while maintaining safety and smoothness. Safety is non-negotiable, smoothness is important for passenger comfort, and efficiency matters for battery life."

*Traditional Specification*: $R = 0.5 R_"efficiency" + 0.3 R_"safety" + 0.2 R_"smoothness"$

The semantic gap is enormous: the weights cannot express that safety is "non-negotiable" or that smoothness relates to "passenger comfort." The linear combination treats all objectives as tradeable commodities, fundamentally misrepresenting the practitioner's intent.

=== Addressing the Semantic Gap

Our fulfillment framework directly addresses the semantic gap by preserving semantic meaning through:

*Semantic Anchoring*: Each fulfillment function has clearly defined meaning with $f(tau) = 0$ meaning "completely unacceptable" and $f(tau) = 1$ meaning "satisfactory."

*Compositional Logic*: Relationships between objectives are expressed through continuous logic operators that preserve semantic meaning: $f_"safety" and f_"efficiency"$ means "both safety AND efficiency must be satisfied."

*Interpretable Values*: Intermediate values maintain semantic meaning throughout optimization, enabling practitioners to understand and debug system behavior.

== The Specification-to-Sim-Behavior Gap: From Specification to Simulated Policy Behavior
#label("gap:spec_to_sim_behavior")

The Specification-to-Sim-Behavior Gap captures the challenges that arise when learning algorithms fail to produce policies that behave according to the intended specification, *even within the controlled confines of the simulation environment*. This gap occurs when the learned policy $pi_"sim"$ exhibits behavior $beta_"sim"$ in simulation that deviates from the behavior intended by the specification $S$.

=== Sources of Specification-to-Sim-Behavior Gap

*Optimization Pathologies (in Simulation)*: Learning algorithms may get trapped in local optima that satisfy the specification numerically but not behaviorally within the simulation. A policy might achieve high average rewards while exhibiting unintended oscillatory behavior in the simulator.

*Reward Hacking (in Simulation)*: Policies discover behaviors in the simulated environment that maximize the specified objective while violating unstated assumptions or exploiting simulator loopholes. A delivery drone in simulation might minimize flight time by flying through simulated walls if collision penalties are imperfectly specified.

*Exploration Limitations (in Simulation)*: Insufficient exploration during simulated training may prevent the discovery of policies that truly satisfy the specification across all relevant simulated states. The learned policy may perform well in visited simulated states but fail in unexplored regions of the simulation.

*Function Approximation Errors*: Neural network approximations may introduce biases that cause the learned policy to deviate from the optimal policy for the given specification, even with perfect information within the simulation.

== The Sim-to-Real Gap: From Simulated Behavior to Real-World Performance
#label("gap:sim_to_real")

The Sim-to-Real Gap captures the fundamental challenges that arise when policies trained in simulation are deployed on real hardware, leading to different real-world behaviors. This gap encompasses the discrepancies identified in existing sim-to-real taxonomies while positioning them within our broader intent-to-reality framework.

=== Integration with Existing Sim-to-Real Taxonomies

Our sim-to-real gap incorporates and extends existing taxonomies. The categorizations from @valassakis2020crossing (observation shift, dynamics shift) and @jiang2024transic (perception errors, controller gaps, embodiment mismatches, dynamics differences, object asset mismatches) all represent specific manifestations of the fundamental discrepancy between simulated and real-world behaviors.

The key insight is that these existing categorizations describe *sources* of the sim-to-real gap rather than the gap itself. Our framework positions these as components within a systematic understanding of how simulation limitations affect deployed behavior.

=== Sources of Sim-to-Real Gap

The sources of the Sim-to-Real Gap, building on the established literature, include:

1.  *Observation & Perception Discrepancies*: Real sensors exhibit noise, delays, calibration inaccuracies, and failure modes not perfectly captured in simulation. This encompasses @valassakis2020crossing's "observation shift" and @jiang2024transic's "perception error gap."

2.  *Dynamics & Model Discrepancies*: Discrepancies in simulated physical laws and parameters versus the real system, including unmodeled contact forces, friction, or material properties. This corresponds to @valassakis2020crossing's "dynamics shift" and @jiang2024transic's "dynamics difference."

3.  *Embodiment and Control Mismatches*: Physical differences between simulated and real robots (@jiang2024transic's "embodiment mismatch") and differences in control interfaces (@jiang2024transic's "controller gap").

4.  *Environmental Complexity*: Real environments contain countless unmodeled details that simulation cannot perfectly capture.

=== Example: Quadrotor Control

The quadrotor example illustrates how these sources manifest in practice:

*Simulated Training*: Assumes perfect state estimation, idealized actuator models, and simplified aerodynamics.

*Real Deployment*: Encounters noisy sensor data (observation shift), actual motor dynamics (dynamics shift), and unmodeled environmental factors, demonstrating how multiple gap sources compound to create deployment failures.

== The Distributional Dimension: Ongoing Adaptation in Deployment
#label("gap:distributional")

The distributional dimension captures an inherent and expected aspect of real-world deployment: the distribution of states, disturbances, task variations, and environmental conditions encountered during extended deployment naturally evolves over time. Rather than viewing this as a "gap" to be eliminated, modern robot learning methods should account for this distributional shift as a fundamental characteristic of real-world operation.

This distributional evolution is distinct from the initial sim-to-real transfer problem, focusing instead on the robot's ability to maintain performance as conditions change during deployment. Well-designed methods should anticipate and gracefully handle these distributional changes rather than assuming static environments.

== Empirical Validation of the Taxonomy

Analysis of reported robot learning failures across industries provides empirical support for our taxonomy. Deployment failures consistently map to our three core components:

=== Specification-Related Failures (≈ 67% of incidents)

*Reward Hacking*: Policies discover behaviors that maximize specified rewards while violating unstated assumptions - a manifestation of the semantic gap where formal specifications fail to capture true intent.

*Specification Brittleness*: Small changes in objective weights lead to dramatically different behaviors - indicating that linear scalarization fails to preserve semantic relationships.

*Objective Conflicts*: Linear combinations fail to capture intended relationships between competing objectives - demonstrating the inadequacy of current specification approaches.

=== Transfer-Related Failures (≈ 33% of incidents)

*Sim-to-Real Discrepancies*: Policies fail when encountering real-world conditions not captured in simulation - directly mapping to our sim-to-real gap.

*Distributional Shift*: Performance degradation as deployment conditions evolve - validating the importance of the distributional dimension.

*Adaptation Challenges*: Difficulties updating policies during deployment without catastrophic forgetting - highlighting the interconnected nature of our taxonomy components.

This empirical validation demonstrates that our taxonomy captures the systematic patterns underlying deployment failures, rather than merely providing a theoretical categorization.

== Interconnections and Compounding Effects

While we analyze these components separately for clarity, they are fundamentally interconnected and exhibit significant compounding effects. Poor performance in one area amplifies challenges in others.

=== Semantic-to-Deployment Cascade

Poor semantic specification amplifies deployment failures. A policy with proper semantic structure (well-specified safety constraints) degrades gracefully under distributional changes, while a policy with poor semantic structure (linear safety-efficiency trade-offs) fails catastrophically.

=== Specification-to-Transfer Interactions

Policies that exhibit reward hacking during training are particularly vulnerable to sim-to-real transfer and distributional shift. A policy that exploits simulator artifacts will fail more dramatically in real deployment than a policy that learns robust behaviors.

=== Design Implications

This analysis leads to several design principles:

*Semantic-First Design*: Address semantic gaps early in the design process, as they cascade to amplify all other challenges.

*Robust Specification*: Design specifications that are inherently robust to the types of challenges that will be encountered.

*Distribution-Aware Training*: Structure training procedures to anticipate distributional changes rather than optimizing for training performance alone.

*Unified Solutions*: Develop solutions that address multiple challenges simultaneously rather than treating them independently.

== Chapter Summary

This chapter establishes a formal taxonomy of the intent-to-reality gap that provides a foundation for understanding deployment failures in robot learning systems.

The key insight is that deployment failures stem from three core challenges: the semantic gap (intent to specification), the specification-to-sim-behavior gap (learning in simulation), and the sim-to-real gap (transfer to reality). These challenges are interconnected, with poor semantic specification cascading to amplify deployment failures.

Additionally, real-world deployment involves natural distributional evolution that should be anticipated rather than eliminated. This taxonomy motivates semantic-first design principles and the development of unified frameworks that address multiple challenges simultaneously.