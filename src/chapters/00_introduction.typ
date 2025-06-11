#import "../commands.typ": *

= Introduction <chap:introduction>

Contemporary robot learning has achieved remarkable successes in controlled environments, from game-playing agents mastering complex strategies #todo[AlphaGo] to robotic manipulation systems demonstrating impressive dexterity in laboratory settings #todo[OpenAI Dactyl]. However, a significant gap persists between these research achievements and practical deployment in real-world robotics applications. Practitioners repeatedly encounter:

+ *Objective-specification difficulty* — scalar rewards are hard to craft so that they reflect designer intent.
+ *Simulation–reality brittleness* — controllers that look good in sim often oscillate or crash on hardware.
+ *Catastrophic forgetting* during adaptation to real data.
+ *Sample inefficiency* — popular RL algorithms demand lengthy, expensive data collection.

Taken together, these shortcomings underscore the breadth of the *intent-to-reality gap*—the discrepancy between designer intention and deployed robot behaviour.

Examining what contributes to this gap, we identify critical expressiveness limitations in how objectives are specified and optimized. User intentions encoded as scalar rewards often fail to capture the behaviors produced by policy optimization. Even in simulated benchmark tasks designed by researchers in the field, these reward functions tend to be difficult to interpret, often contain redundant terms, and even worse, produce algorithm-, environment-, and seed-specific formulations.

If rewards are the answer, then what is the question? The _reward hypothesis_ states that scalar rewards can precisely represent all that we care about in robot control. However, it says nothing about the difficulty in expressing such rewards. Can adding more structure to this interface of value and reward functions help us express our intentions more precisely?

To address this question, we instead treat objectives as continuous and bounded logical values to be fulfilled. This fulfillment-centric reasoning serves as a semantic bridge, translating intuitive judgments like "this robot moves 80% as smoothly as I want, and 30% as fast as I want" into mathematically precise, differentiable, and composable fulfillment values that remain aligned with intention throughout optimization. From this perspective, we unify the aforementioned challenges under the guise of accurate, or missing, specification.

Reasoning across the entire stack, from user intention to careful treatment of the embedded systems running on-robot, is essential for bridging the intent-to-reality gap. This wholistic approach enabled the achievement of several state-of-the-art results: the first RL attitude controller to outperform classical PID controllers on real racing quadrotors, reductions in power consumption by 50-80%, live and robust neural network adaptation, and consistent policy search with up to 3$times$ faster learning than Soft Actor Critic across various robotic domains.

== Problem Statement

=== Recurrent Challenges in Robot Learning

==== Objective Specification Difficulty
The challenge of translating intended behavioral objectives into mathematical reward functions that effectively guide reinforcement learning toward desired controller behavior. Practitioners frequently struggle with reward engineering, as there exists a fundamental disconnect between human conceptualization of objectives and the scalar optimization mechanisms employed by RL algorithms #todo[comprehensive_reward_eng_and_shaping]. Recent empirical studies reveal that the vast majority of RL experts rely on trial-and-error approaches for reward design, leading to overfitted and inadequate reward functions #todo[booth2023perils]. The predominant approach of linear scalarization—combining multiple objectives into weighted sums—proves inadequate for expressing the semantic relationships that characterize real robotics tasks #todo[Limitations_of_Scalarisation]. When practitioners intend hierarchical relationships such as "safety should never be compromised for speed," no linear combination of weights can adequately capture this constraint, leading to policies that optimize the stated mathematical objective while failing to embody the practitioner's true intent.

==== Simulation-to-Reality Transfer Failures  
The phenomenon where control policies exhibit erratic behavior upon deployment despite demonstrating strong performance in simulation environments. This brittleness stems from the fundamental mismatch between simplified simulation models and the complexity of real-world dynamics, compounded by critical distributional shifts in the data encountered during deployment #todo[Muratore2022]. Reinforcement learning agents often memorize correct responses to specific simulation states rather than developing systematic models capable of generalizing to novel inputs #todo[Overfitting]. These transfer failures manifest across a spectrum of severity, from visible oscillations and control instability to complete system breakdown #todo[Sim2multi], with empirical studies showing that the majority of simulation-trained agents fail to maintain acceptable performance when deployed on physical hardware #todo[benchmarkingRobo].

==== Catastrophic Forgetting During Adaptation
The tendency for learned control policies to lose previously acquired capabilities when fine-tuned on real-world data, a well-documented phenomenon in continual learning literature #todo[catastrophic-forgetting-wolczyk]. This forgetting occurs rapidly as policies overfit to the limited and often skewed distributions encountered during deployment, losing crucial behaviors that were learned across simulation's broader operational context #todo[catastrophic-forgetting-binici]. The problem is fundamentally exacerbated by the constraints of real-world data collection, where safety considerations naturally limit experience gathering to narrow operational regions, potentially underrepresenting critical scenarios such as emergency maneuvers or boundary conditions. As policies adapt to these biased distributions, they systematically forget the comprehensive behavioral profiles that were carefully encoded during initial training.

==== Sample Inefficiency in Training
The requirement for prohibitively long training runs due to the inherently low sample efficiency of popular reinforcement learning algorithms #todo[sample_efficiency_challenges]. This inefficiency creates particularly severe barriers in robotics applications, where sample collection incurs substantial costs beyond computational resources #todo[RL_challenges]. Physical systems experience wear and degradation during extended training sessions, laboratory equipment becomes costly to maintain in continuous operation, and safety protocols require constant human supervision. For applications demanding direct on-robot training—such as precise sensor calibration or complex manipulation tasks that cannot be adequately simulated—the sample efficiency problem transforms from a computational inconvenience into a fundamental economic barrier that can render RL-based solutions impractical for real-world deployment.

=== A Common Thread

Despite their apparent diversity, these four challenges share a common contributing factor: critical expressiveness limitations in how objectives are specified and optimized in robot learning. Current approaches lack the representational structures necessary to capture and preserve the semantic meaning of practitioner intentions throughout the learning pipeline, which exacerbates each of these challenges.

The fundamental issue lies in the predominant reliance on scalar optimization primitives that cannot adequately represent logical relationships between objectives. When practitioners specify intentions like "achieve both speed and smoothness," they typically mean that both objectives matter, but whichever but less fulfilled objectives should receive more attention, this requires structured composition that linear utilities cannot express. Linear scalarization attempts $R = w_1 R_"smooth" + w_2 R_"speed"$, but this treats both objectives equally regardless of their current satisfaction levels. If smoothness is at 0.3 and speed is at 0.9, the practitioner would want to focus on improving smoothness, but linear combination cannot encode this adaptive prioritization, fundamentally violating the practitioner's intent #todo[Pareto optimal RL]. To account for this, many use sum of squares, but as we will see this can be seen as an instance of a more general operator to maximize.

This semantic erosion propagates throughout the learning pipeline, manifesting as each of the four challenges. Practitioners cannot directly express their intentions, leading to brittle numerical approximations that fail under distributional shifts, cause catastrophic forgetting during adaptation, and require inefficient high-dimensional search over poorly structured optimization landscapes.

The systematic inability to preserve semantic meaning thus transforms what should be direct specification of behavioral intentions into complex approximation problems that accumulate drift throughout robot learning systems.

== Thesis Statement

This thesis defines the *intent-to-reality gap* and addresses portions of it in various forms across general robotics tasks. We argue that minimizing this gap fundamentally requires preserving practitioner intentionality throughout the entire robot learning pipeline---from initial objective specification through architectural design to final deployment.

We demonstrate that intentionality preservation can be achieved through a *fulfillment-based approach*---reconceptualizing robot learning as the satisfaction of continuous and bounded logical values rather than the maximization of scalar rewards. By focusing on the semantic meaning of objectives, we enable their principled combination through continuous logic operators.

Beyond specification, we also show that intentionality extends to architectural and deployment considerations, requiring careful system design for real-world adaptation and robust execution of learned behaviors on real cyber-physical systems.

== Key Contributions

+ *Taxonomy of the Intent-to-Reality Gap* — Identifies the aspects usually overlooked in robot-learning literature (objective expressiveness, behavioural preservation, deployment constraints) and organises them into a coherent taxonomy that complements traditional foci on reward maximisation and sim-to-real transfer.

+ *Fulfilment-Centric Specification (FPL)* — Introduces Fulfilment Priority Logic and the Balanced Policy Gradient algorithm, providing an expressive, differentiable language for multi-objective intent. Thus, allowing the unification of a large portion of the contributions in this thesis.

+ *Universal Behavioural Objectives* — Defines cross-domain objectives such as smoothness and stability (Lyapunov safety) and supplies general integration techniques—including CAPS—that embed these objectives directly in policy architecture.

+ *Adaptation as Specification* — Presents Anchor Critics, reframing on-the-fly adaptation as a multi-fulfilment optimisation that preserves simulation intent and averts catastrophic forgetting during real-world fine-tuning.

+ *Embedded-System Architecture* — Combines asymmetric actor–critic sizing with the SwaNNFlight firmware stack, enabling resource-aware deployment and hot-swappable neural controllers on real-time hardware.

== Empirical Results

Our approach achieves significant quantitative improvements across multiple domains:

- *Sample Efficiency*: Up to 5$times$ faster learning than Soft Actor Critic on standard Gymnasium benchmark tasks @fpl2025
- *Training Stability*: Across Gymnasium benchmarks the standard deviation of learning curves is reduced by 40–50\%, indicating more repeatable training runs @fpl2025
- *Energy Consumption*: Almost 80% power reductions in quadrotor control demonstrated through CAPS regularization @caps2021  
- *Deployment Success*: 100% flight-worthy controllers in real-world quadrotor deployment through our RE+AL framework @how_to_train_your_quadrotor
- *Training Consistency*: 100% successful sim-to-real transfers with reproducible training runs, and 40–50\% lower reward variance across Gymnasium benchmarks @how_to_train_your_quadrotor @fpl2025
- *Transfer Robustness*: Up to 50% power consumption reduction during sim-to-real adaptation using Anchor Critics @anchor_critics

== Scope and Limitations

This work focuses primarily on continuous control problems in robotics applications, with particular emphasis on multi-objective scenarios involving safety, performance, and efficiency trade-offs. While we demonstrate broad applicability across domains, the framework is most beneficial for applications with clear semantic objective relationships.

The thesis addresses behavioral objectives—those directly related to robot behavior—but does not claim to replace all aspects of reward engineering. General objectives (such as regularization terms) are better handled through appropriate algorithm design, while our architectural integration approach specifically targets universal behavioral objectives.

== Impact and Broader Implications

This work has implications beyond robot learning, providing foundations for interpretable multi-objective optimization, human-AI interaction in complex systems, and principled engineering approaches to artificial intelligence. The semantic preservation properties of fulfillment-centric learning offer pathways toward more transparent and reliable AI systems in safety-critical applications.

By transforming robot learning from a trial-and-error process into a principled engineering discipline, this thesis contributes to closing the gap between research advances and practical deployment, potentially accelerating the adoption of learned behaviors in real-world robotics applications. 