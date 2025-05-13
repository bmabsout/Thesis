#import "../lib_cv.typ": *

#let behavioral = "behavioral retention"
#let resource = "resource efficiency"

= Published Results


== Foundations: How to Train Your Quadrotor @how_to_train_your_quadrotor <how-to-train-your-quadrotor>
Our journey began with a fundamental challenge in robotics: achieving reliable low-level control of quadrotor attitude that could outperform classical PID controllers. While PID controllers were straightforward to use, they couldn't learn from experience or adapt to the environment. Previous attempts to apply reinforcement learning to this problem faced two critical issues: poor transfer from simulation to reality (with only one in dozens of trained agents proving controllable on real drones) and unstable, non-smooth control leading to excessive power consumption and hardware wear.

Through careful analysis, we identified a fundamental limitation in how objectives were being specified: the standard practice of linear reward composition required constant manual tuning based on observed behavior, leading to brittle policies that failed to capture true behavioral objectives. This led us to develop RE+AL, which introduced multiplicative reward composition as an alternative that better preserved the intent of each objective, improving #behavioral @def-retention through more robust policy learning.

The results were transformative. We achieved the first successful application of reinforcement learning to outperform classical PID controllers on quadrotor attitude control. The approach yielded a 10× reduction in training time, dropping from 9 hours to under 50 minutes. Additionally, we achieved significant improvements in control signal quality, reducing oscillations from 330Hz to 130Hz while maintaining low tracking errors of 4.2 deg/s.

These improvements directly addressed #resource @def-resource through reduced training time and better control efficiency.

This early work revealed a crucial insight that would shape my subsequent research: the gap between practitioner intent and realized behavior wasn't just about improving simulators—it was about how we specified objectives to the learning system. This realization led me to develop the concepts of intent-to-behavior and intent-to-reality gaps, and the principles of Expressive Reinforcement Learning.

== Conditioning for Action Policy Smoothness (CAPS) @caps <CAPS>
A critical but often unaddressed challenge in deploying learned policies to real robots is the prevalence of oscillatory control responses. While deep reinforcement learning enables training control policies for complex dynamical systems, these policies often exhibit problematic behaviors detrimental to system integrity. These oscillations manifest as:
- Potential hardware failures due to sustained stress
- Visible physical system oscillations affecting performance
- Increased power consumption and overheating from high-frequency control signals

The challenge is particularly acute in continuous control domains, where controller responses can vary infinitely within acceptable output limits. While we can help shape behavior using reward engineering, we identified that certain objectives - like smoothness - can be directly encoded into the policy optimization process itself. This led to a fundamental insight: by explicitly specifying these objectives through policy regularization, we could work in conjunction with reward signals to shape the desired outcomes.

Our Conditioning for Action Policy Smoothness (CAPS) addressed this by directly shaping the neural network's mapping from states to actions through two complementary objectives, implemented as regularization terms:
1. *Temporal smoothness*: Actions should maintain similarity with previous actions to ensure smooth transitions in controller outputs over time
2. *Spatial smoothness*: Similar states should map to similar actions, providing robustness against measurement noise and modeling uncertainties

We formalize these smoothness objectives through regularization terms:

==== Temporal Smoothness Loss
$ loss_"temporal" = 1/T sum_(t=1)^T ||#action($a_t$) - #action($a_(t+1)$)||_2 $ <temporal>
where $loss_"temporal"$ measures the average change in actions over time, encouraging smooth transitions between consecutive control outputs.

==== Spatial Smoothness Loss
$ loss_"spatial" = expect_(s_1,s_2)[(||#action($a_1$) - #action($a_2$)||_2)/(||#state($s_1$) - #state($s_2$)||_2)] $ <spatial>
where $loss_"spatial"$ measures the average Lipschitz constant of the policy, ensuring similar states map to similar actions.

The total loss combines these terms with the policy objective:

==== CAPS Total Loss
$ loss_"total" = loss_"policy" + alpha loss_"temporal" + beta loss_"spatial" $ <caps-loss>
where $alpha$ and $beta$ are hyperparameters controlling the trade-off between objectives.

Key results include:
- 80% reduction in power consumption while maintaining task performance
- 96% improvement in policy roughness see @def-roughness
- Significant reduction in training time
- Successful flight-worthy controllers using simple reward structures

This work demonstrated a key principle: some objectives are better expressed directly through policy structure rather than through reward engineering. By directly encoding smoothness objectives into the policy structure, CAPS addresses simulation-to-reality transfer @def-sim-to-real by ensuring consistent behavior in reality and #resource @def-resource through reduced power consumption and hardware stress.

=== Impact
The success of CAPS in achieving smooth control has led to a large body of subsequent works that have been built on our notions of policy smoothness and on similar derivative notions. This exemplifies how well-structured specifications is desired and can simultaneously address multiple aspects of the intent-to-reality gap, from resource constraints to behavioral requirements.

== Efficient Control through Actor-Critic Asymmetry @honey_shrunk_actor <actor-critic-asymmetry>
While CAPS addressed energy efficiency through smoother actions, the computational cost of neural network inference remained a significant barrier to deployment. This led us to question a fundamental implicit assumption in actor-critic methods: that actors and critics should share similar neural network architectures.

A key insight emerged when we examined the different objectives these networks need to satisfy: the critic must develop rich representations to understand both system dynamics and reward structures, while the actor simply needs to learn a mapping that maximizes value. This suggested that the representational power needed to satisfy the actor's objectives might be much smaller than what's needed for the critic's objectives - yet the standard practice was to use identical architectures for both components. We thus developed a binary-search based algorithm that automatically searches for the smallest actors that can solve the tasks at hand.

Through systematic evaluation across multiple actor-critic algorithms and environments, we demonstrated that:
- Actors can be reduced by up to 99% in size while maintaining performance
- Average reduction of 77% in model parameters across tasks
- Successful validation across 4 popular actor-critic algorithms
- Consistent results across 9 different environments with varying dynamics

This work revealed a fundamental asymmetry in the representational requirements needed to satisfy actor versus critic objectives. This insight directly addresses #resource @def-resource by dramatically reducing computational requirements. 