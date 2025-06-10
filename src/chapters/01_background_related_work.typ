#import "../commands.typ": *
#import "../style.typ": *
#import "../../figures/mdp.typ": mdp
#import "../../figures/momdp.typ": momdp
#import "../../figures/transitions.typ": make_trajectory


= Background and Related Work <chap:background_related_work>

== Background

=== Reinforcement Learning

==== Discrete-Time Markov Decision Processes <def-mdp>
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
The key property is that the transition function $TT$ is only defined with respect to the current #state(state) and #action(action), with no _knowledge_ of the history of transitions. This property enables many of the techniques employed in RL.

==== Policies <def-policy>
A policy $pi : #S -> Delta(#A)$ defines the "decision maker", it maps states to a probability distribution over actions. For deterministic policies, this would be a function $pi : #S -> #A$.

#figure(
  mdp,
  caption: [The Markov Decision Process showing how a state #st in the state space #S and action $#at ~ pi(#st)$ determine the probability distribution $#stp1 ~ TT(#st,#at)$ over next states. Dashed arrows (#box[#{import "@preview/cetz:0.3.4"; cetz.canvas(cetz.draw.line((0,0), (0.6,0), mark: (end: "triangle"), stroke: (dash: "dashed", thickness: 0.7pt)))}]) indicate sampling from a distribution.]
)
==== Rewards <def-reward>
  The reward function $R : #S times #A times #S -> RR$ is a function that maps a transition to a real-valued reward, in RL it is our main interface for choosing which policies are better at solving the task at hand than others.
  #figure(
    make_trajectory(with_policy: true, with_reward: true),
    caption: [Transitions produced by a policy's actions results in a reward signal.]
  )

==== The Reward Hypothesis <def-rew-hypothesis>
Established in the foundational RL textbook by @SuttonBarto the hypothesis states: "all of what we mean by goals and purposes can be well thought of as maximization of the expected value of the cumulative sum of a received scalar signal." This hypothesis has provided a unifying framework for RL research, enabling the development of powerful algorithms like Q-learning, policy gradients, and actor-critic methods.


==== Returns <def-return>
The return is the discounted sum of rewards: $sum_(t=0)^infinity reward(gamma)^t reward(R)(#st,#at,#stp1)$. The discount factor $reward(gamma)$ determines how much to prioritize immediate versus future rewards. Mapping a trajectory to a value in $RR$. The main goal in RL is to find policies that maximize the expected return. 


==== Value Functions
A #Q\-value function $#Q^pi$ represents the expected return when following policy $pi$ from state #state($s_0$) and action #action($a_0$):

$ #Q^pi (#state($s_0$), #action($a_0$)) = expect [ sum_(t=0)^infinity gamma^t reward(R)(#st,#at,#stp1) | #stp1 ~ TT(#st,#at), #at ~ pi(#st) ] $

Similarly, a value function $#V^pi$ represents the expected return when in state #state($s_0$) and then following $pi$:

$ #V^pi (#state($s_0$)) = expect [ #Q^pi (#state($s_0$), #action($a_0$)) | #action($a_0$) ~ pi(#state($s_0$)) ] $

Value functions form the basis of deep reinforcement learning @DQN_paper, capturing the specific notion of optimality emerging from the chosen reward function. They are commonly approximated by neural networks.

// ==== The Bellman Equations

// $ #V^pi (#state($s_0$)) = expect [ reward(R)(#st,#at,#stp1) + gamma #V^pi (#state($s_1$)) | #stp1 ~ TT(#st,#at), #at ~ pi(#st) ] $

// $ #Q^pi (#state($s_0$), #action($a_0$)) = reward(R)(#st,#at,#stp1) + gamma #V^pi (#state($s_1$)) $

// $ #Q^pi (#state($s_0$), #action($a_0$)) = reward(R)(#st,#at,#stp1) + gamma expect [ #Q^pi (#state($s_1$), #action($a_1$)) | #stp1 ~ TT(#st,#at), #at ~ pi(#st) ] $

==== Optimal Policy
A policy is considered optimal and denoted as $pi^*$ if it has the highest possible value in all states:
$forall_pi forall_(state(s) in #S) #V^pi^*(state(s)) >= #V^pi(state(s))$


=== Multi-Objective Reinforcement Learning <def-morl>

Multi-objective reinforcement learning extends standard MDPs with multiple reward signals simultaneously forming MOMDPs. 

==== Vector Reward Functions
Instead of a single scalar reward, MORL considers vector reward functions $reward(bold(arrow(R))) : #S times #A times #S -> RR^n$ composed of $n$ reward functions $reward(bold(arrow(R)))(state(s), action(a), state(s')) = (reward(R_1)(state(s), action(a), state(s')), reward(R_2)(state(s), action(a), state(s')), ..., reward(R_n)(state(s), action(a), state(s')))$ where each $reward(R_i) : #S times #A times #S -> RR$ represents a distinct objective @survey_seq_dec_morl @practical_guide.

This extension fundamentally challenges the reward hypothesis in @def-rew-hypothesis, changing the optimization problem.

==== Vector Value Functions
Rather than maximizing a single expected return, the agent must now consider a vector of expected returns, making the value function a vector-value function:

$ reward(bold(arrow(V)))^pi (state(s)) = (reward(V_1)^pi (state(s)), reward(V_2)^pi (state(s)), ..., reward(V_n)^pi (state(s)))
space "where" space
reward(V_i)^pi (state(s)) = expect [ sum_(k=0)^infinity reward(gamma)^k reward(R_i) (state(s_t), action(a_t), state(s_(t+1))) ] $

==== Partial Ordering
In the single valued case of standard MDPs, we can compare one value with another as the reals form a total order. This allows us to define the optimal policy as one forming the highest value. The multi-valued nature of MOMDPs, however, introduces a partial ordering instead. To highlight the issue consider the following example:
$#V^(pi_1)(state(s)) = (2.3, 4.5)$ and $#V^(pi_2)(state(s)) = (7.3, 6.5)$. It is clear the $pi_2$ is better than $pi_1$ on both objectives on state $s$, we can make the statement $#V^pi_1(state(s)) < #V^pi_2(state(s))$, this is known as *pareto dominance*. However, how do we judge $#V^(pi_3)(state(s)) = (1.3, 7.5)$? 

Policy $pi_3$ performs worse than $pi_1$ on the first objective but better on the second. Similarly, $pi_3$ is significantly worse than $pi_2$ on the first objective but superior on the second. Neither $pi_1$ nor $pi_2$ pareto dominates $pi_3$. This creates an incomparable relationship where we cannot definitively rank these policies without flattening the partial ordering, motivating the use of utility functions.

==== Utility Functions
A utility function $U: RR^n -> RR$ is defined as a function that maps multi-objective returns to scalar values, flattenting the partial ordering introduced by having vector value functions, allowing us to recover optimality.

==== Linear Utilities
The most prevalent utility function in MORL based methods is the linear utility function, which combines objectives as weighted sums: $U(bold(arrow(G))) = sum_(i=1)^n w_i G_i$. Using this approach, we can define flattened Q-value functions as follows:

$ #Q^pi (state(s_0), action(a_0)) =sum_(i=1)^n w_i expect [ sum_(t=0)^infinity gamma^t R_i (state(s_t), action(a_t), state(s_(t+1)))] = expect [ sum_(t=0)^infinity sum_(i=1)^n w_i gamma^t R_i (state(s_t), action(a_t), state(s_(t+1)))] =  $

Note that linear utilitilities enjoy the property that a utility function over the rewards produces the same value as a utility function over the value functions.



==== Pareto Optimality in Policy Space
MORL adapts the foundational concept of Pareto optimality to policy space. A policy $pi^*$ is Pareto optimal if no other policy $pi'$ exists such that $reward(V_i)^(pi')(state(s)) >= reward(V_i)^(pi^*)(state(s))$ for all objectives $i$ and states $s$, with strict inequality for at least one objective-state pair. The Pareto frontier represents the set of all Pareto optimal policies, providing a complete characterization of optimal trade-offs in policy space.

== Logical Specifications for Robotics

The mathematical foundations for composing multiple objectives draw extensively from continuous logic and fuzzy systems theory. This work provides essential tools for extending discrete logical relationships to continuous domains.

=== Fuzzy Logic Foundations

Fuzzy logic extends Boolean logic to the continuous interval $[0,1]$, enabling smooth reasoning about concepts that admit degrees of truth. T-norms and T-conorms provide the mathematical foundations for continuous logical operations, satisfying commutativity, associativity, and monotonicity properties while extending AND and OR operations to continuous domains.

Fuzzy systems theory establishes connections between fuzzy logic and probability theory, multi-valued logic, and approximate reasoning, demonstrating the broad applicability of continuous logic operators across diverse domains.


== Related Work

=== Fundamental Limitations of MORL

Traditional MORL approaches face several fundamental limitations that have hindered their adoption in complex robotics applications:

*Semantic Loss*: Even vector-valued approaches ultimately compress multi-objective information into scalar decisions during action selection, losing the semantic meaning of individual objectives.

*Specification Complexity*: MORL requires practitioners to specify preferences, constraints, or selection criteria that are often as difficult to design as the original reward functions.

*Deployment Brittleness*: MORL policies trained for specific trade-offs often struggle when deployed in environments with different objective relationships.

*Limited Logical Expressivity*: Traditional MORL approaches cannot directly express the logical relationships ("safety AND performance", "efficiency OR speed") that naturally characterize robotics objectives.

*Computational Scalability*: Methods that maintain explicit Pareto frontiers face exponential growth in computational requirements as the number of objectives increases.


=== Avoiding Reward Engineering
There are multiple subfields of reinforcement learning that focus efforts on avoiding the need for designing reward functions.

==== Large Language Model-Based Reward Engineering
Recent work such as the work of @eureka demonstrates how large language models can automate reward design. Eureka generates reward functions from natural language descriptions, employing a vision model for evaluating the adherence of the final policy to the original intentions representing in the textual description. While promising, such approaches still rely on standard reward engineering methodology inheriting their fundamental limitations.

==== Imitation Learning
Imitation learning provides an alternative to manual reward engineering by learning policies directly from expert demonstrations. Rather than designing reward functions, practitioners can leverage demonstrated expert behavior as the specification of desired behavior. This approach encompasses behavior cloning and inverse reinforcement learning, offering different strategies for avoiding manual reward specification.

==== Behavior Cloning
Behavior cloning completely avoids reward engineering by treating policy learning as supervised learning, directly mapping observed states to expert actions without any reward signal. While this represents the most direct form of reward avoidance, it suffers from distribution shift problems when the learned policy encounters states not present in the demonstration data.

==== Inverse Reinforcement Learning
Inverse reinforcement learning avoids manual reward engineering by automatically inferring reward functions from expert demonstrations rather than requiring explicit design. The work of @ng2000algorithms established the theoretical foundations, while @abbeel2004apprenticeship demonstrated practical applications. However, IRL approaches still typically result in scalar reward functions and face challenges in multi-objective scenarios where expert demonstrations may represent complex trade-offs between competing objectives.


=== Robust Deployment and Transfer Learning

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
while highlighting challenges in real-world deployment.

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