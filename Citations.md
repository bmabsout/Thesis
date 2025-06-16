### Citations from `AsymmetricAC/main.tex`

#### Core RL Concepts

*   `Qlearning`: Watkins, Christopher JCH and Dayan, Peter. "Q-learning." Machine learning 8.3-4 (1992): 279-292.
    *   **Context**: Foundational value-based RL approach. Mentioned as an example of a value-based RL approach that actor-critic methods draw from for sample efficiency.

*   `sutton2000policy`: Sutton, Richard S., et al. "Policy gradient methods for reinforcement learning with function approximation." Advances in neural information processing systems. 2000.
    *   **Context**: Foundational policy-based approach. Mentioned as a policy-based approach that actor-critic methods use, which enables learning on continuous action domains.

#### Actor-Critic Algorithms

*   `A2C`: Mnih, Volodymyr, et al. "Asynchronous methods for deep reinforcement learning." International conference on machine learning. PMLR, 2016.
    *   **Context**: A prominent actor-critic algorithm. The paper itself is about A3C, but A2C is a synchronous version.
*   `A3C`: Shen, Han, et al. "Asynchronous Advantage Actor Critic: Non-asymptotic Analysis and Linear Speedup." arXiv preprint arXiv:2012.15511 (2020).
    *   **Context**: A prominent actor-critic algorithm.
*   `PPO`: Schulman, John, et al. "Proximal policy optimization algorithms." arXiv preprint arXiv:1707.06347 (2017).
    *   **Context**: A prominent actor-critic algorithm.
*   `TRPO`: Schulman, John, et al. "Trust region policy optimization." International conference on machine learning. PMLR, 2015.
    *   **Context**: A prominent actor-critic algorithm.
*   `DDPG`: Lillicrap, Timothy P., et al. "Continuous control with deep reinforcement learning." arXiv preprint arXiv:1509.02971 (2015).
    *   **Context**: A prominent actor-critic algorithm.
*   `TD3`: Fujimoto, Scott, Herke van Hoof, and David Meger. "Addressing function approximation error in actor-critic methods." International conference on machine learning. PMLR, 2018.
    *   **Context**: A prominent actor-critic algorithm.
*   `SAC`: Haarnoja, Tuomas, et al. "Soft actor-critic: Off-policy maximum entropy deep reinforcement learning with a stochastic actor." International conference on machine learning. PMLR, 2018.
    *   **Context**: A prominent actor-critic algorithm.

#### RL Benchmarks and Reproducibility

*   `baselines`: Dhariwal, Prafulla, et al. "Openai baselines." GitHub repository (2017).
    *   **Context**: A common RL baseline library where actor-critic architectures are often symmetric.
*   `stable-baselines`: Hill, Ashley, et al. "Stable baselines." GitHub repository (2018).
    *   **Context**: A common RL baseline library where actor-critic architectures are often symmetric.
*   `stable-baselines3`: Raffin, Antonin, et al. "Stable baselines3." GitHub repository (2019).
    *   **Context**: A common RL baseline library where actor-critic architectures are often symmetric.
*   `GYM`: Brockman, Greg, et al. "Openai gym." arXiv preprint arXiv:1606.01540 (2016).
    *   **Context**: A common RL benchmark environment.
*   `TFAgents`: Guadarrama, Sergio, et al. "{TF-Agents}: A library for Reinforcement Learning in TensorFlow." (2018).
    *   **Context**: A common RL baseline library where actor-critic architectures are often symmetric.
*   `SpinningUp2018`: Achiam, Joshua. "Spinning up in deep reinforcement learning." (2018).
    *   **Context**: An educational resource and baseline code library where actor/critic symmetry is common.
*   `pineau2020improving`: Pineau, Joelle, et al. "Improving reproducibility in machine learning research (a report from the neurips 2019 reproducibility program)." arXiv preprint arXiv:2003.12206 (2020).
    *   **Context**: Cited for the high sensitivity of RL algorithms to implementation details and hyperparameters. Also for network architecture's impact on performance.
*   `henderson2018deep`: Henderson, Peter, et al. "Deep reinforcement learning that matters." Proceedings of the AAAI conference on artificial intelligence. Vol. 32. No. 1. 2018.
    *   **Context**: Cited for RL algorithm sensitivity. Specifically mentioned for providing a cursory analysis of disentangling actor and critic architectures, but without sufficient depth.
*   `Overfitting`: Zhang, Chiyuan, et al. "A study on overfitting in deep reinforcement learning." arXiv preprint arXiv:1804.06893 (2018).
    *   **Context**: Cited for impact of network architecture on RL performance and overfitting.
*   `Overfitting2`: Zhang, Amy X., Nicolas Ballas, and Joelle Pineau. "A dissection of overfitting and generalization in continuous reinforcement learning." arXiv preprint arXiv:1806.07937 (2018).
    *   **Context**: Cited for impact of network architecture on RL performance and overfitting.
*   `islam2017reproducibility`: Islam, Riashat, Peter Henderson, Maziar Gomrokchi, and Doina Precup. "Reproducibility of benchmarked deep reinforcement learning tasks for continuous control." arXiv preprint arXiv:1708.04133 (2017).
    *   **Context**: Cited for RL algorithm sensitivity and the importance of network sizes, but notes they don't consider actor/critic architectures separately.
*   `benchmarkingRL`: Duan, Yan, et al. "Benchmarking deep reinforcement learning for continuous control." International conference on machine learning. PMLR, 2016.
    *   **Context**: Cited for RL algorithm sensitivity and the impact of network architecture. Also as a baseline library with symmetric architectures.
*   `self-tuning`: Zahavy, Tom, et al. "A self-tuning actor-critic algorithm." Advances in Neural Information Processing Systems 33 (2020).
    *   **Context**: Cited as addressing the importance of network sizes but without considering actor/critic architectures separately.

#### Network Compression and Distillation

*   `Han2016DeepCC`: Han, Song, Huizi Mao, and William J. Dally. "Deep compression: Compressing deep neural network with pruning, trained quantization and huffman coding." arXiv preprint arXiv:1510.00149 (2015).
    *   **Context**: Pruning as a technique for reducing neural network parameter count.
*   `Hinton2015DistillingTK`: Hinton, Geoffrey, Oriol Vinyals, and Jeff Dean. "Distilling the knowledge in a neural network." arXiv preprint arXiv:1503.02531 (2015).
    *   **Context**: Knowledge distillation as a technique for reducing neural network parameter count.
*   `Ullrich2017SoftWF`: Ullrich, Karen, Edward Meeds, and Max Welling. "Soft weight-sharing for neural network compression." arXiv preprint arXiv:1702.04008 (2017).
    *   **Context**: Weight sharing as a technique for reducing neural network parameter count.
*   `rusu2015policy`: Rusu, Andrei A., et al. "Policy distillation." arXiv preprint arXiv:1511.06295 (2015).
    *   **Context**: Policy distillation as an effective tool for reducing network sizes in RL, hinting at excess modeling capacity in policy networks.

### Citations from `AnchorsRAM/root.tex`

#### Sim-to-Real and Domain Adaptation

*   `benchmarkingRobo`, `Sim2Real`, `Sim2multi`: Cited in the introduction to highlight that controllers trained in simulation can fail or perform poorly on real hardware due to the "reality gap".
*   `Muratore2022`, `pmlr-v155-sandha21a`: Used to introduce the concept of the "reality gap" and, more specifically, the "distributional sim-to-real gap," which arises from skewed data distributions in real-world operation compared to simulation.
*   `catastrophic-forgetting-wolczyk`, `catastrophic-forgetting-binici`: These are cited to define "catastrophic forgetting," the phenomenon where an agent fine-tuned on a new (real-world) domain forgets crucial behaviors learned in the original (simulation) domain.
*   `NFori`, `NFv2`: References Neuroflight, a precursor framework for embedding neural network controllers into drone firmware, noting its limitations in update flexibility which the new `SwaNNFlight` firmware addresses.
*   `Chinchali2021`, `orevi2023`: Mentioned as examples of systems that offload computation to a ground station, which can limit autonomy. `SwaNNFlight` is presented as an alternative that performs inference on-board.

#### RL Algorithms and Stability

*   `PPO`: Referenced as a stable adaptation technique (along with TRPO) that limits policy updates. Also mentioned as an algorithm that proved difficult to transition from TensorFlow 1 to TensorFlow 2 implementations, motivating the switch to DDPG-based methods for the flight controller.
*   `DDPG`, `SAC`, `TD3`: These are the three popular actor-critic algorithms that Anchor Critics were implemented on top of for the inverted pendulum benchmark experiments.
*   `henderson2018deep`: Cited to support the claim that on-policy algorithms like PPO and TRPO are known to be brittle and sensitive to implementation details.
*   `mysore2021caps`: Referenced for its "CAPS" regularization technique, which was added to DDPG to train viable flight controllers by mitigating oscillatory behavior.

#### Methodological Foundations & Contributions

*   `fpl2025`: Cites "Fulfillment Priority Logic (FPL)" as the theoretical foundation for combining the source (anchor) and target critic Q-values using a geometric mean, framing adaptation as a multi-objective problem.
*   `swannlake-github`: The citation for the open-source `SwaNNFlight` firmware and the Anchor Critics library developed as part of the research.
*   `mysore2021train`: Cited as prior work that used the older Neuroflight framework for training flight controllers.

### Citations from `REAL/REAL-manuscript.tex`

#### Core RL & Control Concepts

*   `SuttonBarto`: Foundational RL textbook. Cited for formalizing RL as "the optimal control of incompletely-known Markov decision processes".
*   `SARSA`, `Qlearning`, `DoubleQ`: Cited as examples of classical temporal difference (TD) learning techniques for solving RL problems in low-dimensional state spaces.
*   `REINFORCE`: Cited as an early policy gradient method that forms the basis for many deep RL techniques.
*   `sutton2000policy`: Cited for establishing policy gradient techniques which are fundamental to modern deep RL.
*   `dqn`, `alphago`, `alphazero`, `alphastar`: Cited as major successes of deep RL, demonstrating its power on complex tasks like video games, Go, and StarCraft.
*   `10.1145/325165.325247`: Citation for Perlin noise, which is used to generate more realistic, smoothly-varying goal signals during training, as opposed to simple step inputs.
*   `ZieglerNichols`: A classical method for tuning PID controllers, used to create a strong baseline for comparison in both simulation and real-world flight tests.

#### RL for Robotics & Sim-to-Real

*   `benchmarkingRobo`, `Sim2multi`, `Hwangbo2017ControlOA`: Cited to establish the problem of "over-actuation" and instability when transferring RL controllers trained in simulation to real hardware.
*   `learning2drive`: Another example of prior work that found mitigating control instability difficult.
*   `NFv2`, `NFori`, `NFThesis`: These cite the "Neuroflight" framework, which is the direct predecessor and baseline for the paper's "RE+AL" framework. They are referenced to describe the initial system, its successes (viability of PPO for control), and its significant limitations (inconsistent transfer, noisy control, high power consumption).
*   `Sim2Real`, `Overfitting`, `Overfitting2`: Cited to explain that a significant problem in deep RL is agents overfitting to the training domain (simulation) and failing to generalize to real-world inputs, leading to aberrant behavior.
*   `benchmarkingRL`: Cited to establish that RL algorithms are often sensitive to the specific dynamics of their training environments.
*   `dynamicweights`, `shelton2001balancing`: Referenced as examples of works that use additive composition for multi-objective rewards, a common but potentially problematic approach that the paper contrasts with its proposed multiplicative composition.
*   `amodei2016concrete`: Cited to support the argument that adversarial and poorly-scaled reward components in an additive structure can lead to destructive interference during optimization.
*   `Hajek1998`: Cites Fuzzy logic literature for the use of the product t-norm, which acts as a smooth logical AND operator and is the basis for the paper's multiplicative reward composition.
*   `Fleming1986HowNT`: Cited for the use of the geometric mean to compose rewards, which prevents the scalar reward from vanishing as more components are added.

#### Software and Simulation Frameworks

*   `baselines`: The OpenAI Baselines library, used for the PPO implementation.
*   `abadi2016tensorflow`: Citation for the TensorFlow framework, used for training and compiling the neural network agents.
*   `betaflight-homepage`: The Betaflight firmware, which is the open-source flight controller software that was modified to run the learned neural network policies.
*   `gazebo`, `DART`, `ODE`: Simulation tools. Neuroflight (the baseline) uses Gazebo with the DART physics engine (an improvement over the standard ODE) for higher fidelity simulation.
*   `GYM`: The OpenAI Gym toolkit, referenced as a standard for RL environments and for the Pendulum-v0 benchmark environment.

### Citations from `FPLIROS/root.tex` and its sections

#### Reward Design & Engineering

*   `comprehensive_reward_eng_and_shaping`: Cited for the general challenge of reward design in RL.
*   `booth2023perils`, `KNOX2023103829`: These papers are cited to highlight the prevalence of inefficient "trial-and-error" reward engineering among RL experts, which leads to overfitted and inadequate reward functions.
*   `hayes2023brief`, `Limitations_of_Scalarisation`: Referenced as examples of the flawed trial-and-error weight tuning process.
*   `inverse_rl_survey`: Cited as an alternative approach that avoids manual reward design by inferring rewards from demonstrations.
*   `eureka`, `yu2023language`: Cited as recent methods that delegate the reward design problem to Large Language Models.
*   `tokamak`, `radiotherapy`, `pianosi2013tree`, `VERSTRAETEN2019428`, `how_to_train_quad`: These are cited as examples of complex, real-world applications where practitioners naturally gravitate towards structured, compositional (often multiplicative or geometric) reward approaches, aligning with the paper's core thesis.
*   `lee2020learning`: A specific example of meticulous, multi-component reward engineering for quadrupedal locomotion.
*   `RL_challenges`: Cited to frame the work as a direct solution to the "Unspecified and Multi-Objective Reward Functions" challenge in real-world RL.
*   `Hu2020`: Referenced in the context of reward shaping techniques used to improve learning efficiency.
*   `fuzzy_reward_fn_rl`, `rl_with_fuzzy_testing`: Cited as related work in fuzzy logic that also addresses reward design by creating intermediate reward landscapes.

#### Multi-Objective Reinforcement Learning (MORL)

*   `survey_seq_dec_morl`: A key survey on MORL, cited for establishing vector rewards and noting the limitations of linear scalarization for non-linear objective relationships. Also cited in the context of the reward hypothesis.
*   `reymond2023actor`: Cited as a MORL method that uses a non-linear utility function, but is limited to discrete action spaces and assumes the utility function is given.
*   `sutton2018reinforcement`, `reward_is_enough`: These support Sutton's "Reward Hypothesis," the idea that any goal can be framed as maximizing a scalar reward.
*   `reward_hypothesis_false`, `settling_reward_hypothesis`: These are cited as counterarguments to the reward hypothesis, showing cases where it does not hold and motivating the need for more expressive MORL approaches.
*   `MOMARL`: Cited to show that linear utility functions can drive policies to suboptimal local minima when objectives conflict.
*   `SAKAWA199819`, `MODRL_framework`: Cited as general references for a-posteriori MORL methods.
*   `xu2020prediction`: An example of an a-posteriori MORL method using evolutionary algorithms. Also cited for maximizing the hypervolume indicator, which is equivalent to a geometric mean (`p=0`) FPL operator.
*   `shu2024learning`: An example of an a-posteriori MORL method using hypernetworks.
*   `alegre2023sample`: An example of an a-posteriori MORL method (GPI-PD) that uses Convex Coverage Sets.

#### Formal Methods & Logic

*   `Belta_Temporal`: A general reference for using temporal logics for structured specifications in robotics.
*   `kress2009temporal`, `lahijanian2011temporal`: Examples of temporal logic frameworks (STL, BLTL) for specifying robot behavior.
*   `aksaray2016q`: An example of extending temporal logic to learning-based control.
*   `jothimurugan2019composable`: The citation for SPECTRL, a domain-specific language for temporal specifications.
*   `priority_based_temporal_logics`: Cites "Weighted STL," which uses smooth min/max and arithmetic/geometric means. The paper notes that these are all special cases of its more general power mean operators.
*   `tnorm`: Cited in the discussion of the relationship between FPL operators and fuzzy logic t-norms.

#### RL Algorithms & Sample Efficiency

*   `towers2024gymnasium`: The citation for the Gymnasium benchmark suite used in the experiments.
*   `DDPG`: The baseline algorithm that the paper's `BPG` algorithm extends.
*   `SAC`, `TQC`, `CrossQ`: State-of-the-art sample-efficient RL algorithms used as baselines for comparison in the experiments.
*   `REDQ`: An algorithm that addresses overestimation bias with ensembles of critics. The paper's approach is contrasted with this.
*   `power_mean_properties`: A general reference for the mathematical properties of power means, which are the foundation of the FPL logic.

* `sample_efficient_rl`:  outlines why sample efficiency is a critical bottleneck for RL and surveys several directions for improvement

### Citations from `CertiflightProgress`

*   `NEURIPS2019_2647c1db`: This is cited in the context of synthesizing certifiable Neural Network based controllers. The document mentions that this work shows it's possible to create such controllers, which could be applied to a "Safe-visor" architecture, where the certified controller takes over when a high-performance (but uncertified) controller is deemed likely to be unsafe. It notes that these techniques are computationally expensive.

### Citations from `CAPS/root.tex`

#### RL for Control and Sim-to-Real

*   `Dextrous`, `RoboImitationPeng20`, `mnih2015human`: Cited as examples of deep RL being successfully applied to complex control problems where manual controller design is difficult.
*   `benchmarkingRobo`, `Sim2Real`, `Sim2multi`, `benchmarkingRL`: These are cited to establish that RL-based controllers can exhibit problematic behaviors like oscillations, especially when transferred from simulation to real hardware.
*   `NFThesis`, `NFv2`, `NFori`: These cite the "Neuroflight" framework, which is the direct predecessor and baseline for the work. The `CAPS` paper positions itself as a solution to the control smoothness and sim-to-real transfer problems observed in Neuroflight.
*   `Hwangbo2017ControlOA`: Cited as another work that attempts to condition RL agent behavior through reward engineering to achieve stable flight.
*   `Ziegler1942OptimumSF`: The classic Ziegler-Nichols method for tuning PID controllers, used as a strong baseline for comparison.

#### RL Theory, Reproducibility, and Regularization

*   `DDPG`, `SAC`, `TD3`, `PPO`, `TRPO`: These are the common continuous control RL algorithms mentioned. CAPS is evaluated on top of DDPG, SAC, TD3, and PPO in the benchmark experiments.
*   `Ilyas2020A`: A key citation used to argue that relying on reward engineering is flawed because the surrogate value functions learned by RL agents may not accurately represent the true optimization landscape, making direct policy optimization (like CAPS) a more reliable approach.
*   `Overfitting`, `Overfitting2`, `Engstrom2020Implementation`, `pineau2020improving`: These are cited to highlight the broader issues of reproducibility and sensitivity to hyperparameters and implementation details in RL research.
*   `liu2019regularization`: Cited as a work that highlights regularization as an understudied but useful tool in RL. CAPS is framed as a specific type of regularization focused on action policy smoothness.
*   `repRL`, `repRL2`: These papers are cited for their work on using temporal coherence constraints in *state representation* learning. The CAPS paper draws an analogy, applying a similar concept to the *action policy* itself.
*   `shen2020deep`: Cited as concurrent work that also uses a form of spatial smoothness regularization for robustness. The CAPS paper distinguishes itself by also including a temporal smoothness component, which it argues is crucial for sim-to-real transfer.
*   `sutton2000policy`, `Qlearning`: Foundational RL concepts (policy gradients, Q-learning) mentioned in the background section.
*   `scaman2018lipschitz`, `miyato2018spectral`, `cisse2017parseval`: These are cited to support the idea that while computing exact Lipschitz constants is NP-hard, regularization techniques can be used to approximate and encourage this property, leading to better generalization and robustness. CAPS is framed as a method that effectively minimizes the temporal and spatial Lipschitz constants of the policy.

#### Software and Benchmarks

*   `GYM`: The OpenAI Gym toolkit, used for the benchmark environments (Pendulum, LunarLander, Reacher, Ant).
*   `stable-baselines`, `SpinningUp2018`, `baselines`: Common RL libraries and codebases used for implementing the algorithms and finding hyperparameters for the benchmark experiments.
*   `betaflight-homepage`: Cited for the `blackbox_decode` tool used for analyzing control signals.
*   `DSP`: A general reference to digital signal processing, mentioned in the context of why simple filtering is not a straightforward solution for neural network controllers.
