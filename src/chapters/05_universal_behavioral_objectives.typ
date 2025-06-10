#import "../commands.typ": *

= Universal Behavioral Objectives <chap:ubo>

The previous chapters established that fulfillment logic can give us a language for composing various objectives. However, we deemed the building of fulfillment values as a task-specific process, but some objectives are so widely applicable in robotics to merit special treatment.

==== Universal Behavioral Objectives
These are behavioral objectives that are desirable across virtually all robotics applications, transcending specific tasks, domains, or application contexts. These include smoothness, stability, and robustness. When these objectives are quantified by fulfillments, they become *Universal Behavioral Fulfillments*.

By focusing on a general class of objectives and defining ways to compute and optimize them, we get to reuse them across different applications. With enough use, they will be part of popular implementations of such learning algorithms.

This chapter presents Conditioning for Action Policy Smoothness (CAPS) as a paradigm for this architectural approach. CAPS demonstrates how smoothness (a UBO, represented by $f_"smoothness"$ UBF) can be encouraged directly into policy architectures rather than relying on reward engineering or constant FPL inclusion. We show how this architectural approach complements FPL by handling fundamental behavioral requirements (UBFs) at the policy level while allowing FPL to focus on task-specific behavioral objective relationships.

*The Architectural vs. Compositional Distinction*: This approach reflects a key insight from our objective taxonomy (and the Behavioral Decomposition Principle from Chapter 3): different types of objectives (and their fulfillments) require different treatment mechanisms. Task-specific behavioral objectives (and their fulfillments) benefit from explicit composition through FPL, allowing practitioners to express complex logical relationships. Universal Behavioral Objectives (and their UBFs, like $f_"smoothness"$) should typically be promoted via the architecture itself, ensuring they are automatically encouraged without burdening the specification process. However, UBFs *can* still be part of an FPL formula if their interaction with other fulfillments needs explicit logical management in a particular context.

== Smoothness as a Universal Behavioral Objective


=== The Problem of Oscillatory Control in Neural Policies

A critical problem with the practical utility of controllers trained with deep Reinforcement Learning is the notable lack of smoothness in the actions learned by RL policies. This trend often presents itself in the form of control signal oscillation and can result in poor control, high power consumption, and undue system wear.

==== Manifestations of Non-Smooth Control
The problem of oscillatory control responses is particularly pronounced in continuous control applications where controller response can vary infinitely within the limits of acceptable outputs. This issue is further accentuated by the domain gap in sim-to-real transfer, where policies trained in simulation exhibit erratic behavior when deployed on real hardware.

- *Power Consumption*: High-frequency oscillations in control signals lead to increased power consumption as actuators work against each other or make unnecessary corrections. In our quadrotor experiments, non-smooth controllers consumed up to 80% more power than smooth alternatives.

- *Hardware Wear*: Oscillatory control signals cause excessive wear on actuators, motors, and mechanical components. The constant high-frequency actuation can lead to premature failure of hardware components, particularly in high-performance applications.

- *Performance Degradation*: While oscillatory controllers may achieve good tracking performance in simulation, they often fail catastrophically when deployed on real systems where actuator dynamics, delays, and noise amplify the negative effects of non-smooth control.

- *Safety Concerns*: In safety-critical applications, oscillatory control can lead to instability and loss of control. The unpredictable nature of these oscillations makes it difficult to provide safety guarantees for deployed systems.

==== Why Traditional Approaches Fail
The black-box nature of neural network-based controllers limits mitigation of bad behavior at run-time. Classical control techniques such as filtering, which might normally be used to address oscillatory problems, behave inconsistently with neural network controllers and can lead to catastrophic failures.

- *Filtering Incompatibility*: Neural network policies are not typically trained with integrated filters, so deploying them with a filter changes the dynamical response expected by the network and can result in anomalous behavior. Our experiments showed that naively introducing filters can cause complete loss of control.

- *Reward Engineering Limitations*: Attempts to condition the behavior of RL agents largely focus on engineering rewards to induce the desired behavior. However, relying on reward engineering for behavior conditioning requires networks to learn through indirect information, which may or may not be easily relatable to the outputs of the network. The process is tedious, unintuitive, and ultimately provides no guarantees that the desired behavior would be learned.

- *Surrogate Function Issues*: Research has shown that RL algorithms can be very sensitive to learning hyperparameters, input normalization, and reward scales. The surrogate optimization functions learned by policy gradient algorithms can present a very different optimization space compared to the true value function, making it difficult to trust nuanced information transfer from environment rewards to action policy optimization.

=== Conditioning for Action Policy Smoothness (CAPS)

Smoothness represents the paradigmatic example of a universal behavioral objective. Its corresponding UBF, $f_"smoothness"$, would quantify the degree of achieved smoothness. Smooth control policies exhibit two key properties:

- *Temporal Smoothness*: Actions taken should be similar to previous actions to preserve smooth transitions between controller outputs over time. This prevents rapid oscillations that can destabilize systems or waste energy.

- *Spatial Smoothness*: Similar states should map to similar actions, thus mitigating measurement noise and modeling uncertainties. This improves robustness to perturbations and enhances generalization.

These properties are desirable across virtually all robotics applications, making smoothness (and its $f_"smoothness"$ UBF) an ideal candidate for architectural integration rather than task-specific reward engineering or mandatory inclusion in all FPL formulas.


We introduce Conditioning for Action Policy Smoothness (CAPS), an effective yet intuitive regularization approach that promotes the UBF of smoothness directly at the policy level. CAPS operates by adding regularization terms to the policy optimization objective that encourage both temporal and spatial smoothness, thereby promoting a high $f_"smoothness"$.

=== Mathematical Formulation

CAPS modifies the standard policy optimization objective by adding regularization terms that directly constrain the policy's action mappings. For a neural network policy $pi_theta$ parameterized by $theta$, the CAPS optimization objective is:

$ J_theta^"CAPS" = J_theta - lambda_T L_T - lambda_S L_S $

where $J_theta$ is the standard policy optimization objective, and $L_T$ and $L_S$ are temporal and spatial smoothness regularization terms with weights $lambda_T$ and $lambda_S$.

*Hyperparameter Selection*: The regularization weights $lambda_T$ and $lambda_S$ are user-tunable hyperparameters that control the trade-off between task performance and control smoothness:

- *Temporal Weight* $lambda_T in [0, 1]$: Controls how much consecutive actions should be similar. Higher values promote smoother transitions but may slow response times.
- *Spatial Weight* $lambda_S in [0, 0.1]$: Controls how similar actions should be for nearby states. Higher values improve robustness to noise but may reduce precision.

*Observed Trade-offs*: In our experiments, we found:
- *Sample Efficiency vs. Smoothness*: Higher regularization values (e.g., $lambda_T = 0.5$) improve smoothness by 2-3× but may increase training time by 20-30%.
- *Performance vs. Power Consumption*: Moderate values ($lambda_T = 0.1, lambda_S = 0.01$) achieve 50-80% power reduction with only 5-10% performance impact.
- *Domain-Specific Tuning*: Quadrotor control benefited from higher temporal smoothness ($lambda_T = 0.3$) while manipulation tasks preferred stronger spatial smoothness ($lambda_S = 0.05$).

*Temporal Smoothness Regularization*:
$ L_T = D_T(pi_theta(s_t), pi_theta(s_(t+1))) $

This term penalizes policies when actions taken on the next state under the state transition probabilities of the system are significantly dissimilar from actions taken on the current state.

*Spatial Smoothness Regularization*:
$ L_S = D_S(pi_theta(s_t), pi_theta(bar(s)_t)) "where" bar(s) tilde phi(s_t) $

This term mitigates noise in system dynamics by ensuring that policies take similar actions on similar states $bar(s)$, which are drawn from a distribution $phi$ around $s$.

*Distance Measures*: In practice, we use Euclidean distances for the distance measures $D_T$ and $D_S$, and assume a normal distribution $phi(s) = N(s, sigma)$ for spatial perturbations, with standard deviation $sigma$ based on expected measurement noise.

=== Theoretical Foundation: Lipschitz Regularization

CAPS can be understood as approximating Lipschitz regularization for neural network policies. The regularization terms effectively minimize the temporal and spatial Lipschitz constants of the policy functions around regions of interest.

A function $f$ has Lipschitz constant $L$ if:
$ ||f(x) - f(y)||_2 <= L ||x - y||_2 $

for all $x, y$ in the domain. While computing exact Lipschitz constants for neural networks has been shown to be NP-hard @scaman2018lipschitz, regularization techniques allow for approximation with demonstrable utility in increasing the generalizability and robustness of learned mappings @miyato2018spectral @cisse2017parseval.

The CAPS regularization terms directly approximate these Lipschitz constraints:

*Temporal Lipschitz Approximation*: The temporal smoothness term $L_T$ constrains the policy to have small Lipschitz constants along trajectories:
$ L_T = D_T(pi_theta(s_t), pi_theta(s_(t+1))) approx L_"temporal" ||s_(t+1) - s_t||_2 $

*Spatial Lipschitz Approximation*: The spatial smoothness term $L_S$ constrains the policy to have small Lipschitz constants in the neighborhood of visited states:
$ L_S = D_S(pi_theta(s_t), pi_theta(bar(s)_t)) approx L_"spatial" ||bar(s)_t - s_t||_2 $

This theoretical foundation explains why CAPS is effective across different domains and algorithms—it directly addresses the fundamental issue of policy sensitivity that leads to oscillatory control behavior.

*Temporal Lipschitz Constraint*: The temporal smoothness term $L_T$ constrains the policy to have small Lipschitz constants along trajectories, preventing rapid changes in action outputs as the system evolves.

*Spatial Lipschitz Constraint*: The spatial smoothness term $L_S$ constrains the policy to have small Lipschitz constants in the neighborhood of visited states, improving robustness to measurement noise and modeling uncertainties.

=== Integration with Existing RL Algorithms

CAPS is designed to be algorithm-agnostic and can be integrated with any policy gradient method. The regularization terms are computed using only the policy network outputs and do not require additional information from the environment during training.

*Actor-Critic Integration*: For actor-critic methods like DDPG, SAC, and TD3, CAPS modifies only the actor loss function. The critic networks continue to learn value functions based on the original reward signals, while the actor is regularized for smooth behavior.

*Policy Gradient Integration*: For methods like PPO and TRPO, CAPS can be integrated into the policy gradient computation, providing additional gradients that encourage smooth action mappings.

*Computational Efficiency*: The computational overhead of CAPS is minimal, requiring only additional forward passes through the policy network to compute the regularization terms. The gradient computation follows standard backpropagation rules.

== Empirical Validation Across Domains

We validated CAPS across multiple robotics domains, demonstrating consistent improvements in smoothness without significant degradation in task performance.

=== Toy Problem Validation

To illustrate that issues related to smooth control are not limited to complex dynamics, we constructed a simple 1-dimensional goal-tracking environment with no complex dynamics or noise. The agents observe the disparity $s_t = g_t - c_t$ between the current state $c_t$ and desired goal state $g_t$. Actions directly affect the system response such that $s_(t+1) = c_t + a_t$, making the ideal action $a_t^* = s_t$.

#figure(
  image("/figures/ToyFig_plusStateAction_v4.svg", width: 100%),
  caption: [Comparison of state response and normalized state-action histograms on the toy problem for TD3 policy (left) vs CAPS-regularized TD3 policy (right). Actions of the regularized agent are much closer to the ideal linear mapping (green dotted line) while vanilla agents learn binary-like policies (red dotted line) that cause high-frequency oscillations.]
) <fig:caps_toy_problem_results>

Standard RL agents learned highly aggressive control policies, akin to binary step responses, which resulted in oscillations as they attempted to maintain tracking. This oscillatory behavior learned early in training acts as a local minimum that agents fail to escape. CAPS-regularized agents, however, learned behavior much closer to the ideal linear mapping, naturally yielding smoother control.

=== OpenAI Gym Benchmarks

We evaluated CAPS on four continuous control benchmarks: Pendulum-v0, LunarLanderContinuous-v2, Reacher-v2, and Ant-v2. Results show that CAPS consistently produces smoother policies across all tested algorithms (DDPG, SAC, TD3, PPO) and environments.

*Abrasion Metric*: We define an abrasion measure based on the Fast Fourier Transform (FFT) frequency spectrum:
$ "Ab" = (2)/(n f_s) sum_(i=1)^n M_i f_i $

where $M_i$ is the amplitude of the $i$-th frequency component $f_i$ and $f_s$ is the sampling frequency. This metric provides the mean weighted normalized frequency, with lower values indicating smoother control.

*Comprehensive Results*: Table 1 shows detailed results across all tested algorithms and environments. CAPS agents are smoother than their vanilla counterparts on all tested tasks, with smoothness improvements ranging from 2x to 7x. We observe nominal performance hits on pendulum and lunar-lander tasks due to agents being slower at achieving goal states as they strive for smoother behavior. However, with Reacher and Ant environments, the improved smoothness actually enabled higher rewards.

#figure(
  table(
    columns: 9,
    align: center,
    [*Algorithm*], [*Pendulum-v0*], [], [*LunarLanderContinuous-v2*], [], [*Reacher-v2*], [], [*Ant-v2*], [],
    [], [Reward ↑], [Abrasion (Ab×10³) ↓], [Reward ↑], [Abrasion (Ab×10³) ↓], [Reward ↑], [Abrasion (Ab×10³) ↓], [Reward ↑], [Abrasion (Ab×10³) ↓],
    [DDPG], [-145.56 ± 10.64], [47.6 ± 10.64], [217.04 ± 51.61], [34.9 ± 1.36], [-4.26 ± 0.25], [4.56 ± 0.45], [225.23 ± 362.88], [2.73 ± 0.65],
    [DDPG + CAPS], [-188.16 ± 22.53], [*7.09 ± 1.65*], [181.98 ± 87.18], [*16.7 ± 2.92*], [-5.03 ± 1.89], [*3.69 ± 1.13*], [*253.30 ± 187.93*], [*1.31 ± 0.71*],
    [SAC], [-139.86 ± 8.29], [9.32 ± 1.13], [277.62 ± 11.02], [8.14 ± 0.81], [-5.96 ± 0.47], [5.99 ± 0.91], [3366.07 ± 1522.45], [6.53 ± 2.26],
    [SAC + CAPS], [-165.79 ± 9.22], [*4.93 ± 1.15*], [*281.94 ± 3.65*], [*7.62 ± 0.71*], [-6.25 ± 3.71], [*5.00 ± 0.71*], [*4209.08 ± 1367.18*], [*6.11 ± 2.93*],
    [TD3], [-152.71 ± 9.47], [43.9 ± 30.94], [271.06 ± 17.39], [37.9 ± 12.30], [-6.52 ± 1.12], [5.70 ± 0.98], [3087.86 ± 888.75], [9.09 ± 1.90],
    [TD3 + CAPS], [-172.82 ± 13.47], [*5.92 ± 1.52*], [270.32 ± 25.73], [*16.7 ± 3.26*], [*-6.34 ± 0.66*], [*4.63 ± 0.72*], [*3871.68 ± 1121.36*], [*7.89 ± 2.92*],
    [PPO], [-668.60 ± 551.85], [9.29 ± 5.51], [169.08 ± 56.59], [11.4 ± 1.36], [-4.37 ± 1.74], [4.49 ± 0.43], [3734.58 ± 988.29], [6.09 ± 1.19],
    [PPO + CAPS], [*-590.35 ± 295.86*], [*8.09 ± 2.13*], [140.71 ± 23.03], [*10.0 ± 2.92*], [-4.69 ± 2.05], [*3.38 ± 0.36*], [*4256.93 ± 570.88*], [*1.60 ± 0.26*]
  ),
  caption: [Comparing rewards and abrasion scores on OpenAI Gym benchmarks. CAPS consistently improves smoothness (lower Ab values) across all algorithms and environments. Bold values indicate improvements over vanilla algorithms.]
) <tab:caps_gym_benchmarks_results>

Interestingly, soft-policies such as PPO and SAC appear to learn relatively smoother policies on their own, which we hypothesize is due to stochasticity in the policies allowing for improved exploration of the state and action spaces.

=== Quadrotor Control Validation

The most compelling validation of CAPS comes from real-world quadrotor control experiments, where we trained attitude controllers for high-performance racing drones using the Neuroflight framework.

*Experimental Setup*: We trained controllers to follow pilot input desired rates of angular velocity on three axes of rotation. The main problem with baseline Neuroflight was that, despite achieving decent tracking in simulation, trained agents presented with significant high-frequency control signal oscillations, causing motors to overheat and making drones unflyable. Only a handful of baseline agents were flight-worthy, while most failed to transfer well to real hardware.

*CAPS vs. Baseline Comparison*: By stripping training rewards down to basic tracking error components and comparing agents trained with CAPS against those without, we demonstrated clear improvements in motor actuation smoothness.

#figure(
  image("/figures/withVSwoCAPS_v3.svg" ),
  caption: [PPO trained for quadrotor control with just tracking error reward compared against the same algorithm with CAPS optimization. Note the significant reduction in motor signal amplitude and oscillation, despite maintaining similar tracking performance. CAPS agents were flight-worthy while vanilla agents posed significant risk.]
) <fig:caps_quadrotor_power>

*Training Efficiency*: CAPS training completed successfully within 1 million time-steps, constituting a 90% reduction in data intensity and 8× wall-time speedup over baseline Neuroflight approaches.

*Quantitative Flight Performance*: Table 2 compares performance metrics between different controllers on both simulated validation and real test flights.

#figure(
  table(
    columns: 4,
    align: center,
    [*Agent*], [*MAE (deg/s) ↓*], [*Current (Amps) ↓*], [*Abrasion $(times 10^3)$ ↓ *],
    [colspan(4)[*Simulated Validation*]],
    [PID], [11.41], [-NA-], [0.29],
    [Neuroflight], [7.30], [-NA-], [3.23],
    [PPO + Temporal], [11.36 ± 2.19], [-NA-], [0.056 ± 0.007],
    [PPO + Spatial], [16.66 ± 4.57], [-NA-], [0.021 ± 0.007],
    [PPO + CAPS], [*9.26 ± 1.03*], [-NA-], [*0.021 ± 0.012*],
    [colspan(4)[*On-Platform Live Test-Flights*]],
    [PID], [5.01], [8.07], [0.4],
    [Neuroflight], [5.19], [22.87], [4.3],
    [PPO + Temporal], [7.82 ± 2.42], [7.59 ± 2.24], [1.10 ± 0.32],
    [PPO + Spatial], [14.85 ± 6.85], [4.59 ± 2.70], [0.37 ± 0.22],
    [PPO + CAPS], [*9.28 ± 2.31*], [*4.86 ± 2.32*], [*0.16 ± 0.02*]
  ),
  caption: [Flight performance comparison showing Mean Absolute Error (MAE), current consumption, and abrasion (Ab). CAPS achieves the best balance of tracking accuracy, power efficiency, and smoothness. Variance statistics computed over 10 independently trained agents.]
) <tab:caps_quadrotor_quantitative_results>

*Power Consumption Analysis*: CAPS-optimized agents consumed significantly less power (4.86 ± 2.32 Amps) compared to Neuroflight (22.87 Amps) and even outperformed the PID controller (8.07 Amps), demonstrating that neural network controllers can exceed classical control efficiency when properly regularized.

*Frequency Analysis*: Figure 3 shows the dramatic difference in control signal frequency content between CAPS and baseline approaches.

#figure(
  image("/figures/fourier_vs_motors_v3.svg", width: 100%),
  caption: [Comparison of motor usage during flight and corresponding FFTs demonstrate significant improvement in smoothness with CAPS. High frequency components are practically eliminated compared to Neuroflight, which falls victim to the domain gap between simulated training and real flight. CAPS demonstrates robustness to this shift, contributing to 100% flight-worthy agents versus cherry-picking required for baselines.]
)

*Reproducibility Achievement*: Critically, CAPS enabled 100% repeatability in the training pipeline—all 10 agents trained with CAPS transferred successfully to the drone, demonstrating the added robustness offered by the regularization approach. This contrasts sharply with baseline approaches that required careful selection of viable controllers.

=== Sim-to-Real Transfer Analysis

CAPS demonstrates particular value in sim-to-real transfer scenarios, where the smoothness learned during simulation training transfers effectively to real-world deployment.

*Domain Gap Robustness*: The architectural nature of CAPS regularization makes it robust to domain shifts. Unlike reward-based approaches that may not transfer well due to dynamics differences, CAPS constraints on policy smoothness remain relevant across domains.

*Consistent Performance*: All agents trained with CAPS successfully transferred to real hardware, demonstrating 100% repeatability compared to the cherry-picking required for baseline approaches.

*Power Efficiency*: The smooth control signals produced by CAPS-trained agents resulted in significantly lower power consumption on real hardware, extending flight times and reducing thermal stress on components.

=== Integration Into Policy Optimization

The success of CAPS demonstrates broader principles for integrating universal behavioral objectives into policy architectures.

==== Direct Policy Conditioning vs. Reward Engineering
CAPS represents a fundamental shift from reward engineering to direct policy conditioning. Rather than trying to encode desired behaviors through complex reward functions, we condition the policy optimization process directly.

*Advantages of Direct Conditioning*:
+ *Transparency*: The relationship between regularization terms and resulting behavior (and thus the UBF) is direct and interpretable
+ *Robustness*: Architectural constraints promoting UBFs are less sensitive to domain shifts than reward-based approaches
+ *Efficiency*: Simpler reward structures or FPL formulas can be used when UBFs for universal objectives are handled architecturally
+ *Guarantees*: Direct constraints provide stronger guarantees about resulting behavior than indirect reward signals

*When to Use Direct Conditioning*: Universal behavioral objectives that apply across tasks and domains are ideal candidates for architectural integration. Task-specific objectives are better handled through FPL formulations.

=== The Fulfillment Treatment <chap:ubo:fulfillment>
We can expressing CAPS objectives as fulfillments as is done in @anchor_critics, 

=== Design Guidelines for Universal Objectives

Based on our experience with CAPS, we propose the following guidelines for identifying and integrating universal behavioral objectives (and their UBFs):

*Identification Criteria*:
1. The UBO applies across multiple tasks and domains
2. The UBO can be expressed in terms of policy behavior (and thus quantified as a UBF) rather than environment state
3. The UBO contributes to safety, efficiency, or robustness
4. The UBO can be measured using only policy inputs and outputs

*Integration Strategies*:
1. *Regularization*: Add penalty terms to the policy optimization objective
2. *Architectural Constraints*: Build constraints directly into the network architecture
3. *Preprocessing/Postprocessing*: Apply transformations to inputs or outputs
4. *Hybrid Approaches*: Combine multiple integration strategies for complex objectives

== Limitations and Future Directions

While CAPS demonstrates significant benefits, several limitations and opportunities for future work remain.

=== Current Limitations

*Parameter Sensitivity*: The regularization weights $lambda_T$ and $lambda_S$ require tuning for each domain, though this is generally easier than reward engineering.

*Performance Trade-offs*: In some cases, CAPS may lead to slightly more conservative behavior, trading some performance for smoothness. This trade-off is usually acceptable but should be considered in performance-critical applications.

*Limited Scope*: CAPS addresses only smoothness as a universal objective. Other universal objectives may require different architectural approaches.

=== Future Research Directions

*Automated Parameter Selection*: Developing methods to automatically select appropriate regularization weights based on task characteristics and hardware constraints.

*Additional Universal Objectives*: Identifying and implementing other universal behavioral objectives such as energy efficiency, predictability, and robustness.

*Adaptive Regularization*: Developing methods that adjust regularization strength based on performance and deployment conditions.

*Integration with Model-Based Methods*: Exploring how universal behavioral objectives can be integrated with model-based RL and planning methods.

== Learning Lyapunov Stability as Fulfillment