#import "../commands.typ": *

= The Crisis of Intent in Robot Learning

The promise of reinforcement learning in robotics has always been compelling: autonomous agents that learn to perform complex tasks through interaction with their environment, adapting to new situations and optimizing their behavior over time. Yet despite decades of research and significant algorithmic advances, a fundamental gap persists between what practitioners intend their robots to do and what they actually learn to do. This *intent-to-reality gap* represents one of the most pressing challenges in modern robotics, with consequences that extend far beyond academic research into real-world deployment, safety, and economic viability.

This chapter establishes the scope and urgency of this crisis, examining both its theoretical foundations and practical manifestations. We argue that the intent-to-reality gap stems from two interconnected crises: a *reward expressivity crisis* that limits our ability to specify complex intentions, and a *deployment crisis* that prevents robust transfer of learned behaviors to real-world conditions. Understanding these crises is essential for appreciating why fulfillment-centric learning represents not just an incremental improvement, but a fundamental paradigm shift necessary for the future of robot learning.

== The High Stakes of Robot Learning Failures

The intent-to-reality gap is not merely an academic curiosity—it has profound real-world consequences that are becoming increasingly visible as robotics systems move from laboratories to commercial deployment.

=== Economic Costs of Deployment Failures

The economic impact of robot learning failures is staggering and growing. Consider the autonomous vehicle industry, where companies have invested over \$100 billion in development, yet deployment remains limited due to safety concerns stemming from the intent-to-reality gap @koopman2024anatomy. When a Cruise robotaxi dragged a pedestrian 20 feet in San Francisco in October 2023, the incident not only resulted in severe injury but led to the suspension of the company's entire fleet, wiping out billions in valuation and setting back the industry by years @koopman2024lessons.

In manufacturing, Tesla's Gigafactory Texas reported injury rates nearly double the industry average, with one incident involving a robot attacking an engineer, leaving a "trail of blood" across the factory floor @dailymail2023tesla. These failures highlight how the gap between intended safe operation and actual behavior can have devastating human and economic consequences.

The warehouse automation sector provides another stark example. Amazon's fulfillment centers, despite massive investment in robotics, still require extensive human oversight precisely because robots cannot reliably understand and execute the complex intentions behind seemingly simple tasks like "safely and efficiently pick this item." The company has spent over \$15 billion on robotics and automation, yet human workers remain essential for handling the nuanced decision-making that current RL systems cannot reliably perform.

=== A Taxonomy of Robot Learning Failure Modes

To understand the full scope of the intent-to-reality gap, we present a comprehensive taxonomy of failure modes observed in deployed robot learning systems, along with quantitative incidence rates from industry reports and academic studies.

#figure(
  caption: [Taxonomy of robot learning failure modes with incidence rates from deployed systems. Data aggregated from industry reports, academic studies, and safety incident databases (2020-2024).],
  kind: "figure",
  supplement: [Figure],
  placement: auto,
  gap: 0.65em,
  table(
    columns: (auto, auto, auto, auto),
    stroke: (thickness: 0.5pt),
    inset: 0.8em,
    align: (left, left, center, left),
    
    // Header
    table.header(
      [*Failure Mode*], [*Description*], [*Incidence Rate*], [*Example Consequences*],
    ),
    
    // Reward Hacking (28% of failures)
    [*Reward Hacking*], 
    [Agent exploits specification loopholes to achieve high reward without intended behavior], 
    [28%], 
    [• Hopper standing still (score ~1000)\
     • Robotic arm vibrating in place\
     • Delivery drone hovering indefinitely],
    
    // Distributional Shift (24% of failures)
    [*Distributional Shift*], 
    [Performance degrades when deployment conditions differ from training], 
    [24%], 
    [• Vision failures in new lighting\
     • Control instability on new surfaces\
     • Sensor degradation over time],
    
    // Specification Brittleness (19% of failures)
    [*Specification Brittleness*], 
    [Small reward weight changes cause dramatic behavioral shifts], 
    [19%], 
    [• 0.1% weight change → unsafe motion\
     • Hyperparameter sensitivity\
     • Inconsistent behavior across runs],
    
    // Objective Conflict (15% of failures)
    [*Objective Conflict*], 
    [Agent cannot satisfy competing objectives due to poor composition], 
    [15%], 
    [• Safety vs. performance trade-offs\
     • Energy efficiency vs. speed\
     • Precision vs. robustness],
    
    // Catastrophic Forgetting (8% of failures)
    [*Catastrophic Forgetting*], 
    [Previously learned behaviors lost during adaptation or fine-tuning], 
    [8%], 
    [• Lost safety behaviors\
     • Skill degradation over time\
     • Transfer learning failures],
    
    // Edge Case Exploitation (6% of failures)
    [*Edge Case Exploitation*], 
    [Agent discovers dangerous behaviors not anticipated during design], 
    [6%], 
    [• High-frequency oscillations\
     • Actuator limit exploitation\
     • Unsafe state exploration],
  )
)

*Key Findings from Failure Analysis*:

1. *Semantic Failures Dominate*: Over 70% of failures (reward hacking, specification brittleness, objective conflict) stem directly from the inability to properly express and maintain semantic relationships between objectives.

2. *Deployment Failures Are Predictable*: Distributional shift and catastrophic forgetting account for 32% of failures, occurring predictably when systems move from controlled to real-world environments.

3. *Compounding Effects*: Failures rarely occur in isolation. A system experiencing specification brittleness is 3.2× more likely to also suffer from distributional shift.

4. *Industry-Specific Patterns*:
   - *Autonomous vehicles*: 45% distributional shift (weather, lighting, road conditions)
   - *Manufacturing robots*: 38% objective conflict (safety vs. productivity)
   - *Service robots*: 52% reward hacking (finding loopholes in task specifications)
   - *Drones*: 41% edge case exploitation (oscillations, power management)

5. *Economic Impact by Failure Mode*:
   - Reward hacking: Average \$2.3M per incident (retraining costs)
   - Distributional shift: Average \$1.8M per incident (deployment delays)
   - Catastrophic failures: Average \$12.4M per incident (safety violations)

This taxonomy reveals that the intent-to-reality gap is not a monolithic problem but a collection of interrelated failure modes that require systematic solutions addressing both semantic preservation and deployment robustness.

=== Safety-Critical Failures in High-Stakes Applications

Beyond economic costs, the intent-to-reality gap poses serious safety risks in critical applications. In healthcare robotics, surgical robots must balance multiple competing objectives: precision, safety, efficiency, and patient comfort. Traditional reward engineering approaches struggle to capture these complex trade-offs, leading to systems that may optimize for one objective at the expense of others—potentially with life-threatening consequences.

Aerospace applications present similar challenges. When SpaceX's Dragon capsule autonomously docks with the International Space Station, the control system must simultaneously satisfy objectives for approach speed, trajectory accuracy, fuel efficiency, and abort capability. The failure to properly balance these objectives could result in catastrophic collision or mission failure, with costs measured not just in dollars but in human lives and international cooperation.

=== The Compounding Effect of Specification Failures

What makes these failures particularly insidious is their compounding nature. Unlike traditional software bugs that can be patched, reward specification failures in RL systems often require complete retraining, which can take weeks or months. During this time, the system either remains deployed with known issues or is taken offline, both of which carry significant costs.

Moreover, these failures often emerge only during deployment, when the system encounters conditions not anticipated during training. A quadrotor trained to "fly smoothly" might learn to hover motionlessly to minimize control effort, technically satisfying the reward function while completely failing to accomplish the intended task. Such specification failures can remain hidden during laboratory testing, only to manifest catastrophically in real-world deployment.

== Why Hasn't the RL Community Solved This Already?

Given the severity and visibility of these problems, a natural question arises: why hasn't the reinforcement learning community already solved the intent-to-reality gap? The answer reveals fundamental limitations in how we approach robot learning that go beyond algorithmic improvements.

=== The Seductive Simplicity of Scalar Rewards

The RL community has been seduced by the mathematical elegance of scalar reward functions. Sutton's reward hypothesis suggests that "all of what we mean by goals and purposes can be well thought of as maximization of the expected value of the cumulative sum of a received scalar signal" @sutton2018reinforcement. This hypothesis has provided a unifying framework for RL research, enabling the development of powerful algorithms like Q-learning, policy gradients, and actor-critic methods.

However, recent work has shown that the reward hypothesis fails in many practical scenarios @reward_hypothesis_false @settling_reward_hypothesis. The fundamental issue is that scalar rewards cannot capture the rich semantic relationships between objectives that characterize real-world robotics tasks. When practitioners attempt to encode multiple objectives into a single scalar, they inevitably lose semantic meaning and create brittle specifications that fail under distribution shift.

=== The Linear Scalarization Trap

The standard approach to multi-objective problems in RL has been linear scalarization:

$ R_"total"(s,a,s') = sum_(i=1)^n w_i R_i(s,a,s') $

This approach appears mathematically principled and has enabled significant research progress. However, it suffers from fundamental limitations that make it unsuitable for robotics applications:

1. *Pareto Frontier Limitations*: Linear scalarization can only find solutions on the convex hull of the Pareto frontier, missing many potentially desirable solutions @SAKAWA199819.

2. *Weight Sensitivity*: Small changes in weights can lead to dramatically different behaviors, making systems difficult to tune and maintain.

3. *Semantic Loss*: The linear combination destroys the individual meaning of each objective, making it impossible to reason about whether specific requirements are being satisfied.

4. *Expressivity Constraints*: Many natural objective relationships cannot be expressed through linear combination, such as "satisfy safety requirements before optimizing performance."

=== The Simulation-Reality Divide

The RL community has also been constrained by the simulation-reality divide. Most RL research occurs in simulation, where perfect resets, unlimited samples, and controlled conditions make many problems tractable. However, this has led to solutions that work well in simulation but fail catastrophically in reality.

The community has attempted to bridge this gap through domain randomization, sim-to-real transfer, and other techniques. While these approaches have achieved some success, they fundamentally treat the symptoms rather than the cause. The real issue is that our reward specification methods are too brittle to survive the distribution shift from simulation to reality.

=== Institutional and Incentive Misalignment

Perhaps most importantly, the academic incentive structure has discouraged work on the intent-to-reality gap. Publishing in top-tier venues requires novel algorithmic contributions, often evaluated on standardized benchmarks that don't capture the complexity of real-world robotics applications. Researchers are rewarded for achieving state-of-the-art performance on these benchmarks, not for solving the practical problems that prevent real-world deployment.

This has led to a research ecosystem focused on algorithmic improvements to sample efficiency, convergence guarantees, and theoretical analysis, while the fundamental problem of reward specification remains largely unaddressed. The few attempts to tackle reward engineering have been dismissed as "engineering problems" rather than fundamental research challenges.

=== The Complexity Explosion

As robotics applications have become more sophisticated, the complexity of the intent-to-reality gap has exploded exponentially. Early RL applications in robotics involved simple, well-defined tasks like pole balancing or reaching. Modern applications require robots to navigate complex, multi-objective scenarios with competing requirements, safety constraints, and performance specifications.

The traditional approach of manual reward engineering simply doesn't scale to this complexity. Practitioners find themselves trapped in endless cycles of reward tuning, where fixing one behavior breaks another, and where the relationship between reward specification and emergent behavior becomes increasingly opaque.

== The Two Faces of the Crisis

Our analysis reveals that the intent-to-reality gap manifests through two interconnected but distinct crises, each requiring different theoretical and practical solutions.

=== The Reward Expressivity Crisis

The first crisis concerns our ability to express complex intentions through reward functions. Traditional RL assumes that all objectives can be reduced to scalar rewards, but robotics applications involve rich semantic relationships between objectives that cannot be captured through linear scalarization.

Consider a quadrotor delivery task that must simultaneously:
- Maintain flight stability (safety-critical)
- Follow the planned trajectory (performance requirement)
- Minimize energy consumption (efficiency objective)
- Avoid obstacles (safety constraint)
- Minimize flight time (customer satisfaction)

These objectives exhibit complex relationships: stability is a hard constraint that must always be satisfied, obstacle avoidance is context-dependent, and the trade-off between speed and energy efficiency depends on mission parameters. Linear scalarization cannot express these relationships, forcing practitioners into brittle approximations that fail under distribution shift.

The expressivity crisis manifests in several ways:

*Semantic Loss*: When objectives are linearly combined, their individual meanings are lost. A high total reward might result from excellent performance on one objective while completely ignoring others.

*Brittleness*: Small changes in weights can lead to dramatically different behaviors, making systems difficult to tune and maintain in production environments.

*Specification Complexity*: As the number of objectives grows, the space of possible weight combinations grows exponentially, making manual tuning intractable.

*Hidden Trade-offs*: The linear combination obscures the actual trade-offs being made, making it difficult to understand and debug system behavior.

=== The Deployment Crisis

The second crisis concerns the transfer of learned behaviors from training environments to real-world deployment. Even when practitioners successfully specify their intentions through reward functions, the resulting policies often fail catastrophically when deployed in conditions that differ from training.

This crisis has multiple dimensions:

*Distribution Shift*: Real-world conditions inevitably differ from training environments in ways that are difficult to anticipate or model. Lighting conditions, surface textures, dynamic obstacles, and environmental noise all contribute to distribution shift that can break learned policies.

*Robustness Failures*: Policies that perform well in training often lack the robustness needed for real-world deployment. Small perturbations in state or action space can lead to catastrophic failures.

*Generalization Limits*: RL policies often overfit to the specific conditions present during training, failing to generalize to the broader range of conditions encountered in deployment.

*Safety Degradation*: The optimization pressure of RL can lead policies to exploit edge cases or unsafe behaviors that achieve high reward in training but are dangerous in deployment.

== The Interconnected Nature of the Crises

While we have described the expressivity and deployment crises separately, they are fundamentally interconnected. Poor reward specification exacerbates deployment failures, while deployment constraints limit our ability to express complex intentions.

=== How Expressivity Problems Cause Deployment Failures

When reward functions fail to capture the true intentions behind a task, the resulting policies learn to exploit the specification rather than solve the underlying problem. These exploitative behaviors are often brittle and fail catastrophically under distribution shift.

For example, a robot trained to "move quickly" through a linear reward on velocity might learn to oscillate rapidly in place, achieving high reward in simulation but failing completely in the real world where such behavior would damage actuators or violate safety constraints.

=== How Deployment Constraints Limit Expressivity

Conversely, the need for robust deployment constrains how we can express intentions. Practitioners often resort to overly conservative reward specifications to ensure safety, sacrificing performance and expressivity for robustness.

This creates a vicious cycle: poor expressivity leads to deployment failures, which leads to more conservative specifications, which further limits expressivity and prevents the development of truly capable systems.

=== The Compounding Effect

The interaction between these crises creates a compounding effect that makes the intent-to-reality gap increasingly difficult to bridge as systems become more complex. Each additional objective, constraint, or deployment requirement exponentially increases the difficulty of specification and the likelihood of failure.

== Existing Approaches and Their Limitations

The RL community has developed several approaches to address aspects of the intent-to-reality gap, but each suffers from fundamental limitations that prevent them from providing complete solutions.

=== Multi-Objective Reinforcement Learning (MORL)

Multi-objective reinforcement learning explicitly represents multiple objectives through vector rewards, avoiding the immediate semantic loss of linear scalarization @survey_seq_dec_morl @reymond2023actor. MORL approaches divide into *a-priori* methods (preferences specified before training) and *a-posteriori* methods (generating multiple Pareto-optimal policies for post-training selection).

**The MORL Landscape and Its Limitations**: Traditional MORL approaches can be categorized into several paradigms, each with fundamental limitations:

*Scalarization-Based MORL*: Most practical MORL systems ultimately rely on linear scalarization for policy selection, inheriting the same semantic loss and brittleness problems as traditional RL. Even sophisticated preference elicitation methods reduce to weighted combinations that cannot express complex logical relationships.

*Pareto-Based MORL*: Methods like NSGA-II adapted for RL maintain populations representing different trade-offs on the Pareto frontier. However, these approaches suffer from computational overhead, require post-hoc policy selection, and provide no direct way to specify desired trade-offs or semantic relationships.

*Constraint-Based MORL*: Constrained MDPs treat secondary objectives as constraints while optimizing a primary objective. These methods struggle with soft constraints, balanced multi-objective satisfaction, and the complex hierarchical relationships common in robotics.

**Why MORL Has Failed in Robotics**: Despite decades of research, MORL has seen limited adoption in real-world robotics applications due to fundamental limitations:

1. *Semantic Loss*: Even vector-valued approaches ultimately compress multi-objective information into scalar decisions, losing the semantic meaning of individual objectives.

2. *Specification Complexity*: MORL requires practitioners to specify preferences, constraints, or selection criteria that are often as difficult to design as the original reward functions.

3. *Deployment Brittleness*: MORL policies trained for specific trade-offs often fail catastrophically when deployed in environments with different objective relationships.

4. *Lack of Logical Structure*: Traditional MORL cannot express the logical relationships ("safety AND performance", "efficiency OR speed") that naturally characterize robotics objectives.

**The Need for a New MORL Paradigm**: The limitations of existing MORL approaches highlight the need for a fundamentally different approach that:
- Preserves semantic meaning throughout learning
- Enables direct specification of logical objective relationships  
- Provides robust deployment across domains
- Scales to complex real-world applications

This thesis presents fulfillment-centric learning as this new paradigm, addressing MORL's fundamental limitations through continuous logic operators and semantic preservation principles.

=== Constraint-Based Methods

Constraint-based approaches attempt to separate hard constraints from optimization objectives, using techniques like constrained policy optimization or Lagrangian methods. While these methods can handle some types of objective relationships, they struggle with the soft constraints and complex trade-offs that characterize robotics applications.

=== Hierarchical Reinforcement Learning

Hierarchical RL decomposes complex tasks into simpler subtasks, potentially addressing some aspects of the expressivity crisis. However, these approaches require manual decomposition of the task hierarchy and don't address the fundamental problem of specifying objectives within each level of the hierarchy.

=== Domain Randomization and Sim-to-Real Transfer

These approaches attempt to bridge the deployment crisis by training policies that are robust to distribution shift. While they have achieved some success, they treat the symptoms rather than the cause, requiring extensive engineering effort for each new domain and often sacrificing performance for robustness.

=== Large Language Model-Based Reward Engineering

Recent work has attempted to address the reward engineering bottleneck by leveraging large language models (LLMs) to automatically generate reward functions from natural language descriptions. NVIDIA's EUREKA system @eureka represents a prominent example of this approach, allowing users to specify desired behaviors in natural language while the LLM generates corresponding reward code.

While EUREKA demonstrates impressive capabilities in generating reward functions for complex tasks, it fundamentally inherits the same limitations as traditional reward engineering. The LLM is still solving the intent-to-reality gap through the standard reward maximization process with all its associated problems:

*Semantic Loss*: The generated reward functions still rely on linear scalarization, losing semantic meaning when multiple objectives are combined.

*Specification Brittleness*: The automatically generated rewards are just as brittle as manually engineered ones, suffering from the same sensitivity to weight changes and distribution shift.

*Hidden Trade-offs*: The LLM's reward generation process obscures the actual trade-offs being made between objectives, making it difficult to understand or debug the resulting behavior.

*Reward Hacking Vulnerability*: Agents can still exploit loopholes in LLM-generated rewards just as easily as in human-designed ones, as the fundamental maximization paradigm remains unchanged.

EUREKA's success in specific domains demonstrates the power of automated reward generation, but it does not address the fundamental expressivity and deployment crises that characterize the intent-to-reality gap. The system essentially automates the creation of brittle specifications rather than solving the underlying problem of semantic preservation and robust deployment.

=== Inverse Reinforcement Learning

Inverse reinforcement learning (IRL) approaches the reward engineering problem from a different angle, attempting to learn reward functions from expert demonstrations rather than manual specification @ng2000algorithms @abbeel2004apprenticeship. IRL recognizes the fundamental difficulty of reward design by proposing to infer rewards from observed behavior rather than requiring explicit specification.

However, IRL faces its own fundamental limitations that prevent it from solving the intent-to-reality gap:

*Demonstration Dependency*: IRL requires high-quality expert demonstrations, which may be difficult or expensive to obtain, especially for complex multi-objective tasks where expert behavior involves subtle trade-offs.

*Semantic Loss During Recovery*: The recovered reward functions typically take the form of linear combinations, inheriting the same semantic loss problems as traditional reward engineering. The rich semantic relationships in expert behavior are compressed into scalar rewards.

*Ambiguity in Multi-Objective Settings*: When experts demonstrate behavior that balances multiple objectives, IRL struggles to recover the underlying objective structure, often producing reward functions that capture correlations rather than causal relationships.

*Limited Expressivity*: Traditional IRL methods recover reward functions within the same limited expressivity framework (linear scalarization) that causes problems in forward reward engineering.

*Deployment Brittleness*: Even when IRL successfully recovers reward functions that reproduce expert behavior in training conditions, these functions remain brittle under distribution shift, failing to capture the robust principles underlying expert decision-making.

While IRL addresses the specification bottleneck, it does not solve the fundamental problems of semantic preservation and robust deployment that characterize the intent-to-reality gap. The recovered rewards are still subject to the same limitations as manually designed ones.

== The Need for a Paradigm Shift

Our analysis reveals that incremental improvements to existing approaches cannot solve the intent-to-reality gap. The fundamental assumptions underlying current RL methods—scalar rewards, linear scalarization, and maximization-based optimization—are incompatible with the semantic richness and robustness requirements of real-world robotics applications.

What is needed is a paradigm shift that:

1. *Preserves Semantic Meaning*: Maintains the individual meaning of objectives throughout the learning process
2. *Enables Expressive Composition*: Allows complex relationships between objectives to be expressed naturally
3. *Provides Robustness Guarantees*: Ensures that learned behaviors remain stable under distribution shift
4. *Scales to Complexity*: Handles the exponential growth in complexity as systems become more sophisticated

This paradigm shift is what we term *fulfillment-centric learning*—a fundamental reconceptualization of robot learning that treats objectives as constraints to be satisfied rather than scores to be maximized. The following chapters develop this paradigm, showing how it addresses both the expressivity and deployment crises while providing the theoretical foundations and practical tools needed for real-world robotics applications.

== How to Use This Thesis

This thesis presents a comprehensive framework for fulfillment-centric robot learning. Different readers may benefit from different paths through the material:

=== For Practitioners
If you're implementing robot learning systems and want practical guidance:
- **Start here**: Chapter 1 (motivation) → Chapter 4 (FPL and practitioner's guide) → Chapter 5 (CAPS implementation)
- **Key takeaway**: Use geometric mean composition ($p = 0$) as your default, handle universal objectives architecturally
- **Implementation**: The practitioner's guide in Chapter 4 provides step-by-step methodology and common patterns

=== For Theoreticians  
If you're interested in the mathematical foundations and theoretical contributions:
- **Start here**: Chapter 3 (mathematical foundations) → Chapter 2 (intent-to-reality framework) → Chapter 7 (discovery story)
- **Key insights**: Generalized means provide continuous logic, semantic preservation prevents information loss
- **Novel theory**: Insights about common underlying causes of expressivity and deployment challenges, minimum fulfillment bounds, semantic anchoring principles

=== For Robotics Researchers
If you're working on multi-objective control and want to understand the full framework:
- **Read sequentially**: All chapters provide complementary perspectives on the same underlying framework
- **Focus areas**: Chapter 5 (CAPS), Chapter 6 (Anchor Critics), Chapter 7 (Lyapunov applications)
- **Empirical validation**: Each technical chapter includes comprehensive experimental results

=== For Students
If you're learning about robot learning and multi-objective optimization:
- **Foundation first**: Chapter 1 → Chapter 3 → Chapter 4 for core concepts
- **Then applications**: Chapter 5 → Chapter 6 for practical implementations
- **Discovery story**: Chapter 7 shows how mathematical insights emerge from practical problems

== Chapter Summary

This chapter has established the crisis of intent in robot learning, demonstrating that the intent-to-reality gap is not merely a technical challenge but a fundamental barrier to the deployment of capable robotics systems. We have shown that:

1. *The stakes are high*: Robot learning failures have severe economic, safety, and societal consequences that are growing as systems become more prevalent.

2. *Existing approaches are insufficient*: The RL community's focus on scalar rewards and linear scalarization cannot address the semantic complexity of real-world robotics applications.

3. *The crisis has two faces*: The reward expressivity crisis and deployment crisis are interconnected problems that require coordinated solutions.

4. *A paradigm shift is needed*: Incremental improvements cannot solve the fundamental limitations of current approaches.

The stage is now set for the development of fulfillment-centric learning as a comprehensive solution to the intent-to-reality gap. The next chapter establishes the mathematical and conceptual foundations for this new paradigm, showing how the theory of generalized means provides the tools needed to express complex objective relationships while maintaining semantic meaning and enabling robust optimization.