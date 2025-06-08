#import "../commands.typ": *
#import "../style.typ": *
#import "../../figures/mdp.typ": mdp
#import "../../figures/momdp.typ": momdp
#import "../../figures/transitions.typ": make_trajectory


= Background and Related Work <chap:background_related_work>

== Standard Reinforcement Learning Definitions


=== Discrete-Time Markov Decision Processes <def-mdp>

The standard formalization in Reinforcement Learning of sequential decision making @SuttonBarto @barto2017some, defined by a tuple $(#S, #A, TT, #R, gamma)$, where:

#note(gradient: primary_gradient)[
  #table(
    columns: (auto, auto, auto),
    row-gutter: 2em,
    align: (right, left, left),
    stroke: none,
    column-gutter: (-0.5em, 0.5em),
    [#S], [: Set], [
      *State space*, the information we have about the world,\
      e.g. sensor readings and physical configurations
    ],
    [#A], [: Set], [
      *Action space*, the decision we can take,
      e.g. motor commands
    ], 
    [$TT$], [: #S $times$ #A $-> Delta(#S)$], [
      *Transition distribution function*,\
      e.g. the definition of (possibly stochastic) dynamics of our relevant system
    ],
    [#R], [: #S $times$ #A $times$ #S $-> RR$], [
      *Reward function*, the numerical representation of how "good" a transition is,\
      e.g. 0 if the robot falls over, 1 if it reaches the goal
    ],
    [$reward(gamma)$], [: $[0,1)$], [*Discount factor*, the decay rate of rewards],
  )
]

This abstraction captures a notion of process of moving through states in $#S$ using actions in $#A$.
==== Transitions
The system _transitions_ from the current state $#st$ to the next state $#stp1$ using action $#at$. The $(#st, #at, #stp1)$ tuple is what we define as the *transition*.
==== Trajectories
A trajectory is a sequence of transitions:
#figure(
  make_trajectory(with_policy: false, with_reward: false),
  caption: $"trajectory" = ((state(s_0), action(a_0), state(s_1)), (state(s_1), action(a_1), state(s_2)), (state(s_2), action(a_2), state(s_3)), ...) $
)

==== The Memoryless Property
The key property is that the transition function $TT$ is only defined with respect to the current #state(state) and #action(action), with no _knowledge_ of the history of transitions. This property enables many of the techniques used in RL.

=== Making Decisions in MDPs

==== Policies <def-policy>
A policy $pi : #S -> Delta(#A)$ defines the "decision maker", it maps states to a probability distribution over actions. For deterministic policies, this would be a function $pi : #S -> #A$.

#figure(
  mdp,
  caption: [The Markov Decision Process showing how a state #st in the state space #S and action $#at ~ pi(#st)$ determine the probability distribution $#stp1 ~ TT(#st,#at)$ over next states. Dashed arrows (#box[#{import "@preview/cetz:0.3.4"; cetz.canvas(cetz.draw.line((0,0), (0.6,0), mark: (end: "triangle"), stroke: (dash: "dashed", thickness: 0.7pt)))}]) indicate sampling from a distribution.]
)
#block(breakable: false)[
  ==== Rewards <def-reward>
  The reward function $R : #S times #A times #S -> RR$ is a function that maps a transition to a real-valued reward, in RL it is our main interface for choosing which policies are better at solving the task at hand than others.
  #figure(
    make_trajectory(with_policy: true, with_reward: true),
    caption: [Transitions produced by a policy's actions results in a reward signal.]
  )
]

==== The Reward Hypothesis <def-rew-hypothesis>
Established in the foundational RL textbook by @SuttonBarto the hypothesis states: "all of what we mean by goals and purposes can be well thought of as maximization of the expected value of the cumulative sum of a received scalar signal." This hypothesis has provided a unifying framework for RL research, enabling the development of powerful algorithms like Q-learning, policy gradients, and actor-critic methods.

=== Value Functions and Q-Functions <def-value-function>
The main goal in RL is to find policies that maximize the expected return. 

==== Returns <def-return>
The return is the discounted sum of rewards: $sum_(t=0)^infinity reward(gamma)^t reward(R)(#st,#at,#stp1)$. The discount factor $reward(gamma)$ determines how much to prioritize immediate versus future rewards.


==== Value Functions
A #Q\-value function $#Q^pi$ represents the expected return when following policy $pi$ from state #state($s_0$) and action #action($a_0$):

$ #Q^pi (#state($s_0$), #action($a_0$)) = expect [ sum_(t=0)^infinity gamma^t reward(R)(#st,#at,#stp1) | #stp1 ~ TT(#st,#at), #at ~ pi(#st) ] $

Similarly, a value function $#V^pi$ represents the expected return when in state #state($s_0$) and then following $pi$:

$ #V^pi (#state($s_0$)) = expect [ #Q^pi (#state($s_0$), #action($a_0$)) | #action($a_0$) ~ pi(#state($s_0$)) ] $

Value functions form the basis of deep reinforcement learning @DQN_paper, capturing the specific notion of optimality emerging from the chosen reward function. They are commonly approximated by neural networks.


== Multi-Objective Reinforcement Learning <def-morl>

Multi-objective reinforcement learning extends the standard MDP framework defined in @def-mdp to handle multiple reward signals simultaneously. Instead of a single scalar reward function, MORL considers a vector reward function $reward(bold(arrow(R))) : #S times #A times #S -> RR^n$ composed of $n$ reward functions $(reward(R_1), reward(R_2), ..., reward(R_n))$ where each $reward(R_i) : #S times #A times #S -> RR$ represents a distinct objective @survey_seq_dec_morl @practical_guide.

This extension fundamentally challenges the reward hypothesis in @def-rew-hypothesis, changing the optimization problem. Rather than maximizing a single expected return, the agent must now consider a vector of  expected returns, making the value function a vector-value function:

$ reward(bold(arrow(V)))^pi(s) = (reward(V_1)^pi(s), reward(V_2)^pi(s), ..., reward(V_n)^pi(s))
space "where" space
reward(V_i)^pi(s) = expect [ sum_(k=0)^infinity reward(gamma)^k reward(R_i) (s_(t+k), a_(t+k), s_(t+k+1)) ] $

The challenge becomes balancing competing objectives @SAKAWA199819, as policies that excel at one objective may perform poorly on others. This field provides the most direct foundation for our work, though the existing formulations face significant limitations that motivate our fulfillment-centric alternative. Put more formally, rather than a total ordering given by a single objective function, the multiplicity of objectives induces a partial ordering which is consolidated using a utility function.


=== Utility Functions
A utility function $U: RR^n -> RR$ is defined as a function that maps multi-objective returns to scalar values, thereby flattenting the partial ordering introduced by having vector value functions.

==== Linear Utility
The most prevalent utility function in MORL based methods is the linear utility function, which combines objectives as weighted sums: $U(bold(arrow(G))) = sum_(i=1)^n w_i G_i$. Using this approach, we can define flattened Q-value functions as follows:

$ Q^pi (s,a) = expect [ sum_(i=1)^n w_i sum_(t=0)^infinity gamma^t R_i(s_t, a_t, s_(t+1)) | s_0 = s, a_0 = a ] $

The brittleness of linear scalarization becomes particularly problematic in RL settings, where small changes in weights can lead to dramatically different learned behaviors due to the sequential nature of decision-making and the compounding effects of policy changes.



=== Pareto Optimality in Policy Space

MORL adapts the foundational concept of Pareto optimality to policy space. A policy $pi^*$ is Pareto optimal if no other policy $pi'$ exists such that $reward(V_i)^{pi'}(s) >= reward(V_i)^{pi^*}(s)$ for all objectives $i$ and states $s$, with strict inequality for at least one objective-state pair. The Pareto frontier represents the set of all Pareto optimal policies, providing a complete characterization of optimal trade-offs in policy space.

This differs from traditional multi-objective optimization where Pareto optimality applies to solution vectors. In MORL, we must consider Pareto optimality over entire value functions $reward(bold(arrow(V)))^pi = (reward(V_1)^pi, reward(V_2)^pi, ..., reward(V_n)^pi)$, making the problem significantly more complex than traditional multi-objective optimization.


=== Pareto-Based MORL

To address scalarization limitations, Pareto-based approaches explicitly optimize for multiple non-dominated policies. The Pareto Q-Learning algorithm @pareto_q_learning maintains sets of Pareto optimal Q-vectors for each state-action pair:

$ Q_"Pareto"(s,a) = {bold(arrow(q)) in RR^n : bold(arrow(q)) text(" is Pareto optimal in ") {bold(arrow(Q))^pi(s,a) : pi in Pi}} $

While theoretically elegant, this approach faces significant computational and memory challenges. The number of Pareto optimal Q-vectors can grow exponentially with the number of objectives, making the approach intractable for high-dimensional objective spaces or large state-action spaces common in robotics applications.

=== Constraint-Based Approaches

Constraint-based MORL treats some objectives as hard constraints while optimizing others. This approach modifies the standard MDP to include constraint functions $C_j : #S times #A times #S -> RR$ and constraint thresholds $c_j$:

$ max_pi expect [ sum_(t=0)^infinity gamma^t R_"primary"(s_t, a_t, s_(t+1)) ] quad text("subject to") quad expect [ sum_(t=0)^infinity gamma^t C_j(s_t, a_t, s_(t+1)) ] <= c_j $

These approaches ensure constraint satisfaction during learning but require practitioners to distinguish between primary objectives and constraints, which may not align with natural problem specifications. They struggle with soft constraints and the complex hierarchical relationships common in robotics where objectives may need to be violated temporarily to achieve better long-term performance.

=== Multi-Objective Value Functions

MORL requires extensions to standard value function concepts. Multi-objective Q-functions become vector-valued:

$ bold(arrow(Q))^pi(s,a) = (Q_1^pi(s,a), Q_2^pi(s,a), ..., Q_n^pi(s,a)) $

where each component $Q_i^pi(s,a)$ represents the expected return for objective $i$. Similarly, multi-objective value functions become:

$ bold(arrow(V))^pi(s) = (V_1^pi(s), V_2^pi(s), ..., V_n^pi(s)) $

The Bellman equations must be adapted to handle vector returns, leading to vector Bellman operators that preserve the multi-objective structure throughout learning.

=== Fundamental Limitations of MORL

Traditional MORL approaches face several fundamental limitations that have hindered their adoption in complex robotics applications:

*Semantic Loss*: Even vector-valued approaches ultimately compress multi-objective information into scalar decisions during action selection, losing the semantic meaning of individual objectives.

*Specification Complexity*: MORL requires practitioners to specify preferences, constraints, or selection criteria that are often as difficult to design as the original reward functions.

*Deployment Brittleness*: MORL policies trained for specific trade-offs often struggle when deployed in environments with different objective relationships.

*Limited Logical Expressivity*: Traditional MORL approaches cannot directly express the logical relationships ("safety AND performance", "efficiency OR speed") that naturally characterize robotics objectives.

*Computational Scalability*: Methods that maintain explicit Pareto frontiers face exponential growth in computational requirements as the number of objectives increases.


== Avoiding Reward Engineering
There are multiple subfields of reinforcement learning that focus efforts on avoiding the need for designing reward functions.

==== Large Language Model-Based Reward Engineering
Recent work such as the work of @eureka demonstrates how large language models can automate reward design. Eureka generates reward functions from natural language descriptions, employing a vision model for evaluating the adherence of the final policy to the original intentions representing in the textual description. While promising, such approaches still rely on standard reward engineering methodology inheriting their fundamental limitations.

==== Imitation Learning
Imitation learning provides an alternative to manual reward engineering by learning policies directly from expert demonstrations. Rather than designing reward functions, practitioners can leverage demonstrated expert behavior as the specification of desired behavior. This approach encompasses behavior cloning and inverse reinforcement learning, offering different strategies for avoiding manual reward specification.

==== Behavior Cloning
Behavior cloning completely avoids reward engineering by treating policy learning as supervised learning, directly mapping observed states to expert actions without any reward signal. While this represents the most direct form of reward avoidance, it suffers from distribution shift problems when the learned policy encounters states not present in the demonstration data.

==== Inverse Reinforcement Learning
Inverse reinforcement learning avoids manual reward engineering by automatically inferring reward functions from expert demonstrations rather than requiring explicit design. The work of @ng2000algorithms established the theoretical foundations, while @abbeel2004apprenticeship demonstrated practical applications. However, IRL approaches still typically result in scalar reward functions and face challenges in multi-objective scenarios where expert demonstrations may represent complex trade-offs between competing objectives.

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