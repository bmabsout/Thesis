#import "../commands.typ": *

= Synthesis and Conclusion <chap:synthesis>

This thesis has presented a unified framework for bridging the *intent-to-reality gap* in robot learning. We began by deconstructing this gap into a cascade of three interconnected challenges: translating human intent into a formal language, optimizing a policy that adheres to that specification, and deploying that policy in the real world without losing its capabilities. By reframing robot learning from a paradigm of reward maximization to one of *fulfillment satisfaction*, we have developed a cohesive set of solutions that address each stage of this pipeline, transforming robot learning from a brittle art into a principled engineering discipline.

This final chapter synthesizes these contributions into a single narrative, tracing the path from high-level human intent to robust, deployed robot behavior. It re-examines the broader implications of this fulfillment-centric perspective and concludes by reflecting on the journey that led to this reconceptualization of how we design and build intelligent systems.

== A Unified Framework for Bridging the Gap <chap:synthesis:unified_framework>

The core argument of this thesis is that the disparate challenges of objective specification, reward hacking, and catastrophic forgetting are not independent problems but symptoms of a single, underlying failure: the inability of traditional methods to preserve the semantic meaning of human intent throughout the learning process. Our framework provides an end-to-end solution by introducing mechanisms that explicitly encode, optimize, and preserve this intent.

=== From Intent to Specification: The Language of Fulfillment <chap:synthesis:unified_framework:intent_to_spec>

The journey begins at the *intent-to-specification gap*, where the nuance of human goals is often lost in the restrictive language of scalar rewards. We addressed this with *Fulfillment Priority Logic (FPL)* (@chap:encoding_intentionality), a formal language that allows practitioners to express complex objective relationships—priorities, trade-offs, and logical dependencies—in a way that is both intuitive and mathematically precise.

Built on the foundation of the generalized mean, FPL replaces the ambiguous process of weight tuning with a structured composition of *fulfillment functions*. These functions map system performance to a normalized $[0,1]$ score, providing an absolute measure of satisfaction for each objective. By composing these fulfillments with logical operators like `and` and `or`, FPL preserves the semantic meaning of objectives, enabling specifications like "prioritize safety above all else, and conditional on being safe, balance speed and efficiency." This provides the first pillar of our framework: a language that faithfully captures human intent.

=== From Specification to Behavior: Principled Optimization <chap:synthesis:unified_framework:spec_to_behavior>

With a semantically rich specification, the challenge shifts to the *specification-to-behavior gap*: ensuring the learning algorithm produces a policy that actually fulfills the specified intent. Our contributions here provide the necessary optimization machinery.

First, the *Balanced Policy Gradient (BPG)* algorithm (@chap:encoding_intentionality:optimizer:bpg_algorithm) extends actor-critic methods to directly optimize FPL formulas. By learning a vector of *fulfillment Q-values*—one for each objective—and composing them only at the actor update stage, BPG separates the learning of individual objective satisfaction from the trade-offs between them. This prevents the kind of "reward hacking" common in scalarized systems and leads to more stable and sample-efficient learning.

Second, we recognized that some objectives, like smoothness, are universal. *Conditioning for Action Policy Smoothness (CAPS)* (@chap:ubo) provides an architectural solution, baking these fundamental requirements directly into the policy optimization rather than cluttering the specification. This embodies the principle of *behavioral decomposition*, separating universal requirements from task-specific goals and ensuring a baseline of robust, smooth control without manual intervention.

=== From Simulation to Reality: Preserving Intent Through Adaptation <chap:synthesis:unified_framework:sim_to_real>

The final challenge is the *simulation-to-reality gap*, where policies catastrophically forget their training when adapted to real-world data. We reframed this not as a technical failure but as a *specification failure*. Fine-tuning on limited real-world data implicitly tells the agent that the comprehensive behaviors learned in simulation no longer matter.

Our solution, *compositional adaptation with Anchor Critics* (@chap:adaptation_anchors), makes this specification explicit. We treat the value function learned in simulation as a *derived specification* that encodes the full set of desired behaviors. During adaptation, we use FPL to compose this "anchor" specification with the new specification being learned from real-world data. The resulting policy is optimized to satisfy both: adapting to real dynamics while preserving the rich behavioral repertoire from simulation. This prevents catastrophic forgetting by design, completing the chain of semantic preservation from initial intent to final deployment.

=== Architectural Foundations <chap:synthesis:unified_framework:architecture>

Underpinning this entire framework is a suite of architectural contributions that make its deployment on resource-constrained hardware possible. Our work on *Asymmetric Actor-Critic* architectures demonstrated that policy networks can be dramatically smaller than value networks, a key enabler for the dual-critic design of Anchor Critics. The *SwaNNFlight* architecture (@chap:architecture:swannflight) provides the complete embedded system, enabling live, on-the-fly updates of neural policies on a real quadrotor without interrupting flight. These systems contributions are not merely implementation details; they are the crucial final link that allows our theoretical framework to have a practical impact, closing the loop from abstract mathematics to tangible, real-world behavior.

== Broader Implications and Future Vision <chap:synthesis:implications>

This work represents a fundamental departure from the dominant linear trade-off-based thinking in multi-objective optimization. By moving from the maximization of a scalar utility to the fulfillment of a structured logical formula, we address the core semantic limitations that have hindered the adoption of MORL in complex, real-world applications. The fulfillment-centric perspective naturally aligns with control theory's focus on satisfying constraints, creating a bridge between the data-driven flexibility of learning and the rigorous guarantees of control. These principles not only open new avenues for research in encoding robot behavior but also allow MORL to be a more practical and powerful tool. Outside of robotics, this framework can be applied to any domain where multiple objectives compete and a notion of fulfillment is important, with implications for broader machine learning problems, financial optimization, and decision-making in healthcare among other domains.

Furthermore, this new engineering discipline provides a concrete pathway toward solving the broader problem of AI alignment. The framework's ability to verifiably link machine behavior back to explicit human intent is a foundational component for building trustworthy autonomous systems. The vision is one where the specification of complex robot behaviors is a transparent, reliable process, enabling seamless human-machine collaboration and the widespread adoption of intelligent systems that are demonstrably aligned with human values. This transforms the relationship between designer and machine from one of unpredictability and frustration to one of clarity and confidence.

== Limitations and Challenges <chap:synthesis:limitations>

While this framework provides a significant step forward, it is not without limitations that point toward important areas for future work. The expressive power of FPL, while greater than linear scalarization, does not yet encompass all desirable objective relationships, such as complex temporal logic or stochastic dependencies. From a practical standpoint, crafting complex FPL specifications still requires domain expertise, and the development of more mature, intuitive tooling is necessary for widespread adoption. Finally, broader empirical validation across more diverse domains and long-term deployments is needed to fully characterize the framework's performance and failure modes. These challenges, however, represent a rich landscape for future research building upon the fulfillment-centric foundation laid by this thesis.

== Future Research Directions <chap:synthesis:future>

The limitations and broader implications point toward several promising avenues for future research.

=== Logical Extensions <chap:synthesis:future:logical>

==== Predicate Fulfillment Logic <chap:synthesis:future:logical:predicate>
We can extend fulfillment logic to more general settings that offer more expressive power by considering the power mean as an aggregation operator rather than the base for our conjunction operator. Notice how in continuous logic and how in predicate fuzzy logic, the #raw("infimum") operator acts as an aggregator for the $forall$ quantifier, and the #raw("supremum") operator acts as the base for the $exists$ quantifier. By replacing these with a more general $pmean(p)$-based quantifier $fbox(p)$, statements like $forall_(x in X), exists_(y in Y), x and y$ can be built like so: $ fbox(-infinity)_(x in X), fbox(infinity)_(y in Y), x and y$. If we quanitfy over a continuous domain for example this new quantifier evaluates to:
$ fbox(p)_(x in [0, 1]), x  colon.eq root(p, integral_0^1 x^p d x) $
Using the power mean as an aggregation operator is a more natural fit as the power mean is not generally associative and neither are the classical quantifiers in full generality, i.e. $forall exists eq.triple.not exists forall$. The ability to associate the quantifiers, i.e. $forall_x forall_y eq.triple forall_(x,y)$, gets lost under the fulfillment quantifier unless $|p| = infinity$, i.e. $fbox(0)_x, fbox(0)_y, eq.triple.not fbox(0)_(x,y)$.


==== Robust Fulfillments <chap:synthesis:future:logical:robust>
Having a range of fulfillment values for each objective allows the generalization of fulfillment logic to cases where robustness or uncertainty needs to be represented over fulfillment values. We can extend fulfillment values to include ranges, for instance take the following equation:
$ [0.5, 0.7] and^(-infinity) [0.3, 0.8] = [0.3, 0.7] $
It describes the range of the outputs given a range of input fulfillments.
Take noisy sensor readings as an example, if we are unsure how well we are fulfilling the objective, we can represent this as a range of values, then worry about the worst case or the average case.

==== Probabilistic Fulfillments <chap:synthesis:future:logical:probabilistic>
We can also decorate fulfillments with probability distributions, probabilistic fulfillment formula can then represent notions such as the probability of fulfilling certain formulas.
Take the following example where $f_a = U(0.2, 0.8)$ and $f_b = U(0.3, 0.7)$ form uniform distributions, $f_c = f_a and^0 f_b$ builds a distribution $f_c$ represented by $f_c = sqrt(f_a*f_b) | f_a ~ U(0.2, 0.8), f_b ~ U(0.3, 0.7)$.

What makes this construction especially powerful is that the power mean admits a central-limit-like theorem for each $p$, known as the generalized central limit theorem. Meaning that the distribution of the output of the power mean will converge to a generalization of normal distributions as the number of inputs increases. This family of distribution is known as the generalized normal distribution or exponential power distribution.

==== Temporal Logic Integration <chap:synthesis:future:logical:temporal>
We can also extend fulfillment logic to the temporal domain by converting classical signal temporal logic operators to their fulfillment logic counterparts. For example, the `always` operator in STL can be converted to the $and^p$ operator, and the `eventually` operator can be converted to the $or^p$ quantifier. This allows us to express temporal relationships such as "the system will always fulfill the objective of avoiding a collision" or "the system will eventually fulfill the objective of reaching a target".

==== Next steps in Formal Verification <chap:synthesis:future:logical:formal_verification>
We showed in @def:min_fulfillment_bounds a bound on the worst-case fulfillment of a composed formula. However we made no attempt to inductively apply this bound to composed formula (though it can be seen that a $not$ would flip the bound for example). Such a function would tie the inputs to  fulfillment functions with their outputs, allowing us to reason about the composition of fulfillment values. A worthwhile avenue for future research is to develop more of these bounds and achieve guarantees about the behavior of controllers that are using FPL.

=== Machine Learning Extensions <chap:synthesis:future:ml>

==== Inverse Fulfillment Learning (IFL) <chap:synthesis:future:ml:inverse_fulfillment>
Inverse Reinforcement Learning (IRL) aims to recover reward functions from observed _behavior_ $beta$, typically by learning a mapping $m: beta -> R$ such that $#`opt`_("RL")(m(beta)) tilde.eq beta$. Analogously, we can construct fulfillment formulas from expert demonstrations by learning a mapping $m: beta -> "FPL"$. Unlike traditional IRL, which often struggles with interpretability, inverse fulfillment learning can preserve semantic structure by learning individual fulfillment functions and their logical composition. This enables automatic discovery of interpretable multi-objective specifications from demonstrations—especially useful for complex behaviors like "human-like" walking, where manual specification is difficult. The resulting FPL specifications retain the semantic relationships present in expert behavior, while maintaining interpretability and robustness.

==== Loss functions as FPL <chap:synthesis:future:ml:loss_functions>
Due to the usage of the power mean, various existing loss functions used in ML can be expressed as FPL formulas. Notice that minimizing the $L_p$ norm is equivalent to minimizing $pmean(p)$ as $L_p/n^p = pmean(p)$ where n is the number of samples (a constant). As this behavior only differs when we take $p -> 0$, these losses can then be thought of in terms of logical formula, especially when the inputs are values in $[0, 1]$.

Another relation is the cross-entropy loss as it can be expressed as $- sum f_a log(f_b)$. Exponentiated it becomes $product f_b ^f_a$, this is equivalent to the FPL formula $vecand^0 f_b^f_a$. Unlike taking the log which is often used for its monotinicity property to allow for better numerical stability, we can instead use the geometric mean which will produce a value that is representative of performance allowing the composition with other losses while retaining the meaning of the range of values.

=== Connections to other fields <chap:synthesis:future:connections>

==== Game theory
The games that characterize the competition between multiple objectives can be made precise within game theoretical notions. This would allow one to study the games where the power mean is the optimal utility function to use, allowing us to reason about how the selection of the $p$ parameter affects the behavior of the optimization. For example in a multiplicative trade-off game where we build competing fulfillments $f_c_1$ and $f_c_2$ from the fulfillments of the base, uncompetitive objectives $f_u_1$ and $f_u_2$.
$ f_c_1 &= 1 - f_u_1(1-alpha f_u_2)\
  f_c_2 &= 1 - f_u_2(1-alpha f_u_1) $

You can notice that increasing $f_u_1$ increases $f_c_1$ but decreases $f_c_2$, and the opposite is true for $f_u_2$. In this case a linear utility yields optimization that causes the competing terms to diverge while a multiplicative one yields one that compromises both. This is what we consider optimizing for the $or$ vs $and$ of the objectives in the context of FPL.


==== Complexity theory
One can also study the complexity class of finding formula that specify a given behavior. A conjecture put forth here is that the hardness of solving for linear scalarization is greater than the hardness of solving for FPL formulas in a general class of problems. The intuition is that competitive dynamics cause chaotic behavior in optimizing linear scalarization, while FPL formulas can be seperately optimized then composed.

==== System architecture
The optimal spread of information that a fulfillment value can carry is a function of the operator that combines fulfilllments, for instance if $p = 1$ this forms a linear combination, implying the optimal spread of bits is linear, thus an integer representing the values between 0 and 1 can be considered optimal. However if we are combining fulfillments with $p = 0$, the optimal spread of bits is exponential, thus a floating point number with only mantissa bits representing the values between 0 and 1 can be considered optimal. This suggests that we can solve for how the circuits should be designed to optimize the spread of information.

=== Driving Real-World Adoption <chap:synthesis:future:adoption>

The other major research thrust lies in driving the framework toward widespread, reliable deployment. This requires pushing into high-stakes application domains such as *safety-critical systems*, *human-robot interaction*, and *multi-agent systems*, where the benefits of interpretable, robust control are most needed. Success in these areas, however, is contingent on building a complete ecosystem for the practitioner. This involves creating a mature toolchain that moves beyond programmatic specification to include intuitive *graphical and natural-language interfaces* that lower the barrier to entry. Complemented by sophisticated *debugging, visualization, and performance analysis tools* that build operator trust is a key component. Crucially, the entire development process must be guided by rigorous *user studies* to address the critical *human-factors* challenge of how practitioners specify intent and diagnose system behavior. Finally, this ecosystem must be validated through *long-term deployment studies* on real robots to perform thorough *failure mode analysis* and build the foundation of trust and reliability necessary for broad adoption.

== Conclusion

This thesis has presented composable fulfillment as a comprehensive solution to the intent-to-reality gap in robot learning. By systematically deconstructing the gap into its core components—encoding, optimization, and deployment—we have developed a unified framework that preserves semantic meaning at every stage.

The key insight is that the long-standing challenges in robot learning are not isolated technical flaws but symptoms of a single, deeper problem: the loss of human intent in translation. By replacing the paradigm of reward maximization with one of fulfillment satisfaction, we have provided a language (FPL) to express intent, an optimization architecture (BPG, CAPS) to achieve it, and an adaptation mechanism (Anchor Critics) to preserve it.

The empirical validation across multiple domains demonstrates the practical value of this fulfillment-centric approach, with consistent improvements in sample efficiency, specification clarity, and deployment robustness. Perhaps most importantly, this work demonstrates that the intent-to-reality gap is not an insurmountable barrier but a solvable engineering problem.

The future of artificial intelligence depends on our ability to create systems that are not only capable but also trustworthy, interpretable, and aligned with human intent. Composable fulfillments provide a principled foundation for this future, transforming the relationship between human and machine from one of frustration and unpredictability to one of clarity and confidence. As we stand at the threshold of an age of increasingly autonomous systems, the principles and methods developed in this thesis provide a path toward ensuring that these systems serve humanity's best interests, closing the gap between what objectives we intend to fulfill and how our creations learn to behave.