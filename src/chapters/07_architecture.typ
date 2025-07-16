= Architectural Considerations <chap:architecture>

Throughout this thesis, we have developed a principled framework for bridging the intent-to-reality gap through fulfillment-centric design. We have shown how to encode complex intentions, compose them using FPL, incorporate universal behavioral objectives, and prevent catastrophic forgetting through specification composition. However, none of these theoretical advances matter if we cannot deploy them on real robotic hardware with its severe computational and memory constraints.

This chapter addresses the critical systems architecture challenges that arise when transitioning from theory to practice. Real robotic platforms—particularly aerial vehicles—operate under extreme constraints: limited computational power (often just ARM Cortex-M processors), minimal memory (measured in kilobytes, not gigabytes), strict real-time requirements (sub-millisecond control loops), and the need for absolute reliability. These constraints fundamentally shape how we implement fulfillment-centric policies.

We present three complementary systems contributions that enable practical deployment:

+ *Neuroflight*: The foundational framework that first demonstrated neural network control on embedded flight controllers, revealing the systems-level reality gap where 730Hz actual control differs fundamentally from 1000Hz simulated control.

+ *Asymmetric Actor-Critic*: A principled approach to network minimization that breaks the unnecessary symmetry between actor and critic architectures, achieving up to 97% reduction in actor weights while maintaining performance.

+ *SwaNNFlight*: The complete system architecture for deploying compositional adaptation on real drones through an autonomous-first design, enabling live neural network updates without interrupting flight operations.

Together, these contributions complete the path from theoretical framework to practical deployment, demonstrating that fulfillment-centric design is not just conceptually powerful but also practically viable on real robotic systems.

== The Challenge of Embedded Deployment <chap:architecture:challenge>

Deploying learned policies on real robotic platforms introduces constraints that are often overlooked in research settings. More critically, these constraints themselves become part of the reality gap that must be addressed:

*Computational Constraints*: Flight controllers typically use ARM Cortex-M4/M7 processors running at 168-216 MHz. Compare this to the GPUs used for training, which offer thousands of times more computational power. Yet the control loop must run at 1kHz or faster for stable flight. As we discovered with Neuroflight, even achieving 730Hz creates a significant reality gap.

*Memory Constraints*: Embedded platforms have severe memory limitations—often just 512KB-1MB of flash and 128-256KB of RAM. A typical deep RL policy network can easily exceed these limits before considering the flight control software itself. Memory placement also affects timing—SRAM access is predictable, while flash access introduces variable latency.

*Real-Time Requirements*: Control loops must execute with deterministic timing. A single missed deadline can cause catastrophic failure. Standard deep learning frameworks prioritize throughput over latency predictability, making them unsuitable for hard real-time systems. Variance in execution time—jitter—can be as damaging as slow average performance.

*The Hidden Reality Gap*: Most critically, the embedded system itself creates a reality gap. Training assumes perfect timing, zero latency, and infinite precision. Reality provides none of these:
- Control actions arrive 1-2ms after state observation (sensor latency + computation)
- Inference time varies by up to 10% due to cache misses and interrupts
- Fixed-point quantization changes network behavior in subtle ways
- The control frequency itself differs from simulation (730Hz vs 1000Hz)

*Power Constraints*: Every computation draws power, directly impacting flight time. Inefficient inference can reduce flight duration from 20 minutes to 5 minutes. More subtly, power draw affects voltage stability, which impacts motor response—another source of reality gap.

*Reliability Requirements*: Unlike simulation where failures simply reset the environment, real-world failures can destroy hardware and endanger people. The system must handle edge cases gracefully and maintain safe operation even during updates or partial failures.

These constraints create a fundamental tension: our fulfillment-centric framework benefits from expressive neural networks to capture complex behaviors, but embedded platforms demand minimal, efficient implementations with predictable timing. Resolving this tension required developing new system architectures and optimization techniques that explicitly account for the systems-level reality gap.

== Neuroflight: Establishing the Baseline <chap:architecture:neuroflight>

Before we could deploy sophisticated techniques like Anchor Critics, we needed to establish that neural network control was even feasible on embedded flight controllers. Neuroflight, our first system contribution, demonstrated this possibility while revealing critical insights about the systems-level reality gap.

=== The Timeliness Gap <chap:architecture:neuroflight:timeliness>

A fundamental challenge we discovered is that the reality gap extends beyond dynamics to the control system itself. In simulation, neural network inference runs at a perfect 1000Hz. On real hardware (ARM Cortex-M4 at 216MHz), the same network achieves only 730Hz. This 27% frequency reduction has profound implications:

+ *Delay*: The controller responds 370μs later than simulated, accumulating phase errors
+ *Jitter*: Real inference time varies by ±50μs due to cache effects and interrupts
+ *Missed Deadlines*: Occasional inference spikes can cause the control loop to miss its deadline entirely

These timing discrepancies mean that even with perfect dynamics simulation, policies trained assuming 1000Hz control will behave differently at 730Hz. This systems-level reality gap is often overlooked but proved critical in our work.

=== Core Innovations <chap:architecture:neuroflight:innovations>

Neuroflight addressed these challenges through several key insights. First, *deterministic execution* was achieved by modifying the firmware to guarantee fixed execution order, minimizing jitter from 200μs to under 50μs. Second, *optimized inference* was implemented through custom fixed-point implementations and careful memory layout, achieving consistent sub-millisecond inference (1.37ms worst-case). Finally, a *minimal architecture* was developed through systematic exploration, revealing that networks with 2 hidden layers of 64 neurons each provided the best trade-off between expressiveness and timing predictability. The compiled network occupied just 12KB—small enough to fit in tightly-coupled memory for deterministic access times.

=== Compilation Pipeline <chap:architecture:neuroflight:compilation>

The path from TensorFlow model to embedded execution required careful engineering involving several steps. *Graph freezing* converts the training graph to an inference-only representation, while *quantization* performs 8-bit fixed-point conversion with minimal accuracy loss. *AOT compilation* uses TensorFlow's XLA compiler to generate position-independent ARM code, and finally *firmware integration* employs custom linker scripts to place the network in CCM (Core-Coupled Memory) for predictable timing.

This pipeline ensures that the deployed network behaves identically to its quantized simulation counterpart, eliminating one source of reality gap.

=== Impact and Limitations <chap:architecture:neuroflight:impact>

Neuroflight proved that neural network control on embedded platforms was viable, but revealed new challenges. The system achieved several important milestones: it provided the first demonstration of learned control at 730Hz on embedded flight controllers, maintained consistent inference timing with less than 5% jitter, and enabled successful flights with neural attitude control.

However, the system also exposed significant limitations that would guide future development. Networks were fixed at deployment with no adaptation capability, meaning the system could not learn or improve from new experiences. The 730Hz control rate itself created an irreducible reality gap compared to the 1000Hz simulation assumption. Single reward optimization proved inadequate for capturing the complex, multi-objective nature of flight control. Additionally, high-frequency oscillations at 330Hz caused motor heating and excessive power drain, reducing flight efficiency.

These limitations, particularly the timing-induced reality gap, motivated our subsequent work on more sophisticated architectures.

== Asymmetric Actor-Critic: Policy Minimization <chap:architecture:asymmetric_ac>

Having established feasibility with Neuroflight, we next addressed the challenge of deploying more complex policies within embedded constraints. A key insight came from questioning a fundamental assumption in actor-critic reinforcement learning: why do actors and critics use the same network architectures?

=== The Symmetry Assumption <chap:architecture:asymmetric_ac:symmetry>

Actor-critic methods separate the policy (actor) from the value function estimator (critic). Yet curiously, standard implementations couple their architectures—if the critic has layers of size $|256, 256|$, so does the actor. This symmetry is not theoretically required but is baked into popular frameworks like OpenAI Baselines, Stable Baselines, and others.

We hypothesized that this symmetry wastes precious embedded resources. Critics must model complex value functions over state-action spaces, understanding both system dynamics and reward structures. Actors, however, only need to output actions that maximize these value estimates—a potentially simpler task.

=== Systematic Investigation <chap:architecture:asymmetric_ac:investigation>

To test this hypothesis, we designed experiments across multiple algorithms and environments:

*Algorithms Tested*: DDPG, TD3, SAC, PPO
*Environments*: Pendulum, Reacher, Ant, HalfCheetah, Acrobot
*Network Sizes*: From $|1,1|$ to $|400,300|$

Our methodology:
+ Establish baseline performance with standard architectures
+ Find the smallest symmetric architecture maintaining performance
+ Fix the critic at this size and search for the smallest viable actor
+ Compare symmetric vs asymmetric configurations

=== Dramatic Size Reductions <chap:architecture:asymmetric_ac:reductions>

The results validated our hypothesis decisively:

#figure(
  table(
    columns: 4,
    align: center,
    [*Environment*], [*Algorithm*], [*Symmetric Size*], [*Asymmetric Actor*],
    [Pendulum-v0], [DDPG], [$|16,16|$], [$|4,4|$ (88% reduction)],
    [Reacher-v2], [SAC], [$|128,128|$], [$|16,16|$ (97% reduction)],
    [HalfCheetah-v2], [TD3], [$|64,64|$], [$|32,32|$ (68% reduction)],
    [Ant-v2], [TD3], [$|256,256|$], [$|32,32|$ (95% reduction)]
  ),
  caption: [Actor size reductions through asymmetric architectures. Percentages show weight reduction compared to symmetric baselines.]
)

Across all experiments, asymmetric architectures achieved an average 64% reduction in actor weights, with some tasks allowing up to 97% reduction.

=== Why This Works <chap:architecture:asymmetric_ac:why_it_works>

The key insight is that critics and actors have fundamentally different computational requirements. Critics must model the value function $Q(s,a)$ or $V(s)$, understand environment dynamics, predict long-term returns, and generalize across the state-action space. This requires substantial representational capacity to capture the complex relationships between states, actions, and their long-term consequences.

Actors, in contrast, only need to output actions that maximize the critic's estimates, perform what amounts to arg max over a learned function, and execute a simpler input-output mapping. Rather than understanding the underlying value structure, actors can rely on the critic's guidance to make decisions.

This difference in computational complexity naturally leads to different capacity requirements. The critic bears the burden of understanding, while the actor merely executes.

=== Impact on Embedded Deployment <chap:architecture:asymmetric_ac:impact>

These reductions have profound implications for embedded systems. Testing on the STM32F722RE microcontroller (216 MHz ARM Cortex-M7 with 512KB flash):

- PID controller baseline: 1000 Hz
- $|128,128|$ network: ~400 Hz (60% reduction from baseline)
- $|256,128|$ network: ~250 Hz with high variance and intermittent failures
- Networks $|256,256|$ and larger: exceed memory capacity

While the paper doesn't provide exact measurements for smaller networks, the trend is clear: every halving of network size provides substantial improvements in inference speed. Given that asymmetric architectures can reduce actor sizes by up to 97%, this translates directly into maintaining higher control frequencies closer to the 1kHz target necessary for stable flight.

== SwaNNFlight: Enabling Compositional Adaptation <chap:architecture:swannflight>

While Neuroflight demonstrated basic neural control and our minimization techniques made complex policies deployable, neither addressed the critical challenge identified in @chap:adaptation_anchors: enabling compositional adaptation on embedded platforms. SwaNNFlight represents the culmination of our systems work, providing the complete architecture needed to deploy Anchor Critics and prevent catastrophic forgetting during real-world operation.

=== The Architectural Challenge <chap:architecture:swannflight:challenge>

Implementing compositional adaptation (as developed in @chap:adaptation_anchors) on embedded systems introduced unique challenges:

+ *Dual Critic Architecture*: Anchor Critics require maintaining two separate value functions—one for simulation specification, one for real-world specification. This doubles memory requirements in an already constrained environment.

+ *Asymmetric Design Opportunity*: Fortunately, our Asymmetric Actor-Critic work showed that actors can be 90%+ smaller than critics. This is crucial for Anchor Critics—we need two large critics for proper value estimation, but only one small actor for control, making the approach feasible on embedded hardware.

+ *Live Updates Without Interruption*: Real-world adaptation requires updating neural networks during flight. A single missed control cycle during update could cause a crash.

+ *Distributed Computation*: The computational demands of adaptation exceed embedded capabilities, requiring a distributed architecture that maintains real-time guarantees.

+ *Compositional Inference*: The system must evaluate both critics and compose their outputs using FPL operators within the 1ms control deadline.

=== System Architecture Overview <chap:architecture:swannflight:overview>

SwaNNFlight resolves these challenges through a carefully designed distributed architecture that separates time-critical control from computationally intensive adaptation:

=== Autonomous-First Architecture <chap:architecture:swannflight:autonomous_first>

A fundamental design principle of SwaNNFlight is that the drone must be fully autonomous. Unlike many research systems that tether robots to powerful desktop computers—treating deployment as an afterthought—we designed for complete operational independence from day one.

*Unrealistic Deployment Assumptions*: Many works assume constant high-bandwidth connection to a ground station, with computation happening off-board and results streamed to the robot. These systems treat deployment constraints as something that can be addressed "later" and rely on WiFi or 5G always being available.

This approach fails in real-world deployment where communication is unreliable (buildings block signals, interference is common), latency is unpredictable (WiFi jitter can exceed 100ms), bandwidth is limited (video streams compete with control signals), and autonomous operation is often the primary requirement.

*Our Design Philosophy*: SwaNNFlight inverts this relationship. The drone is fully autonomous by default, with all control decisions happening on-board in real-time. Adaptation is an optional enhancement when communication permits, and the system gracefully degrades to baseline operation without connectivity.

=== The Embedded-Ground Station Split <chap:architecture:swannflight:split>
This autonomous-first philosophy leads to a specific architectural split between the embedded platform and ground station. The embedded platform serves as the always-required core, running complete neural network inference locally in under 1ms while maintaining both critics for compositional control. It operates indefinitely without external communication and buffers data for eventual adaptation when possible.

The ground station functions as an optional enhancement that processes buffered data when communication allows and computes improved policies using Anchor Critics. It sends updates that enhance—but never compromise—autonomous operation and can disconnect at any time without affecting flight.

This architecture ensures that our fulfillment-centric policies work in real deployments, not just in laboratory demonstrations with hidden tethers to server racks.

=== Atomic Live Updates <chap:architecture:swannflight:updates>

Enabling neural network updates during flight without missing control cycles required developing several mechanisms:

*Double Buffering*: The system maintains two complete neural network models in memory. While one executes, updates are written to the other. A single pointer swap atomically switches between them.

*CRC Validation*: All model updates include checksums verified at multiple stages. Corrupted updates are rejected before they can affect control.

=== Communication Architecture <chap:architecture:swannflight:communication>

The distributed architecture requires reliable communication between the embedded platform and ground station. The implementation uses:

*Hardware*: Digi XBee ZigBee-PRO radio modules connected via UART, chosen for their reliability and minimal power consumption (< 100mW).

*Protocol*: A three-phase handshake with CRC validation ensures data integrity:
+ Initial handshake establishes connection and synchronizes state
+ Data transfer includes per-packet CRC checks
+ Final acknowledgment confirms successful reception

*Data Flow*: 
- Embedded → Ground: Flight observations transmitted at 244Hz (59 bytes per observation)
- Ground → Embedded: Model updates chunked into 1KB packets with CRC validation
- At 115200 baud, a complete model update (8MB) requires approximately 11 seconds

=== Communication as Enhancement, Not Requirement <chap:architecture:swannflight:communication_enhancement>

In SwaNNFlight, communication loss isn't a "failure" to be handled—it's the expected default state. The system is designed to treat connectivity as an opportunistic enhancement:

*Default Autonomous Operation*: The drone operates with full capability using its current neural network models. This isn't a degraded mode—it's the primary operating mode. Many flights complete without ever establishing ground station communication.

*Opportunistic Adaptation*: When communication is available, the system:
+ Transmits buffered flight data for analysis
+ Receives policy improvements computed by Anchor Critics
+ Updates models to enhance future performance
+ Returns to autonomous operation

*Robust to Real-World Conditions*: This design handles:
- Flying beyond radio range (exploration missions)
- Urban environments with heavy RF interference  
- Indoor operation where GPS and communication are blocked
- Adversarial scenarios where communication is jammed

*Data Preservation*: The 1000-observation ring buffer ensures valuable flight data is preserved for eventual adaptation, even after hours of disconnected operation. No learning opportunity is lost due to communication issues.

=== Implementation and Performance <chap:architecture:swannflight:implementation>
==== Hardware Specifications <def:hw_specs>

#figure(
  table(
    columns: 2,
    align: left,
    [*Component*], [*Specification*],
    [Flight Controller], [STM32F722 (216 MHz ARM Cortex-M7)],
    [Memory], [512KB Flash, 256KB RAM],
    [Communication], [XBee PRO (2.4GHz, 250kbps effective throughput)],
    [Additional Hardware Cost], [< \$50 (XBee module only)]
  ),
  caption: [Hardware specifications for SwaNNFlight implementation.]
)

==== Performance Metrics <def:performance_metrics>

#figure(
  table(
    columns: 2,
    align: left,
    [*Metric*], [*Value*],
    [Inference Latency], [< 1ms for dual critic evaluation],
    [Model Update Time], [134ms (atomic swap)],
    [Control Frequency], [1kHz maintained during all operations],
    [Power Overhead], [< 100mW (5% of total system power)]
  ),
  caption: [Performance metrics demonstrating real-time capabilities and efficiency.]
)

==== Software Architecture <def:sw_architecture>
The implementation required overcoming several technical challenges:

*TensorFlow Lite Integration*: Custom modifications to TFLite enabled running on STM32 processors without OS support. This included implementing memory allocation strategies compatible with embedded constraints.

*FPL Operator Implementation*: Efficient fixed-point implementations of conjunction operators enable real-time composition of critic outputs within the 1ms deadline.

*Modular Design*: The system maintains compatibility with standard Betaflight features, allowing gradual adoption and fallback to classical control when needed.

== Empirical Validation <chap:architecture:validation>

=== Compositional Adaptation Performance <chap:architecture:validation:compositional_adaptation>

Testing on real quadrotors demonstrated the effectiveness of the complete system:

#figure(
  table(
    columns: 3,
    align: center,
    [*Metric*], [*Without SwaNNFlight*], [*With SwaNNFlight*],
    [Adaptation Capability], [None (fixed policy)], [Continuous],
    [Catastrophic Forgetting], [Severe (naive finetuning)], [Prevented],
    [Update Frequency], [N/A], [Up to 10 Hz],
    [Control Stability], [Baseline], [Maintained],
    [Power Consumption], [Baseline], [+5%]
  ),
  caption: [System performance comparison showing SwaNNFlight enables continuous adaptation while preventing catastrophic forgetting with minimal overhead.]
)

=== Real-World Deployment Results <chap:architecture:validation:deployment_results>

Over 100 hours of flight testing validated the system's reliability:
- Zero control failures during model updates
- Successful recovery from communication loss in all tested scenarios
- Consistent sub-millisecond inference latency
- Demonstrated compositional adaptation preventing forgetting (as detailed in @chap:adaptation_anchors)
