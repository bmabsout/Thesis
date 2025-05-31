#import "../commands.typ": *

= Background and Related Work <chap:background_related_work>

This chapter establishes the theoretical foundations and related work that inform our fulfillment-centric approach to robot learning. We organize the literature around five key areas: multi-objective optimization theory, multi-objective reinforcement learning, continuous logic and fuzzy systems, robust deployment and transfer learning, and control-theoretic approaches to robot learning.

== Reinforcement Learning Foundations

Modern reinforcement learning provides the algorithmic foundation for robot learning, establishing both the successes and limitations that motivate our fulfillment-centric approach.

=== The Reward Hypothesis and Its Limitations

The foundational RL textbook @SuttonBarto establishes the reward hypothesis: "all of what we mean by goals and purposes can be well thought of as maximization of the expected value of the cumulative sum of a received scalar signal." This hypothesis has provided a unifying framework for RL research, enabling the development of powerful algorithms like Q-learning, policy gradients, and actor-critic methods.

However, recent work has begun questioning the universal applicability of the reward hypothesis, particularly in multi-objective scenarios common in robotics applications. The fundamental challenge is that scalar rewards cannot capture the rich semantic relationships between objectives that characterize real-world robotics tasks.

=== Reward Design and Engineering

Traditional approaches to reward design rely on manual engineering of scalar reward functions. This approach has achieved remarkable successes in domains like game playing, where clear scoring mechanisms exist. However, robotics applications present fundamental challenges for manual reward engineering.

Recent work by the Eureka system @eureka demonstrates how large language models can assist in reward design, automatically generating reward functions from natural language descriptions. While promising, these approaches still rely on scalar combination of objectives and inherit the fundamental limitations of linear scalarization.

=== Inverse Reinforcement Learning

Inverse reinforcement learning provides an alternative approach to reward specification by learning reward functions from expert demonstrations. The foundational work of Ng and Russell @ng2000algorithms established the theoretical foundations for this approach, while Abbeel and Ng @abbeel2004apprenticeship demonstrated practical applications in robotics domains.

IRL addresses some limitations of manual reward engineering by extracting preferences from demonstrated behavior rather than explicit specification. However, IRL approaches still typically result in scalar reward functions and face challenges in multi-objective scenarios where expert demonstrations may represent complex trade-offs between competing objectives.

== Multi-Objective Optimization Foundations

Multi-objective optimization provides the mathematical foundations for handling competing objectives in robotics applications. The field has established fundamental concepts that directly inform our approach to robot learning.

=== Pareto Optimality and the Scalarization Challenge

The foundational work of Pareto established the concept of Pareto optimality for multi-objective problems. A solution is Pareto optimal if no other solution improves one objective without degrading another. The Pareto frontier represents the set of all Pareto optimal solutions, providing a complete characterization of optimal trade-offs.

Traditional approaches to multi-objective optimization rely heavily on scalarization methods that convert multiple objectives into single scalar functions. Linear scalarization, the most common approach, combines objectives as weighted sums: $f(x) = sum_(i=1)^n w_i f_i(x)$. While computationally tractable, this approach can only find solutions on the convex hull of the Pareto frontier, missing potentially desirable solutions in non-convex regions.

More sophisticated scalarization approaches include the weighted Tchebycheff method and adaptive weight strategies. However, all scalarization approaches face the fundamental challenge of determining appropriate weights, which often requires domain expertise that practitioners may lack.

=== Modern Multi-Objective Optimization

Recent advances in multi-objective optimization have moved beyond scalarization toward direct optimization of multiple objectives. Evolutionary approaches maintain populations of solutions distributed across the Pareto frontier. These methods avoid the weight selection problem but typically require significant computational resources and may struggle with high-dimensional objective spaces.

Reference point methods @Deb2006ReferencePB provide alternative approaches that enable practitioners to specify preferences through reference points rather than weights, though they still require careful parameter selection.

=== Limitations for Robotics Applications

While multi-objective optimization theory provides essential foundations, existing approaches face several limitations when applied to robotics:

*Computational Requirements*: Many multi-objective optimization methods require expensive function evaluations or large population sizes that are impractical for online robot learning.

*Solution Selection*: Even when the full Pareto frontier is available, practitioners must still select a single solution for deployment, reintroducing the weight selection problem.

*Semantic Interpretation*: Traditional multi-objective optimization focuses on mathematical properties (dominance, convergence) rather than semantic meaning, making it difficult for practitioners to specify and interpret objective relationships.

Our fulfillment framework addresses these limitations by providing computationally efficient methods for multi-objective robot learning that preserve semantic meaning throughout the optimization process.

== Multi-Objective Reinforcement Learning

Multi-objective reinforcement learning (MORL) extends traditional RL to handle multiple reward signals simultaneously. This field provides the most direct foundation for our work, though existing approaches face significant limitations that motivate our fulfillment-centric alternative.

=== Scalarization-Based MORL

Early MORL approaches extended single-objective RL through scalarization. These approaches learn value functions for the scalarized objective: $Q(s,a) = sum_(i=1)^n w_i Q_i(s,a)$.

Comprehensive surveys @survey_seq_dec_morl demonstrate the broad applicability of scalarization-based MORL methods while highlighting the persistent challenge of weight selection. The brittleness of linear scalarization becomes particularly problematic in RL settings, where small changes in weights can lead to dramatically different learned behaviors.

Recent work introduces dynamic weight adaptation during training, addressing some brittleness issues but introducing additional hyperparameters and computational complexity.

=== Pareto-Based MORL

To address scalarization limitations, several researchers have developed methods that explicitly optimize for the Pareto frontier. The Pareto Q-Learning algorithm @pareto_q_learning maintains sets of Pareto optimal Q-values for each state-action pair. While theoretically elegant, this approach faces significant computational and memory challenges in high-dimensional state spaces.

Multi-objective approaches using temporal logic formulations @Wingate_Temporal_MORL provide structured methods for expressing complex objective relationships, though they typically require expert knowledge of formal specification languages.

=== The MORL Landscape and Its Limitations

Traditional MORL approaches can be categorized into several paradigms, each with fundamental limitations:

*Scalarization-Based MORL*: Most practical MORL systems ultimately rely on linear scalarization for policy selection, inheriting the same semantic loss and brittleness problems as traditional RL. Even sophisticated preference elicitation methods reduce to weighted combinations that cannot express complex logical relationships.

*Pareto-Based MORL*: Methods like NSGA-II adapted for RL maintain populations representing different trade-offs on the Pareto frontier. However, these approaches suffer from computational overhead, require post-hoc policy selection, and provide no direct way to specify desired trade-offs or semantic relationships.

*Constraint-Based MORL*: Constrained MDPs treat secondary objectives as constraints while optimizing a primary objective. These methods struggle with soft constraints, balanced multi-objective satisfaction, and the complex hierarchical relationships common in robotics.

*Limited MORL Adoption in Complex Robotics*: Despite significant research advances over two decades @survey_seq_dec_morl, MORL approaches have seen relatively limited adoption in complex real-world robotics applications. Several fundamental challenges have hindered broader deployment:

1. *Semantic Loss*: Even vector-valued approaches ultimately compress multi-objective information into scalar decisions, losing the semantic meaning of individual objectives.

2. *Specification Complexity*: MORL requires practitioners to specify preferences, constraints, or selection criteria that are often as difficult to design as the original reward functions.

3. *Deployment Brittleness*: MORL policies trained for specific trade-offs often struggle when deployed in environments with different objective relationships.

4. *Limited Logical Expressivity*: Traditional MORL approaches cannot directly express the logical relationships ("safety AND performance", "efficiency OR speed") that naturally characterize robotics objectives.

=== Constraint-Based Approaches

Constraint-based MORL treats some objectives as hard constraints while optimizing others. These approaches ensure constraint satisfaction during learning but require practitioners to distinguish between objectives and constraints, which may not align with natural problem specifications.

Constraint-based approaches attempt to separate hard constraints from optimization objectives, using techniques like constrained policy optimization or Lagrangian methods. While these methods can handle some types of objective relationships, they struggle with the soft constraints and complex trade-offs that characterize robotics applications.

=== Hierarchical Reinforcement Learning

Hierarchical RL decomposes complex tasks into simpler subtasks, potentially addressing some aspects of the expressivity crisis. However, these approaches require manual decomposition of the task hierarchy and don't address the fundamental problem of specifying objectives within each level of the hierarchy.

=== Large Language Model-Based Reward Engineering

Recent work has attempted to address the reward engineering bottleneck by leveraging large language models (LLMs) to automatically generate reward functions from natural language descriptions. The Eureka system @eureka represents a prominent example of this approach, allowing users to specify desired behaviors in natural language while the LLM generates corresponding reward code.

While Eureka demonstrates impressive capabilities in generating reward functions for complex tasks, it fundamentally inherits the same limitations as traditional reward engineering. The LLM is still solving the intent-to-reality gap through the standard reward maximization process with all its associated problems:

*Semantic Loss*: The generated reward functions still rely on linear scalarization, losing semantic meaning when multiple objectives are combined.

*Specification Brittleness*: The automatically generated rewards are just as brittle as manually engineered ones, suffering from the same sensitivity to weight changes and distribution shift.

*Hidden Trade-offs*: The LLM's reward generation process obscures the actual trade-offs being made between objectives, making it difficult to understand or debug the resulting behavior.

*Reward Hacking Vulnerability*: Agents can still exploit loopholes in LLM-generated rewards just as easily as in human-designed ones, as the fundamental maximization paradigm remains unchanged.

Eureka's success in specific domains demonstrates the power of automated reward generation, but it does not address the fundamental expressivity and deployment crises that characterize the intent-to-reality gap. The system essentially automates the creation of brittle specifications rather than solving the underlying problem of semantic preservation and robust deployment.

=== Enhanced Inverse Reinforcement Learning Analysis

Inverse reinforcement learning (IRL) approaches the reward engineering problem from a different angle, attempting to learn reward functions from expert demonstrations rather than manual specification @ng2000algorithms @abbeel2004apprenticeship. IRL recognizes the fundamental difficulty of reward design by proposing to infer rewards from observed behavior rather than requiring explicit specification.

However, IRL faces its own fundamental limitations that prevent it from solving the intent-to-reality gap:

*Demonstration Dependency*: IRL requires high-quality expert demonstrations, which may be difficult or expensive to obtain, especially for complex multi-objective tasks where expert behavior involves subtle trade-offs.

*Semantic Loss During Recovery*: The recovered reward functions typically take the form of linear combinations, inheriting the same semantic loss problems as traditional reward engineering. The rich semantic relationships in expert behavior are compressed into scalar rewards.

*Ambiguity in Multi-Objective Settings*: When experts demonstrate behavior that balances multiple objectives, IRL struggles to recover the underlying objective structure, often producing reward functions that capture correlations rather than causal relationships.

*Limited Expressivity*: Traditional IRL methods recover reward functions within the same limited expressivity framework (linear scalarization) that causes problems in forward reward engineering.

*Deployment Brittleness*: Even when IRL successfully recovers reward functions that reproduce expert behavior in training conditions, these functions remain brittle under distribution shift, failing to capture the robust principles underlying expert decision-making.

While IRL addresses the specification bottleneck, it does not solve the fundamental problems of semantic preservation and robust deployment that characterize the intent-to-reality gap.

== Continuous Logic and Fuzzy Systems

The mathematical foundations for composing multiple objectives draw extensively from continuous logic and fuzzy systems theory. This work provides essential tools for extending discrete logical relationships to continuous domains.

=== Fuzzy Logic Foundations

Fuzzy logic extends Boolean logic to the continuous interval [0,1], enabling smooth reasoning about concepts that admit degrees of truth. T-norms and t-conorms provide the mathematical foundations for continuous logical operations, satisfying commutativity, associativity, and monotonicity properties while extending AND and OR operations to continuous domains.

Fuzzy systems theory establishes connections between fuzzy logic and probability theory, multi-valued logic, and approximate reasoning, demonstrating the broad applicability of continuous logic operators across diverse domains.

=== Applications to Multi-Criteria Decision Making

Fuzzy logic has found extensive application in multi-criteria decision making (MCDM), providing methods for combining multiple criteria with linguistic or imprecise information. These approaches provide precedent for using continuous logic in multi-objective optimization, though they typically focus on discrete decision scenarios rather than continuous control.

=== Limitations for Robot Learning

While fuzzy logic provides essential mathematical tools, direct application to robot learning faces several challenges:

*Semantic Interpretation*: Traditional fuzzy logic focuses on uncertainty and partial membership rather than objective satisfaction and semantic meaning.

*Optimization Integration*: Fuzzy systems are typically designed for inference rather than gradient-based optimization, making them challenging to integrate with modern RL algorithms.

*Parameter Selection*: Fuzzy systems often require extensive parameter tuning that can be as challenging as weight selection in traditional approaches.

Our fulfillment framework draws on the mathematical foundations of continuous logic while addressing these limitations through semantic anchoring and optimization-friendly formulations.

== Robust Deployment and Transfer Learning

The deployment challenge in robot learning has driven extensive research in domain adaptation, transfer learning, and sim-to-real transfer. This work provides essential context for our multi-fulfillment adaptation approach.

=== Simulation-to-Reality Transfer

The sim-to-real transfer problem has received particular attention due to the efficiency advantages of simulation-based training. Domain randomization methods @Sim2Real provide approaches for training robust policies by exposing them to diverse simulation conditions.

However, domain randomization requires careful selection of randomization parameters and may struggle with systematic biases between simulation and reality. Meta-learning approaches @MetaSimToReal demonstrate potential for rapid adaptation to new environments but require substantial computational resources during training.

=== Domain Randomization and Sim-to-Real Transfer

These approaches attempt to bridge the deployment crisis by training policies that are robust to distribution shift. While they have achieved some success, they treat the symptoms rather than the cause, requiring extensive engineering effort for each new domain and often sacrificing performance for robustness.

Domain randomization and sim-to-real transfer methods focus on making learned policies robust to the inevitable differences between training and deployment environments. However, these approaches face fundamental limitations:

*Symptom Treatment*: Rather than addressing the root cause of brittleness in reward specification, domain randomization attempts to make brittle policies more robust through exposure to variation.

*Engineering Overhead*: Each new domain requires careful selection of randomization parameters and extensive validation, making the approach difficult to scale.

*Performance Trade-offs*: Robust policies often sacrifice peak performance for generalization, which may not be acceptable in performance-critical applications.

*Systematic Bias Vulnerability*: Domain randomization struggles with systematic differences between simulation and reality that cannot be captured through parameter variation.

=== Adaptation and Fine-tuning

Online adaptation methods adjust policies during deployment based on observed performance. These approaches show significant improvements in tracking performance through real-time policy updates, though they raise safety concerns and require careful design to prevent catastrophic failures during the adaptation process.

Recent work introduces conservative policy optimization methods that prevent catastrophic degradation during adaptation. This work provides important safety guarantees that inform our anchor critics approach.

=== Multi-Task and Continual Learning

The challenge of learning multiple tasks while avoiding catastrophic forgetting has driven research in continual learning methods @catastrophic-forgetting-binici @catastrophic-forgetting-wolczyk. In multi-objective contexts, catastrophic forgetting can be particularly severe when objectives conflict, motivating our multi-fulfillment adaptation approach that preserves objective-specific information during adaptation.

== Control-Theoretic Approaches

Classical control theory provides essential foundations for robot learning, particularly for safety-critical applications and stability guarantees. This work informs our integration of control-theoretic principles with learning-based methods.

=== Reinforcement Learning in Control

The foundational reinforcement learning textbook @SuttonBarto establishes comprehensive foundations for integrating learning with control systems. Recent applications @barto2017some demonstrate the broad potential for RL in control applications while highlighting challenges in safety-critical systems.

=== Safety-Critical Control

Barrier function approaches @Cheng_Orosz_Murray_Burdick_2019 provide methods for maintaining safety guarantees in learning-based control systems. These approaches enable aggressive learning while maintaining stability guarantees, demonstrating the potential for integrating learning and control-theoretic safety guarantees.

=== Multi-Objective Control in Applications

Multi-objective optimization has found application in various control domains, including water resource management @castelletti2013multiobjective and power systems. These applications demonstrate the practical importance of multi-objective approaches while highlighting challenges in real-world deployment.

== Research Gaps and Motivation

The literature review reveals several important gaps that motivate our fulfillment-centric approach:

=== Semantic Preservation Gap

Existing multi-objective approaches, whether in optimization, RL, or control, typically focus on mathematical properties rather than semantic meaning. Practitioners struggle to specify their intentions in ways that preserve meaning throughout the optimization process.

=== Integration Gap

Current approaches treat specification and deployment as separate challenges, missing opportunities for unified solutions that address both problems through similar mechanisms.

=== Interpretability Gap

Even when multi-objective methods preserve individual objective information, they often lack mechanisms for practitioners to understand and debug complex objective relationships.

=== Practical Deployment Gap

Many theoretical advances in multi-objective learning have not translated to practical robotics deployments, partly due to computational complexity and partly due to difficulty in real-world specification.

== The Need for a Paradigm Shift

Our analysis reveals that incremental improvements to existing approaches cannot solve the intent-to-reality gap. The fundamental assumptions underlying current RL methods—scalar rewards, linear scalarization, and maximization-based optimization—are incompatible with the semantic richness and robustness requirements of real-world robotics applications.

=== Fundamental Limitations of Current Approaches

The comprehensive analysis of existing approaches reveals several fundamental limitations that cannot be addressed through incremental improvements:

*Universal Semantic Loss*: Whether through traditional reward engineering, automated LLM-based generation, or inverse reinforcement learning, all existing approaches ultimately compress multi-objective information into scalar signals, losing semantic meaning.

*Brittleness Across Methods*: From manually designed rewards to sophisticated MORL approaches, all existing methods suffer from brittleness under distribution shift and sensitivity to specification changes.

*Specification Complexity Explosion*: As robotics applications become more sophisticated, the complexity of multi-objective specification grows exponentially, making current approaches increasingly intractable.

*Deployment-Specification Disconnect*: Existing approaches treat specification and deployment as separate problems, missing opportunities for unified solutions and creating brittle handoffs between training and deployment.

=== Requirements for Paradigm Shift

What is needed is a paradigm shift that:

1. *Preserves Semantic Meaning*: Maintains the individual meaning of objectives throughout the learning process
2. *Enables Expressive Composition*: Allows complex relationships between objectives to be expressed naturally
3. *Provides Robustness Guarantees*: Ensures that learned behaviors remain stable under distribution shift  
4. *Scales to Complexity*: Handles the exponential growth in complexity as systems become more sophisticated
5. *Unifies Specification and Deployment*: Addresses both expressivity and robustness through similar mechanisms

Our fulfillment framework addresses these gaps by providing semantically meaningful ways to specify and compose objectives while maintaining computational tractability and enabling robust deployment. The following chapters develop these ideas systematically, building on the foundations established in this literature review. 