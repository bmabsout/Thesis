#import "../lib_cv.typ": *
#import "../../figures/mdp.typ": mdp
= Definitions and Literature Review

== Standard Fundamentals

=== Discrete-Time Markov Decision Processes <def-mdp>
The standard formalization of sequential decision making @SuttonBarto @barto2017some, defined by a tuple $angle.l #S, #A, PP, #R, gamma angle.r$, where #S is the state space, #A is the action space, $PP(#stp1|#st,#at)$ defines state transition probabilities, #R specifies rewards, and $gamma$ is a discount factor. In robot learning, states typically represent sensor readings and physical configurations, while actions correspond to motor commands.

#figure(
  mdp,
  caption: [The Markov Decision Process showing how a state #st in the state space #S and action $#at ~ pi(#st)$ determine the probability distribution $PP(#stp1|#st,#at)$ over next states. Dashed arrows (#box[#{import "@preview/cetz:0.3.1"; cetz.canvas(cetz.draw.line((0,0), (0.6,0), mark: (end: "triangle"), stroke: (dash: "dashed", thickness: 0.7pt)))}]) indicate sampling from a distribution.]
)

=== Policies and Returns <def-policy>
A policy $pi(#st)$ defines the probability distribution over actions #A in state #st. The goal in RL is to find a policy that maximizes expected returns, defined as the discounted sum of rewards: $expect [ sum_(t=0)^infinity gamma^t reward(R)(#st,#at,#stp1)]$. The discount factor $gamma$ determines how much to prioritize immediate versus future rewards.

=== Value Functions and Q-Functions <def-value-function>
A #Q\-value function $#Q^pi$ represents the expected return when following policy $pi$ from state #state($s_0$) and action #action($a_0$):

$ #Q^pi (#state($s_0$), #action($a_0$)) = expect [ sum_(t=0)^infinity gamma^t reward(R)(#st,#at,#stp1) | #stp1 ~ PP(#stp1|#st,#at), #at ~ pi(#st) ] $

Similarly, a value function $#V^pi$ represents the expected return when in state #state($s_0$) and then following $pi$:

$ #V^pi (#state($s_0$)) = expect [ #Q^pi (#state($s_0$), #action($a_0$)) | #action($a_0$) ~ pi(#state($s_0$)) ] $

These functions form the basis of deep reinforcement learning @DQN_paper, as they are commonly approximated by neural networks and represent the performance of a policy according to our notion of optimality, namely, maximizing the expected reward.

These functions are also central to my work in two key ways:
+ As a basis for objective composition in AQS, where normalized Q-values enable intuitive specification of behavioral trade-offs
+ As anchors for domain transfer, where simulation Q-values preserve critical behaviors during real-world adaptation

=== Multi-Objective RL <def-morl>
Multi-objective reinforcement learning extends the standard MDP framework to handle multiple reward signals simultaneously @survey_seq_dec_morl @practical_guide. Instead of a single scalar reward #R, the agent receives a vector of rewards $reward(arrow(R))$ corresponding to different objectives. This introduces the challenge of balancing competing objectives @SAKAWA199819, forcing us to eventually make a choice of what objectives are more important than others, the scalarization function that combines them into a single objective is called the utility function. Much MORL work focuses on defining and finding Pareto-optimal policies @MODRL_framework that make principled trade-offs between different goals.

=== Sim-to-Real Transfer <def-sim-to-real>
The process of deploying policies trained in simulation to real-world systems @zhao2020sim, encompassing both the technical challenges of domain adaptation @golemo2018sim and the practical constraints of physical deployment @yu2019sim. This fundamental concept bridges the gap between idealized training environments and the complexities of real-world operation @Sim2Real.

== Introduced Conceptual Framework <introduced-concepts>
=== Core Concepts
==== The Intent-to-Behavior Gap <def-intent-to-behavior>
The fundamental challenge of translating a practitioner's intended policy behavior into a mathematical specification that reliably produces that behavior when optimized @hayes2023brief @amodei2016concrete. This gap exists in any reinforcement learning system, as practitioners must convert high-level intentions (like "move smoothly and efficiently") into concrete optimization objectives. Traditional approaches leave practitioners to define scalar rewards and combine objectives through linear scalarization, which often fails to capture the nuanced relationships between different behavioral aspects. More sophisticated specification techniques, such as algebraic composition methods or formal logic frameworks @Belta_Temporal @Wingate_Temporal_MORL, aim to minimize this gap by providing principled tools for expressing behavioral requirements.

==== The Intent-to-Reality Gap <def-intent-to-reality>
A compound challenge in robot learning that combines the intent-to-behavior gap (the challenge of specifying desired behaviors through mathematical objectives) with the sim-to-real gap (the challenge of preserving these behaviors during real-world deployment) @zhao2020sim @Muratore2022. This gap represents the full distance between a practitioner's intentions and the actual behavior of deployed systems @benchmarkingRobo @benchmarkingRL @FU2022104165, making it a central challenge in practical robot learning.

==== Expressive Reinforcement Learning (XRL) <def-xrl>
A subfield of reinforcement learning focused on minimizing the intent-to-behavior gap through principled frameworks for objective specification and composition. Key aspects include:
1. Algebraic approaches to objective composition that maintain semantic meaning, building on foundational work @Hajek1998 (e.g., using power-mean operators for intuitive combination of #Q\-values as in AQS)
2. Formal methods for specifying policy behaviors @Belta_Temporal (e.g., temporal logic for constraint specification @Wingate_Temporal_MORL)

The key distinction from traditional multi-objective RL @survey_seq_dec_morl @SAKAWA199819 is the focus on providing practitioners with mathematically grounded tools for expressing objective composition. While early work established foundational principles @shelton2001balancing @dynamicweights, modern approaches emphasize intuitive specification methods that preserve semantic intent @tokamak @MODRL_framework. This addresses limitations in traditional reward engineering methods that often require significant domain expertise and manual tuning @Sim2multi @Hwangbo2017ControlOA @learning2drive.

==== Behavioral Retention <def-retention>
The degree to which a policy maintains its learned behaviors when transferred to new domains or adapted to new conditions @catastrophic-forgetting-wolczyk @catastrophic-forgetting-binici. We quantify this through multi-objective evaluation of #Q values across domains, particularly focusing on performance in critical scenarios that may occur rarely but have high importance @Yang2023 @Cheng_Orosz_Murray_Burdick_2019. This provides a more nuanced view than traditional average-case metrics @benchmarkingRobo @benchmarkingRL.


==== Behavioral Objectives <def-behavioral-objectives>
We use this term to encompass both the high-level intentions a practitioner wants to achieve and their formal expression as optimization targets. Our work demonstrates this through several key examples: smooth motor control achieved through temporal and spatial action similarity in CAPS, preservation of critical scenario performance through Q-value anchoring, resource efficiency through architectural optimization, and complex objective composition through algebraic Q-value operations in AQS. This structured approach distinguishes our objectives from simple reward functions, emphasizing their principled nature and composability.

=== Mathematical Framework <math-foundations>
==== Power-Mean as a Logical Operator <def-pmean>
  $ pmean_p (x_1, ..., x_n) = (1/n sum_(i=1)^n x_i^p)^(1/p) $ <power-mean>
where $x_i in [0,1]$ are the values being composed. The parameter $p in RR$ controls the attraction to larger or smaller values, with several notable special cases:

#align(center)[
#table(
  stroke: (thickness: 0.4pt),
  columns: (auto, auto, auto),
  inset: 7pt,
  align: horizon,
  [*Parameter*], [*Name*], [*Operation*],
  [$p -> -infinity$], [Minimum], $min(x_1, ..., x_n)$,
  [$p = -1$], [Harmonic Mean], $1/(sum_(i=1)^n 1/x_i)$,
  [$p = 0$], [Geometric Mean], $(product_(i=1)^n x_i)^(1/n)$,
  [$p = 1$], [Arithmetic Mean], $1/n sum_(i=1)^n x_i$,
  [$p -> infinity$], [Maximum], $max(x_1, ..., x_n)$
)
]

For finite values, $p < 0$ biases toward the minimum value (pessimistic composition), while $p > 0$ biases toward the maximum (optimistic composition). The power-mean has several key properties:

+ *Range Preservation:* If $x_i in [0,1]$ then $pmean_p (x_1,...,x_n) in [0,1]$
+ *Commutativity:* $pmean_p (x_1, ..., x_n) = pmean_p (x_sigma(1), ..., x_sigma(n))$ for any permutation $sigma$
+ *Idempotence:* $pmean_p (x, ..., x) = x$
+ *Monotonicity in x:* If $x_i <= x_j$ then $pmean_p (x_1, ..., x_i, ..., x_n) <= pmean_p (x_1, ..., x_j, ..., x_n)$
+ *Monotonicity in p:* If $p < q$ then $pmean_p (x_1, ..., x_n) <= pmean_q (x_1, ..., x_n)$
+ *$and$ semantics at 0 and 1:* if $x_i in {0,1}$ and $p <= 0$ then $pmean_p (x_1, ..., x_n) = x_1 and ... and x_n$
+ *$or$ semantics at 0 and 1:* if $x_i in {0,1}$ and $p <= 0$ then
#align(center, $1-pmean_p (1-x_1, ..., 1-x_n) = x_1 or ... or x_n$)

These properties are especially useful for use as a continuous logical operator. It allows for smooth interpolation between different logical operators with $p$ being small representing notions similar as that of an "and", and $p$ being large representing a notion of an "or". Being able to smoothly interpolate between these two extremes allows for a more intuitive specification of objective composition. And range preservation allows for the operator to be numerically stable.


=== Evaluation Metrics
==== Action Roughness <def-roughness>
A quantitative measure of high-frequency components in a policy's action outputs, first introduced in "Regularizing Action Policies for Smooth Control with Reinforcement Learning" @CAPS (where we incorrectly termed it a "smoothness metric", as lower values indicate more smoothness). We measure action roughness through frequency analysis of control signals using:

$ "Roughness" = sum_(i=1)^n (X_i f_i)/(sum_(i=1)^n X_i f_s) $ <roughness>

where $X_i$ is the amplitude of the $i^"th"$ frequency component $f_i$, and $f_s$ is the sampling frequency. This metric provides the mean weighted normalized frequency of action outputs, with higher values indicating more high-frequency components in the control signal. In motor control applications, high roughness values can lead to catastrophic outcomes including motor burnout, while lower values indicate more sustainable actuation patterns. While originally introduced as a smoothness metric, we adopt the more precise term "roughness" here as the metric directly measures the presence of high-frequency components rather than their absence. This metric addresses a critical gap in the field where action signal quality was previously assessed through ad-hoc or qualitative methods, making it difficult to predict potential hardware damage before deployment.

==== Resource Efficiency <def-resource>
A comprehensive measure encompassing multiple dimensions of system efficiency @Chinchali2021 @orevi2023:

+ *Power Efficiency:* Direct energy consumption by actuators and hardware, quantified through metrics like average power draw and peak current demands @NFv2. This includes both steady-state operation costs and transient spikes from high-frequency control signals @benchmarkingRobo.

+ *Computational Efficiency:* Resources required for policy execution @hasani2021liquid, including:
  - Inference time: Latency between state observation and action selection
  - Memory usage: Both runtime memory and model parameter storage
  - Hardware utilization: CPU/GPU load and thermal considerations

+ *Training Efficiency:* Resources consumed during learning @henderson2018deep @islam2017reproducibility:
  - Sample efficiency: Number of environment interactions needed
  - Gradient steps: Computational work per data point
  - Wall-clock time: Total duration of training process
  - Memory requirements: Both for replay buffers and gradient computation

These metrics are particularly crucial for resource-constrained robotic systems @Hwangbo2017ControlOA, where inefficiencies in any dimension can make deployment impractical.

== Related Work

This section reviews key developments in reinforcement learning that address the intent-to-reality gap in robot learning, organized around three fundamental challenges: objective specification, sim-to-real transfer, and energy-efficient control in the real world.

=== Objective Specification and Composition
Traditional reinforcement learning approaches often struggle to capture complex behavioral requirements, leading practitioners to develop increasingly sophisticated methods for reward specification. A compelling example is found in tokamak plasma control @tokamak, where researchers implicitly developed a structured approach to composing control objectives to manage the extreme complexity of fusion reactor control. Their success in this challenging domain demonstrates both the necessity and natural emergence of formal frameworks for objective specification. However, their approach, while effective, required significant domain expertise to develop and lacked explicit formalization. This highlights a key challenge: how to make such structured specification approaches more accessible while maintaining their expressive power. Several research directions have emerged to address this challenge:

==== Multi-Objective RL
Classical approaches focus on finding Pareto-optimal policies @SAKAWA199819 @MODRL_framework for competing objectives, but often lack intuitive ways to specify trade-offs @survey_seq_dec_morl. These methods typically rely on linear scalarization or constrained optimization @shelton2001balancing @dynamicweights, which can be limiting when objectives have complex interactions. The tokamak control problem @tokamak exemplifies these limitations, where practitioners had to develop sophisticated objective structures implicitly to achieve the required control performance.

==== Formal Methods
Temporal logic frameworks @Belta_Temporal and propositional logic approaches @Wingate_Temporal_MORL provide rigorous specifications but can be challenging for practitioners to use effectively with reinforcement learning. Recent work has explored more accessible formal methods that maintain mathematical rigor while improving usability @neural_lyapunov. This represents a step toward formalizing the kinds of structured approaches that emerge naturally in complex domains like tokamak control.

==== Expressive RL
Early foundational work explored algebraic approaches to objective composition @Fleming1986HowNT @Hajek1998, establishing mathematical principles for combining objectives. Building on these foundations, modern approaches to structured reward design @Sim2multi have focused on maintaining semantic meaning during composition. These methods aim to make explicit the kinds of objective structures that practitioners develop implicitly, providing a formal foundation for composing objectives that preserves their semantic intent. This addresses a limitation of work that has focused on pure reward engineering @tokamak, where the structured composition of objectives remained implicit in the domain expertise rather than being formally captured.

=== Sim-to-Real Transfer
The challenge of transferring policies from simulation to reality remains central to practical robot learning @zhao2020sim. Current approaches broadly fall into two categories:

==== Environment-Focused Methods
Domain randomization @golemo2018sim and adaptive architectures @Hwangbo2017ControlOA attempt to bridge the reality gap through robust training. However, these approaches often struggle with accurately modeling complex real-world dynamics @PasikDuncan1996AdaptiveC and can lead to oscillatory control responses @benchmarkingRobo.

==== Policy-Focused Methods
While fine-tuning approaches can adapt to real systems, they struggle with catastrophic forgetting @catastrophic-forgetting-wolczyk, where policies maintain high rewards on common scenarios but fail on rare, critical cases @catastrophic-forgetting-binici. Recent work has shown that structured training environments @Sim2Real and multi-objective optimization across domains @Muratore2022 can help maintain critical behaviors. Direct policy optimization through regularization @shen2020deep has also shown promise in improving transfer success.

=== Efficient Deployment
Practical deployment requires policies that are efficient in both computation and physical resource usage @Chinchali2021 @orevi2023. Three key areas have emerged:

==== Control Optimization
Explicit regularization @liu2019regularization and adaptive control methods @model_quad_adapt @Song2020ProvablyEM help maintain smooth and efficient behavior. This builds on classical work in optimal control @ZieglerNichols, while addressing the unique challenges of learned policies, particularly in reducing power consumption and system wear @shen2020deep.

==== Architectural Efficiency
Recent advances in asymmetric actor-critic methods @islam2017reproducibility and network compression @Han2016DeepCC demonstrate that smaller networks can achieve comparable performance. Liquid neural networks @hasani2021liquid @ltc2018 show promise for adaptive control with reduced model complexity.

==== Resource-Aware Design
Joint optimization of computational and physical efficiency @Hwangbo2017ControlOA has become crucial for practical robotics, particularly in embedded systems @Chinchali2021 where network dependencies can limit autonomy @orevi2023.

=== Open Challenges
Several fundamental challenges remain in bridging the intent-to-reality gap:

1. *Objective Specification:* While formal methods and expressive frameworks provide tools for composition @Belta_Temporal @Wingate_Temporal_MORL, specifying complex objectives in a way that reliably produces intended behaviors remains difficult @tokamak @hayes2023brief.

2. *Effective Transfer:* Current approaches lack effectiveness in behavioral preservation @catastrophic-forgetting-wolczyk @catastrophic-forgetting-binici, particularly for safety-critical scenarios @Yang2023. This limits deployment in high-stakes applications @Cheng_Orosz_Murray_Burdick_2019.

This dissertation addresses these challenges through a unified approach that combines expressive objective specification which is used to achieve robust transfer and efficient deployment. Through frameworks like AQS, CAPS, and Anchor Critics, we demonstrate how structured approaches to reinforcement learning can minimize the intent-to-reality gap in practical robot learning. 