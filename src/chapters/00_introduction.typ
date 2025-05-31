#import "../commands.typ": *

= Introduction <chap:introduction>

Contemporary robot learning faces significant challenges in bridging the gap between designer intentions and deployed behavior. While reinforcement learning has achieved remarkable successes in simulated environments and controlled domains, real-world robotics applications continue to struggle with fundamental issues in objective specification and robust deployment. This thesis addresses what we term the *intent-to-reality gap*—the discrepancy between what practitioners intend their robots to do and what they actually learn to do in deployment.

== Problem Statement

Robot learning systems must satisfy multiple competing objectives simultaneously: a quadrotor must track trajectories accurately while maintaining stability, conserving energy, and avoiding obstacles; a manipulation system must reach targets quickly while moving smoothly and respecting safety constraints. Traditional reinforcement learning approaches handle such multi-objective scenarios through linear scalarization—combining objectives into weighted sums that obscure individual objective meanings and create brittle, difficult-to-tune systems.

This approach leads to two interconnected challenges. First, the *expressivity challenge*: linear combinations cannot capture the semantic relationships between objectives that characterize real robotics tasks. When a practitioner specifies that "safety should never be compromised for speed," this hierarchical relationship cannot be expressed through linear weights. Second, the *deployment challenge*: policies trained on linearly-scalarized objectives often fail catastrophically when transferred to deployment environments, as the brittle numerical relationships learned in training do not generalize across distribution shifts.

These challenges have created a barrier to widespread deployment of learned robot behaviors in real-world applications, limiting the practical impact of advances in reinforcement learning and contributing to the substantial gap between research demonstrations and production robotics systems.

== Thesis Statement

This thesis demonstrates that the expressivity and deployment challenges in robot learning stem from similar underlying issues related to the lack of structure in existing reward and value functions. We propose that these challenges can be addressed through a unified framework based on *fulfillment-centric learning*—reconceptualizing robot learning as the satisfaction of structured constraints rather than the maximization of scalar rewards.

Our central hypothesis is that fulfillment functions can serve as *semantic bridges* that preserve the natural meaning of objectives throughout the optimization process, while continuous logic operators enable the composition of these objectives in ways that maintain their individual interpretability and relationships.

== Key Contributions

This thesis makes the following primary contributions to robot learning:

=== 1. Unified Framework Analysis
We provide the first systematic analysis demonstrating that expressivity and deployment challenges stem from similar underlying issues in multi-objective constraint satisfaction. This insight simplifies the conceptual landscape and enables integrated solution approaches.

=== 2. Objective Taxonomy and Treatment Framework
We introduce a comprehensive taxonomy of objectives in robot learning—general objectives, behavioral objectives, and universal behavioral objectives—with appropriate treatment mechanisms for each category. This taxonomy clarifies when to use explicit composition versus architectural integration.

=== 3. Fulfillment Priority Logic (FPL)
We develop Fulfillment Priority Logic, a formal specification language that enables practitioners to express complex objective relationships through continuous logic while preserving semantic meaning throughout the optimization process.

=== 4. Architectural Integration Framework
We present Conditioning for Action Policy Smoothness (CAPS), demonstrating how universal behavioral objectives can be integrated directly into policy architectures rather than through reward engineering, achieving superior performance with simplified specification.

=== 5. Robust Deployment Framework
We introduce Anchor Critics, a multi-fulfillment adaptation framework that preserves semantic anchoring during sim-to-real transfer, enabling robust real-world deployment while maintaining interpretability.

=== 6. Real-World Validation
We provide comprehensive empirical validation including the first reinforcement learning system to outperform classical PID controllers in real quadrotor deployment, achieving 50-80% power reductions and demonstrating practical viability.

== Empirical Results

Our approach achieves significant quantitative improvements across multiple domains:

- *Sample Efficiency*: Up to 6.4× speedup on LunarLander and 5.6× speedup on Hopper compared to baseline methods, with FPL consistently outperforming state-of-the-art algorithms like SAC and CrossQ @fpl2025
- *Energy Consumption*: Almost 80% power reductions in quadrotor control demonstrated through CAPS regularization @caps2021  
- *Deployment Success*: 100% flight-worthy controllers in real-world quadrotor deployment through our RE+AL framework @how_to_train_your_quadrotor
- *Training Consistency*: 100% successful sim-to-real transfer with reproducible training pipeline
- *Transfer Robustness*: Up to 50% power consumption reduction during sim-to-real adaptation using Anchor Critics @anchor_critics

== Thesis Organization

This thesis is organized as follows:

*Chapter 2* provides background on multi-objective optimization, reinforcement learning, and related work in robot learning, establishing the theoretical and empirical foundations for our approach.

*Chapter 3* formalizes the intent-to-reality gap and presents our unified framework analysis, demonstrating the common underlying challenges in expressivity and deployment.

*Chapter 4* introduces the mathematical foundations of the fulfillment framework, including generalized means as continuous logic operators and their relationship to existing mathematical frameworks.

*Chapter 5* presents Fulfillment Priority Logic as a formal specification language, with comprehensive algorithmic implementation and empirical validation.

*Chapter 6* demonstrates architectural integration through the CAPS framework, showing how universal behavioral objectives can be built into policy architectures.

*Chapter 7* introduces the Anchor Critics framework for robust multi-fulfillment adaptation and sim-to-real transfer.

*Chapter 8* presents the discovery story of how the fulfillment framework emerged from control-theoretic foundations, validating the approach through classical stability theory.

*Chapter 9* synthesizes contributions and discusses future directions, positioning fulfillment-centric learning as a foundation for principled robot learning engineering.

== Scope and Limitations

This work focuses primarily on continuous control problems in robotics applications, with particular emphasis on multi-objective scenarios involving safety, performance, and efficiency trade-offs. While we demonstrate broad applicability across domains, the framework is most beneficial for applications with clear semantic objective relationships.

The thesis addresses behavioral objectives—those directly related to robot behavior—but does not claim to replace all aspects of reward engineering. General objectives (such as regularization terms) are better handled through appropriate algorithm design, while our architectural integration approach specifically targets universal behavioral objectives.

== Impact and Broader Implications

This work has implications beyond robot learning, providing foundations for interpretable multi-objective optimization, human-AI interaction in complex systems, and principled engineering approaches to artificial intelligence. The semantic preservation properties of fulfillment-centric learning offer pathways toward more transparent and reliable AI systems in safety-critical applications.

By transforming robot learning from a trial-and-error process into a principled engineering discipline, this thesis contributes to closing the gap between research advances and practical deployment, potentially accelerating the adoption of learned behaviors in real-world robotics applications. 