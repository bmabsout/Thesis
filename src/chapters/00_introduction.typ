#import "../commands.typ": *
#import "../style.typ": *

= Introduction <chap:intro>

Contemporary robot learning has achieved remarkable successes in controlled environments, from game-playing agents mastering complex strategies @alphago to robotic manipulation systems demonstrating impressive dexterity in laboratory settings @openai2018learning. However, a significant gap persists between these research achievements and practical deployment in real-world robotics applications. Practitioners repeatedly encounter:
+ *Objective-specification difficulty*: scalar rewards are hard to craft so that they reflect designer intent #changed[@booth2023perils @comprehensive_reward_eng_and_shaping].
+ *Simulation–reality brittleness*: controllers that perform well in simulation often oscillate or crash on hardware #changed[@benchmarkingRobo @Sim2Real @Sim2multi].
+ *Catastrophic forgetting*: policies that lose previously learned behaviors during adaptation to real data #changed[@catastrophic-forgetting-wolczyk @catastrophic-forgetting-binici].
+ *Sample inefficiency*: popular RL algorithms are sample-hungry, requiring lengthy, expensive data collection #changed[@sample_efficient_rl].
Taken together, these shortcomings underscore the breadth of the *intent-to-reality gap*---the discrepancy between designer intention and deployed robot behavior.

Examining what contributes to this gap, we identify critical expressiveness limitations in how objectives are specified and optimized. User intentions encoded as scalar rewards often fail to capture the behaviors produced by policy optimization. Even in simulated benchmark tasks designed by researchers in the field, these reward functions tend to be difficult to interpret, often contain redundant terms, and even worse, produce algorithm-, environment-, and seed-specific formulations @benchmarkingRobo.

If rewards are the answer, then what is the question? The _reward hypothesis_ by @SuttonBarto states that scalar rewards can precisely represent all that we care about in robot control. However, it says nothing about the difficulty in expressing such rewards. Can adding more structure to this interface of value and reward functions help us express our intentions more precisely#changed[ and efficiently]?

To address #changed[this key research question], we instead treat objectives as continuous and bounded logical values to be fulfilled. This fulfillment-centric reasoning serves as a semantic bridge, translating intuitive judgments like "this robot moves 80% as smoothly as I want, and 30% as fast as I want" into mathematically precise, differentiable, and composable fulfillment values that remain aligned with intention throughout optimization. From this perspective, we unify the aforementioned challenges under the guise of accurate, or missing, specification.

Reasoning across the entire stack, from user intention to careful treatment of the embedded systems running on-robot, is essential for bridging the intent-to-reality gap. This wholistic approach enabled the achievement of #changed[several improvements over state-of-the-art results]: the first RL attitude controller to outperform classical PID controllers on real racing quadrotors, reductions in power consumption by 50-80% compared to Neuroflight as well as smoothness improvements accross Gymnasium benchmarks, live and robust neural network adaptation, and consistent policy search with up to 6.4$times$ better sample efficiency than baseline methods across various robotic domains.

== Problem Statement <chap:intro:problem>

=== Recurrent Challenges in Robot Learning <chap:intro:problem:challenges>

==== Objective Specification Difficulty <def:obj_spec_difficulty>
The challenge of translating intended behavioral objectives into mathematical reward functions that effectively guide reinforcement learning toward desired controller behavior. Practitioners frequently struggle with reward engineering, as there exists a fundamental disconnect between human conceptualization of objectives and the scalar optimization mechanisms employed by RL algorithms @comprehensive_reward_eng_and_shaping. Recent empirical studies reveal that the vast majority of RL experts rely on trial-and-error approaches for reward design, leading to overfitted and inadequate reward functions @booth2023perils. The predominant approach of linear scalarization---combining multiple objectives into weighted sums---proves inadequate for expressing the semantic relationships that characterize real robotics tasks @Limitations_of_Scalarisation. When practitioners intend hierarchical relationships such as "safety should never be compromised for speed," no linear combination of weights can adequately capture this constraint, leading to policies that optimize the stated mathematical objective while failing to embody the practitioner's true intent.

==== Simulation-to-Reality Transfer Failures <def:sim2real_failures>
The phenomenon where control policies exhibit erratic behavior upon deployment despite demonstrating strong performance in simulation environments. This brittleness stems from the fundamental mismatch between simplified simulation models and the complexity of real-world dynamics, compounded by critical distributional shifts in the data encountered during deployment @Muratore2022. Reinforcement learning agents often memorize correct responses to specific simulation states rather than developing systematic models capable of generalizing to novel inputs @Overfitting. These transfer failures manifest across a spectrum of severity, from visible oscillations and control instability to complete system breakdown @Sim2multi, with empirical studies showing that the majority of simulation-trained agents fail to maintain acceptable performance when deployed on physical hardware @benchmarkingRobo.

==== Catastrophic Forgetting During Adaptation <def:catastrophic_forgetting>
The tendency for learned control policies to lose previously acquired capabilities when fine-tuned on real-world data, a well-documented phenomenon in continual learning literature @catastrophic-forgetting-wolczyk. This forgetting occurs rapidly as policies overfit to the limited and often skewed distributions encountered during deployment, losing crucial behaviors that were learned across simulation's broader operational context @catastrophic-forgetting-binici. The problem is fundamentally exacerbated by the constraints of real-world data collection, where safety considerations naturally limit experience gathering to narrow operational regions, potentially underrepresenting critical scenarios such as emergency maneuvers or boundary conditions. As policies adapt to these biased distributions, they systematically forget the comprehensive behavioral profiles that were carefully encoded during initial training.

==== Sample Inefficiency in Training <def:sample_inefficiency>
The requirement for prohibitively long training runs due to the inherently low sample efficiency of popular reinforcement learning algorithms. This inefficiency creates particularly severe barriers in robotics applications, where sample collection incurs substantial costs beyond computational resources @RL_challenges. Physical systems experience wear and degradation during extended training sessions, laboratory equipment becomes costly to maintain in continuous operation, and safety protocols require constant human supervision. For applications demanding direct on-robot training---such as precise sensor calibration or complex manipulation tasks that cannot be adequately simulated---the sample efficiency problem transforms from a computational inconvenience into a fundamental economic barrier that can render RL-based solutions impractical for real-world deployment.

=== A Common Thread <chap:intro:problem:common_thread>

Despite their apparent diversity, these four challenges share a common contributing factor: critical expressiveness limitations in how objectives are specified and optimized in robot learning. Current approaches lack the representational structures necessary to capture and preserve the semantic meaning of practitioner intentions throughout the learning pipeline, which exacerbates each of these challenges.

The fundamental issue lies in the predominant reliance on scalar optimization primitives that cannot adequately represent logical relationships between objectives. When practitioners specify intentions like "achieve both speed and smoothness," they typically mean that both objectives matter, but whichever objectives are less fulfilled should receive more attention. This requires structured composition that linear utilities cannot express. Linear scalarization attempts $reward(R) = w_"smooth" reward(R_"smooth") + w_"speed" reward(R_"speed")$, but this treats both objectives equally regardless of their current satisfaction levels. If smoothness is at 0.3 and speed is at 0.9, the practitioner would want to focus on improving smoothness, but linear combination cannot encode this adaptive prioritization, fundamentally violating the practitioner's intent @Limitations_of_Scalarisation. To account for this, many use sum of squares, but as we will see this can be seen as an instance of a more general operator to maximize.

This semantic erosion propagates throughout the learning pipeline, manifesting as each of the four challenges #changed[listed in @chap:intro:problem:challenges]. Practitioners cannot directly express their intentions, leading to brittle numerical approximations that fail under distributional shifts, cause catastrophic forgetting during adaptation, and require inefficient high-dimensional search over poorly structured optimization landscapes.

The systematic inability to preserve semantic meaning thus transforms what should be direct specification of behavioral intentions into complex approximation problems that accumulate drift throughout robot learning systems.

== Thesis Statement <chap:intro:thesis>

This thesis defines the *intent-to-reality gap* and addresses portions of it in various forms across general robotics tasks. We argue that minimizing this gap fundamentally requires preserving practitioner intentionality throughout the entire robot learning pipeline---from initial objective specification through architectural design to final deployment.

We demonstrate that intentionality preservation can be achieved through a *fulfillment-based approach*---reconceptualizing robot learning as the satisfaction of continuous and bounded logical values rather than the maximization of scalar rewards. By focusing on the semantic meaning of objectives, we enable their principled combination through continuous logic operators.

Beyond specification, we also show that intentionality extends to architectural and deployment considerations, requiring careful system design for real-world adaptation and robust execution of learned behaviors on real cyber-physical systems.

== Summary of Contributions <chap:intro:contributions>

+ *A Formal Taxonomy of the Intent-to-Reality Gap:* In @chap:intent_to_reality we deconstruct the challenge of deploying reliable robots into three cascaded sub-problems: the _intent-to-specification gap_, the _specification-to-behavior gap_, and the _simulation-to-reality gap_. We show how these gaps are produced by errors of methodology for _encoding_, _optimization_ and _execution_, affecting _behavior_. We then describe how various disparate methods unify under a common precise definition. We also .

+ *Fulfillment-Based Specification:* @chap:encoding_intentionality introduces Fulfillment Priority Logic and the Balanced Policy Gradient algorithm, providing an expressive, differentiable language for multi-objective intent. Thus, allowing the unification of a large portion of the contributions in this thesis.

+ *Universal Behavioral Objectives:* In @chap:ubo we establish the architectural approach to widely applicable objectives such as smoothness, demonstrating how Conditioning for Action Policy Smoothness (CAPS) can be integrated directly into policy optimization rather than through reward engineering. This represents a principled separation between universal behavioral requirements and task-specific objectives.

+ *Adaptation as Data-Driven Specification Composition:* @chap:adaptation_anchors reveals that catastrophic forgetting during real-world adaptation stems from a fundamental misunderstanding of what value functions represent. We show that value functions are _derived specifications_ that encode not just reward functions but the entire data distribution context in which they were learned. Adaptation becomes a problem of composing specifications from different distributional contexts, leading to Anchor Critics as a natural implementation of this insight.

+ *Embedded-System Focused Architecture:* In @chap:architecture, we show that combining asymmetric actor–critic sizing with the SwaNNFlight firmware stack enables resource-aware deployment and hot-swappable neural controllers on real-time hardware.

== Empirical Results <chap:intro:results>

Our approach achieves significant quantitative improvements across multiple domains:

*Sample Efficiency*: Up to 6.4$times$ faster learning than DDPG on LunarLanderContinuous-v2 and 5.6$times$ faster on Hopper-v4 using our Balanced Policy Gradient algorithm

*Training Stability*: Across Gymnasium benchmarks the standard deviation of learning curves is reduced by 40–50\%, indicating more repeatable training runs

*Energy Consumption*: Almost 80% power reductions in quadrotor control demonstrated through CAPS regularization

*Deployment Success*: 100% flight-worthy controllers in real-world quadrotor deployment through our RE+AL framework

*Training Consistency*: 100% successful sim-to-real transfers with reproducible training runs, and 40–50\% lower reward variance across Gymnasium benchmarks

*Transfer Robustness*: Up to 50% power consumption reduction during sim-to-real adaptation using Anchor Critics

== Scope and Limitations <chap:intro:scope>

This dissertation centers on continuous control for robotic systems, particularly where performance, safety, and efficiency objectives create complex trade-offs. While fulfillment-based thinking is broadly applicable, its benefits are most pronounced in domains where practitioners can articulate clear, structured relationships between objectives. The design of the fulfillment functions themselves, while more intuitive than tuning scalar rewards, still requires domain expertise.

Furthermore, our architectural contributions, such as CAPS and SwaNNFlight, are validated on high-performance quadrotors. While the principles of action regularization and resource-aware deployment are general, their specific implementations may require adaptation for other robotic platforms with different hardware constraints or dynamics.
