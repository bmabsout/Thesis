#import "../lib_cv.typ": primary_color, long_line, diamond, fonts

= Problem Statement and Objectives

The fundamental challenge in robot learning lies in bridging the *intent-to-reality gap*—the disparity between a practitioner's intended robot behavior and what is achieved in reality @def-intent-to-reality. While reinforcement learning offers powerful tools for developing complex controllers @mnih2013playing @silver2016mastering @silver2018general @schrittwieser2020mastering, three critical problems limit its widespread adoption in the real-world @benchmarkingRobo @benchmarkingRL @FU2022104165:

First, practitioners struggle to translate their high-level intentions into precise learning objectives. Current approaches rely on _brittle linear reward composition_ and manual tuning @tokamak @hayes2023brief @Sim2multi @Hwangbo2017ControlOA @learning2drive, making it difficult to express and balance multiple objectives @survey_seq_dec_morl @MODRL_framework. This *intent-to-behavior gap* @def-intent-to-behavior leads to policies that either fail to learn desired behaviors or require prohibitive engineering effort to achieve them @amodei2016concrete.

Second, even when policies perform well in simulation, they often fail to preserve learned behaviors when deployed to real systems @zhao2020sim. Traditional approaches to sim-to-real transfer treat it as a domain adaptation problem @Sim2Real, leading to *catastrophic forgetting* @catastrophic-forgetting-wolczyk where policies maintain performance on common scenarios but fail in critical edge cases @Muratore2022. This challenge is particularly acute in robotics, where failures in rare but important scenarios can lead to system damage or safety violations @Yang2023.

Third, learned policies often exhibit _undesirable behaviors_ that increase computational and energy demands @Chinchali2021. High-frequency oscillations in control signals can cause system overheating and excessive power consumption @NFv2, while complex neural architectures strain limited computational resources @hasani2021liquid. These challenges are particularly relevant for resource-constrained robotic systems that must operate efficiently in the real world.

I argue that addressing these challenges requires *fundamentally rethinking* (see @introduced-concepts) how practitioners express and compose their intentions throughout the learning process. Instead of focusing solely on optimization algorithms @PPO @DDPG @SAC @TD3, existing works provide motivation for developing principled frameworks for:
1. Specifying behavioral objectives in ways that capture intended relationships and trade-offs @Belta_Temporal @Wingate_Temporal_MORL @SAKAWA199819
2. Preserving learned behaviors during transfer while enabling controlled adaptation @MetaSimToReal @Nagabandi2019LearningTA
3. Ensuring efficient deployment through resource-aware policy design @Chinchali2021 @orevi2023

My research addresses these challenges through four interconnected objectives:

1. *Structured Objective Specification:* Develop a principled framework for composing behavioral objectives that enables practitioners to directly express intended relationships and trade-offs. This includes both the mathematical foundations (@math-foundations) for combining objectives and practical tools for specifying complex behaviors @AQS.

2. *Intention-Preserving Transfer:* Create methods that maintain critical behaviors during sim-to-real transfer (@def-sim-to-real) by treating adaptation as multi-objective optimization over Q-values from both domains (@anchor-critics). This ensures policies can adapt to reality while preserving behaviors learned in simulation.

3. *Resource-Aware Control:* Design techniques for learning controllers that are efficient in both computation and energy usage @def-resource. This spans from action smoothness for energy efficiency to architectural optimization for reduced inference cost (@actor-critic-asymmetry).

4. *Practical Validation:* Demonstrate the effectiveness of these approaches through systematic evaluation on increasingly complex robotic systems, from benchmark simulation scenarios to racing quadrotor attitude control. This includes developing open-source tools and system designs to enable broader adoption (@anchor-critics).

Through these objectives, I aim to transform how practitioners develop robotic systems by providing principled ways to express intentions, preserve behaviors, and ensure efficient deployment. The following sections detail my progress toward these goals and outline the remaining work needed to advance this vision. 