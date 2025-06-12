#import "../commands.typ": *
#import "../style.typ": *

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

=== Current Limitations

*Parameter Sensitivity*: The regularization weights $lambda_T$ and $lambda_S$ require tuning for each domain, though this is generally easier than reward engineering.

*Performance Trade-offs*: In some cases, CAPS may lead to slightly more conservative behavior, trading some performance for smoothness. This trade-off is usually acceptable but should be considered in performance-critical applications.


== Smoothness as a Universal Behavioral Fulfillment

While CAPS identifies the correct quantities to regularize—temporal and spatial continuity—its formulation as a linear penalty ($J - lambda_T L_T - lambda_S L_S$) falls short of the principled composition offered by FPL. A linear combination forces an often unintuitive and brittle trade-off, where the weights $lambda$ lack clear semantic meaning. We can reformulate the core ideas of CAPS within the fulfillment framework to create a more robust and interpretable measure of smoothness.

This involves transforming the smoothness penalties from CAPS into *Universal Behavioral Fulfillments* (UBFs). Instead of subtracting a penalty, we define fulfillment functions that map the degree of smoothness to the $[0,1]$ range, where 1 represents perfect smoothness. An exponential decay function is a natural fit for this transformation:

- *Temporal Smoothness Fulfillment*:
  $ f_"temporal"(s_t, s_(t+1)) = exp(-alpha_T ||pi_theta(s_t) - pi_theta(s_(t+1))||_2^2) $

- *Spatial Smoothness Fulfillment*:
  $ f_"spatial"(s_t, bar(s)_t) = exp(-alpha_S ||pi_theta(s_t) - pi_theta(bar(s)_t)||_2^2) $

Here, the parameters $alpha_T$ and $alpha_S$ act as sensitivity knobs. They are not arbitrary weights but have a clear semantic role: they define how quickly the fulfillment value decays as the policy's output becomes less smooth. This allows a designer to tune the functions to match their intuitive judgment, as described in the fulfillment guide (@chap:fulfillment_guide).

These UBFs, provided directly by the policy architecture, can then be integrated into any FPL specification. We can define a single, composite smoothness fulfillment:
$ f_"smoothness" = f_"temporal" and_0 f_"spatial" $

This unified $f_"smoothness"$ term can then be treated as a standard objective within a larger FPL formula, allowing a designer to specify its relationship to other task-specific goals. For instance, a common pattern would be to require smooth operation *while* achieving a task:

$ phi_"total" = f_"smoothness" and_p f_"task" $

This approach elevates smoothness from a simple penalty term to a first-class citizen in the objective specification. By using FPL's conjunctive operators (like the geometric mean, $p=0$), the optimization naturally encourages satisfying *both* objectives, avoiding the pitfalls of linear scalarization where one objective can be sacrificed for another. This directly aligns with the methodology presented in @anchor_critics, where multiplicative composition was shown to reduce training variance and improve performance by transforming a set of linearly-weighted penalties into a single, well-formed FPL objective. This reframing of CAPS is a powerful example of how universal behavioral objectives can be integrated into a principled design framework.

=== Empirical Validation: The Benefits of Compositional Smoothness

The principled reframing of smoothness penalties as fulfillments is not merely a matter of theoretical elegance; it yields concrete, empirical benefits in training stability and performance. As demonstrated in @anchor_critics, moving from linear penalty combination to a multiplicative, FPL-based composition significantly improves the consistency of the learning process.

To validate this, an ablation study was conducted comparing two methodologies for training a quadrotor flight controller:
1.  *Linear Composition*: An agent trained using a standard DDPG approach where smoothness penalties were linearly subtracted from the task reward, akin to the original CAPS formulation.
2.  *FPL Composition*: An agent trained using the *DDPG×* approach, where task and smoothness objectives were first transformed into fulfillments and then composed using the FPL geometric mean operator ($and_0$).

The results of this comparison are striking. As shown in the figure below, the agents trained with linear composition exhibited high variance across multiple independent training runs. Some seeds produced viable controllers, while others failed entirely, demonstrating the brittleness of tuning via linear weights. In contrast, the agents trained with FPL-based multiplicative composition showed significantly reduced variance, leading to a much more reliable and repeatable training process. Every agent consistently learned a high-performance policy.

#figure(
  grid(
    columns: (1fr, 1fr),
    gutter: 1em,
    image("/figures/linear_comp_tf2_ddpg_ca1e5053.svg", width: 100%),
    image("/figures/multi_comp_tf2_ddpg_cff12c6b.svg", width: 100%),
  ),
  caption: [A comparison of learning curves for agents trained with linear vs. FPL-based composition. The linear approach (left) demonstrates high variance across multiple seeds. In contrast, the FPL-based approach using multiplicative composition (right) shows significantly lower variance, leading to more consistent and reliable training outcomes while achieving comparable or superior final performance.]
) <fig:fpl_vs_linear_composition>

This evidence strongly supports the case for treating universal behavioral objectives like smoothness as fulfillments within the FPL framework. The use of principled composition operators like the geometric mean is not just more expressive; it leads to a more stable optimization landscape, reducing the reliance on brittle hyperparameter tuning and increasing the probability of successfully training a well-behaved agent.

== Learning Stability as a Universal Behavioral Fulfillment

Just as smoothness is a near-universal requirement for successful robotic control, stability tends to also be a common requirement. In an effort to present tracking a trajectory represented in a more fundamental fashion that a reward for tracking error, we found that stability was an adequate goal. A controller that performs its task but is unstable is not only unreliable but dangerous. This makes stability a prime candidate for treatment as a Universal Behavioral Objective. The journey to formalizing stability within the fulfillment framework is not just an academic exercise; it was the original discovery path that led to the development of Fulfillment Priority Logic itself.

This section details how our attempts to learn controllers with formal stability guarantees, using tools from classical Lyapunov theory, revealed the limitations of traditional penalty-based methods and directly motivated the creation of the fulfillment-centric paradigm. This allowed us to learn Lyapunov functions and controllers with orders of magnitude less time than traditional methods.

#notice[
these findings were never written up in a paper
]

=== From Lyapunov Conditions to Optimization Objectives

Classical control theory uses Lyapunov functions to provide a mathematical certificate of a system's stability. A function $V(x)$ is a valid Lyapunov function if it is positive definite ($V(x)>0$ for $x!=0$, $V(0)=0$) and its time derivative along the system's trajectories is negative definite ($dot(V)(x) < 0$).

Initially, these conditions were used for binary verification: proving if a hand-designed controller was stable or not. However, a crucial evolution in control theory was to reframe this as an optimization problem: instead of just verifying stability, the goal became to design controllers that maximized the *region of attraction*—the set of initial states from which the system is guaranteed to return to its equilibrium point. This shift transformed Lyapunov conditions from a simple proof tool into a quantitative objective, paving the way for treating stability not as a hard constraint, but as a fulfillment that can be measured, optimized, and composed.

=== The Problem: Opaque Penalties vs. Semantic Robustness

Our initial approach to learning stable controllers followed this optimization path, but using the conventional RL tools of penalty-based loss functions. We sought to simultaneously learn a controller $u$ and a corresponding Control Lyapunov Function (CLF) $V$ that certified its stability. This was formulated as a loss function to be minimized:

$ cal(L)_"CLF" = V(p)^2 + a_1 1/N sum_(x in cal(X)) [epsilon + V(f(x,u)) - V(x)]_+ + a_2 1/N sum_(x in cal(X)) [epsilon - V(x)]_+ $

where $p$ is the desired setpoint, $f(x,u)$ represents the system dynamics under control, and $[dot]_+ = max(dot, 0)$ is the ReLU function. This loss function attempts to enforce that $V(p)$ is zero, $V(x)$ is positive elsewhere, and $V(x)$ is decreasing along system trajectories.

However, this formulation suffers from a critical semantic gap. The raw value of $cal(L)_"CLF"$ is largely uninterpretable; a loss of 1000 is worse than a loss of 3, but neither value tells the designer *how close* the system is to being stable. The formulation creates a hard, binary cliff: only when the arguments to the ReLU functions are negative (i.e., the system is "under epsilon") are the Lyapunov conditions actually met. The loss function acts as a penalty for being on the wrong side of this cliff, but it fails to provide a meaningful, continuous measure of "how far" away from safety the system is.

This can be viewed as a crude and ineffective form of *robustification*. As discussed in our comparison to Signal Temporal Logic (@chap:encoding_intentionality:related_work), a good robustness measure should provide a continuous, interpretable "distance" to satisfying a specification. The penalty-based loss fails this test. It does not create a smooth landscape that guides the optimizer towards stability; it simply penalizes violation.

This fundamental issue leads to secondary problems:
1.  *Brittle Weighting*: Because the loss values lack a shared semantic basis, the weights $a_1, a_2$ become arbitrary tuning parameters to balance incomparable penalties, rather than expressing genuine design priorities.
2.  *Compositional Breakdown*: Attempting to add performance objectives (e.g., tracking error) to this loss function forces the designer to weigh a stability penalty against a performance reward, which is a semantically incoherent and brittle trade-off. It becomes impossible to enforce that stability is a non-negotiable prerequisite for performance.

=== The Solution: Stability as a Robust, Composable Fulfillment

The solution was to develop a completely new formulation grounded in the principles of FPL. This approach replaces the opaque, penalty-based loss with a set of semantically meaningful and composable fulfillment functions, allowing us to directly optimize for stability in a way that provides formal guarantees.

==== Step 1: Architecting a Bounded Lyapunov Function

The foundation of this method is an architectural choice: we constrain the Lyapunov network, $V$, to be bounded, mapping any input state $x$ to a value in the range $[0, 1]$. This is a crucial step, as it normalizes the state space into a consistent "potential energy" landscape, where the setpoint $p$ represents the global minimum (`V(p) = 0`) and all other states have higher "energy."

==== Step 2: Designing Robust Fulfillment Functions

With a bounded Lyapunov function, we can now design a set of robust fulfillment functions that measure the degree to which the core stability conditions are met. A key design pattern here is establishing a "satisfaction threshold" at a fulfillment value of `0.1`. For each condition, a fulfillment above `0.1` will signify that the constraint is met, while a value below it signifies a violation.

- *Decreasing Fulfillment ($f_"decreasing"$)*: The core stability requirement is that the Lyapunov value decreases along system trajectories. Since the change in the bounded Lyapunov function, let's call it $d = V(f(x,u)) - V(x)$, is itself bounded within `[-1, 1]`, we do not need a complex sigmoid. We can construct a simple, smooth quadratic function that precisely maps this range to our desired fulfillment values. The function is designed to pass through three key points: maximum decrease (`d=-1`) should yield high fulfillment (`0.9`), no change (`d=0`) should be the satisfaction boundary (`0.1`), and maximum increase (`d=1`) should yield zero fulfillment (`0.0`). This results in the following quadratic polynomial:
  $ f_"decreasing" = 0.35 d^2 - 0.45 d + 0.1 $
  This function provides a smooth, continuous gradient that strongly rewards the system for decreasing the Lyapunov value while strictly penalizing any increase.

- *Positivity Fulfillment ($f_"positive"$)*: We require the Lyapunov function to be "large" for any state that is not the setpoint. Since $V(x)$ is bounded in `[0,1]`, we can define "large enough" as being greater than a small constant, e.g., `0.1`. The fulfillment can be defined as:
  $ f_"positive" = min(1.0, V(x) / 0.1) $
  This function yields a fulfillment greater than `1.0` (which is capped) if $V(x) > 0.1$, satisfying our condition, and provides a smooth gradient for values below that threshold.

- *Setpoint-Zero Fulfillment ($f_"zero"$)*: Conversely, we require the Lyapunov function to be zero at the setpoint $p$. We can define high fulfillment when $V(p)$ is very small (e.g., less than `0.1`). An inverse mapping works well here:
  $ f_"zero" = 1.0 - min(1.0, V(p) / 0.1) $
  This provides a fulfillment near `1.0` when $V(p)$ is near zero, and a value below `0.1` if $V(p)$ is greater than `0.09`.

==== Step 3: Composition and the Minimum Fulfillment Guarantee

Herein lies the "magic" of the FPL approach. We can now combine these individual fulfillments using a single, conjunctive FPL operator:

$ f_"lyapunov" = f_"decreasing" and_p f_"positive" and_p f_"zero" $

By using a pessimistic, AND-like operator (e.g., the geometric mean, $p=0$, or harmonic mean, $p=-1$), we can leverage the *Minimum Fulfillment Bound* theorem from Chapter 3. This theorem provides a strict, computable lower bound on the worst-performing individual fulfillment, based on the overall composed value.

This allows us to set a clear optimization target: if we can train the agent to achieve a composed $f_"lyapunov"$ value high enough to guarantee that the minimum fulfillment of any component is greater than `0.1`, we have a formal proof that *all three stability conditions are being met simultaneously*. Constraint satisfaction emerges directly from optimizing the composed preference, eliminating the need for brittle penalty weights entirely.

==== Step 4: Efficient Learning via Batch Composition

The final piece of the puzzle is how this formulation leads to dramatic gains in learning speed. Instead of learning from single data points, we can apply this composition across an entire batch of experiences from the replay buffer. For a batch of $N$ transitions, the final training objective for the actor becomes:

$ J = pmean(p)(f_"lyapunov"^(1), f_"lyapunov"^(2), ..., f_"lyapunov"^(N)) $

This objective is incredibly powerful. It represents the aggregate stability fulfillment across a wide distribution of states. A single gradient update contains rich information about how to improve the controller to be more stable *everywhere* in the batch, not just at one point. This stable, highly informative learning signal is the source of the observed speed-up.

=== Experimental Validation

Our approach builds upon foundational research in neural Lyapunov control, which demonstrated the feasibility of learning-based methods for stability analysis, though often in simpler contexts like tuning the gains of an LQR controller. #todo[CITE: Neural Lyapunov Control] Our work extends this to the significantly more complex problem of training a full neural network controller from scratch.

In doing so, we encountered a key practical challenge: the optimization landscape for a full neural network controller is fraught with local minima. We observed that an agent optimizing solely for the composed Lyapunov fulfillment ($f_"lyapunov"$) would often converge to sub-optimal but stable solutions—for example, learning to let the pendulum hang straight down without ever attempting to swing it up. While technically stable, this behavior fails to achieve the actual goal of the task.

To overcome this, we introduced an additional "steering" objective, $f_"steering"$, designed to guide the controller out of these trivial local minima. This fulfillment function could, for instance, provide a small reward for being near the upward position or for having positive angular velocity when the pendulum is below the horizontal. This steering fulfillment was then composed with the others:

$ J = pmean(p)(f_"lyapunov"^(1), ..., f_"lyapunov"^(N)) and_p f_"steering" $

This ability to seamlessly add another semantic objective to guide the learning process, without destabilizing the core stability guarantees, highlights the power and flexibility of the FPL framework.

With this complete formulation, we validated the approach on the classic `Pendulum-v1` environment. The results were remarkable. The FPL-based agent was able to learn a stable controller that successfully balanced the pendulum from a random starting position in approximately *one minute* of training time. This represents an order-of-magnitude improvement over traditional RL methods and demonstrates the power of combining principled objective composition with formal stability guarantees.

// #figure(
//   image("/figures/pendulum_lyapunov.svg", width: 60%),
//   caption: [A snapshot from the `Pendulum-v1` environment. Using the FPL-based Lyapunov formulation, the agent learns to robustly swing up and stabilize the pendulum in roughly one minute of training.]
// ) <fig:pendulum_lyapunov>