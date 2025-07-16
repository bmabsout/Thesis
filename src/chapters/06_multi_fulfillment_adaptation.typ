#import "../commands.typ": *
#import "../style.typ": *

= Adaptation as Specification Composition <chap:adaptation_anchors>

Throughout this thesis, we have developed a fulfillment-centric framework that transforms how we think about robot learning. We have shown how to encode complex intentions as fulfillments, compose them using FPL, and incorporate universal behavioral objectives. Yet one critical challenge remains: how do we ensure that the rich behavioral specification we carefully designed in simulation survives the transition to reality?

This chapter addresses the final piece of the intent-to-reality gap by recognizing a fundamental insight: *adaptation is not a transfer problem, but a specification problem*. When policies catastrophically forget their training during real-world deployment, it's not because adaptation techniques are flawed---it's because we're optimizing an incomplete specification that fails to capture what we actually want. This realization leads naturally to a solution that composes specifications from both simulation and reality, preventing forgetting while enabling adaptation.

== The Hidden Specification Problem in Adaptation <chap:adaptation_anchors:spec_problem>


=== Typical Adaptation Pipeline <chap:adaptation_anchors:spec_problem:typical>
When practitioners adapt a simulation-trained policy to reality, the typical mental model is straightforward:
1. Train a policy in simulation to satisfy a specification (reward function)
2. Fine-tune it on real data to handle dynamics differences
3. Deploy the adapted policy

This framing treats adaptation as a technical problem of adjusting to new dynamics. But this view is incomplete and leads directly to catastrophic forgetting.

=== Missing Specification <chap:adaptation_anchors:spec_problem:missing>

Consider what the standard adaptation process actually optimizes. When we fine-tune a policy $pi_("sim")$ on real-world data, we're implicitly asking it to maximize:

$ J_("adapt")(pi) = #text(size: 15pt,expect)_(
  #stack_math(
    [$s_0 tilde cal(I)_("real")$],
    [$action(a_t) tilde pi(state(s_t))$],
    [$state(s_(t+1)) tilde TT_("real")(state(s_t), action(a_t))$]
  )
) [sum_(t=0)^infinity gamma^t R(state(s_t), action(a_t))] $

$cal(I)_("real")$ defines the real-world distribution of initial states and $TT_("real")$ defines the distribution of real-world transitions, therefore it is severely limited by event rarity. A drone might spend 90% of its time hovering or flying gentle trajectories, even though we trained it to handle aggressive aerobatics in simulation. 

This reveals the core problem: *we're optimizing an incomplete specification*. The reward function $R$ is just one component---the full specification includes the distribution of tasks, state initializations, and scenarios we encounter. In simulation, we deliberately crafted this distribution to include diverse tasks, edge cases, and emergency maneuvers. Notice that these design choices are part of the specification, encoded in the learned Q-values. But during real-world adaptation, the optimization only sees the narrow slice of reality we can safely collect, missing the full behavioral specification we intended.

=== Catastrophic Forgetting as Specification Failure <chap:adaptation_anchors:spec_problem:forgetting>

From this perspective, catastrophic forgetting isn't a mysterious phenomenon---it's the predictable result of optimizing the wrong objective. When a drone forgets how to handle aggressive commands after adapting on gentle flights, it's not a failure of the learning algorithm. It's successfully optimizing exactly what we asked: performance on the limited real-world distribution.

The problem is that we failed to specify that we still care about the full behavioral repertoire from simulation. This is a *specification gap*, not a technical limitation.

== Composing Specifications <chap:adaptation_anchors:composing>


Once we recognize adaptation as a specification problem, the path forward becomes clear. We need to specify that the adapted policy should satisfy *both*:
1. Performance on the real-world distribution (adaptation)
2. Performance on the simulation distribution (preservation)

This isn't about mixing data or averaging models. It's about recognizing that we have two distinct specifications that we must include in our optimization scheme. The fulfillment framework developed in this thesis gives us exactly the tools we need to build such a specification.

=== Formalizing the Derived Specification <chap:adaptation_anchors:composing:dual>

As established in our taxonomy of the intent-to-reality gap in @chap:intent_to_reality, value functions are *derived specifications* (@def:derived_specs) that encode how good certain behavior is, affected by both the reward function and the specific trajectory distribution encountered. This insight is crucial for understanding adaptation and why catastrophic forgetting occurs.

*The Simulation Specification*: The specification in simulation is far richer than just a reward function. It encompasses the reward function $R_("sim")$, the distribution of tasks (what goals appear and how often), the state initialization distribution (where episodes begin), and the dynamics model forming the environment.

The value function learned in simulation, $f"Q"_("sim")$, is a derived specification that integrates *all* of these design choices. It encodes how good behaviors are in the simulation context—combining our reward specification with the intentionally crafted distribution of experiences. When we choose to initialize episodes with aggressive maneuvers 30% of the time, or include emergency recovery scenarios, these aren't implementation details—they become part of the derived specification encoded in $f"Q"_("sim")$.

*The Reality Specification*: Similarly, the real-world creates its own derived specification encompassing the same reward function $R$ (typically), the naturally occurring task distribution (mostly gentle flights), the constrained initialization distribution (safe starting states), and the true dynamics.

The value function $f"Q"_("real")$ learned on real data is a different derived specification—it encodes how good behaviors are in the real-world context. The limited variety isn't a bug—it accurately reflects what the robot will mostly encounter. But this derived specification is incomplete for our true intent.

Both derived specifications are valid. Both encode important aspects of what we want. The question is how to compose them.

=== Why Standard Approaches Fail <chap:adaptation_anchors:composing:fail>

Before showing the solution, let's understand why naive approaches fail:

*Mixing Replay Buffers*: One might try mixing simulation and real experiences during training. But this violates the Markov assumption—the domain origin becomes a hidden variable affecting transitions. Moreover, balancing the mixture is ad-hoc. How much simulation data is "enough" to prevent forgetting? There's no principled answer.

*Reward Engineering*: One might try adding penalty terms to preserve simulation behaviors. But this just pushes the problem around—now you need to hand-tune penalties and weights, losing the semantic clarity we've worked to achieve.

*Alternating Training*: Training alternately on each domain prevents consistent value estimates and can cause oscillation between behaviors rather than true composition.

== Applying Fulfillment-Centric Thinking <chap:adaptation_anchors:solution>

=== Derived Specifications Guide Our Solution <chap:adaptation_anchors:solution:clarity>

Understanding value functions as derived specifications (as introduced in @chap:intent_to_reality) makes the solution clear. Each value function combines:
- A primary specification (the reward function $R$)  
- A context specification (the data distribution, dynamics, task variety)

This produces a derived specification that encodes how good behaviors are in that specific context.

In our case, $f"Q"_("sim")$ encodes how good behaviors are in the rich simulation context while $f"Q"_("real")$ encodes how good behaviors are in the limited real-world context.

Neither derived specification is complete for our true intent. The simulation has the behavioral diversity we designed but wrong dynamics. Reality has correct dynamics but incomplete behavioral coverage. We need both.

=== Applying FPL to Adaptation <chap:adaptation_anchors:solution:fpl>

Once we recognize we have two valid derived specifications, the fulfillment framework provides a principled way to compose them:

$ phi_("adapt") = f"Q"_("sim") and^p f"Q"_("real") $

This formula precisely captures our intent: satisfy *both* derived specifications. The conjunction ensures high value only when performing well according to both contexts—maintaining the comprehensive behavioral repertoire from simulation while adapting to real dynamics.

=== The Power of Compositional Thinking <chap:adaptation_anchors:solution:power>

This compositional approach has several key advantages. First, it provides *semantic clarity* by directly stating what we want—good performance in both domains—without obscure weights or mixing ratios. Second, it ensures *no forgetting by design* since poor performance on either specification directly reduces the overall value, preventing the policy from forgetting simulation behaviors without penalty. Finally, it enables *principled trade-offs* through the choice of conjunction operator (e.g., geometric mean with $p=0$), which determines how we balance the specifications with clear semantic meaning, unlike arbitrary weights.

=== Implementation: The Emergence of Anchor Critics <chap:adaptation_anchors:solution:anchor>

To implement this compositional specification, we need to maintain separate value estimates for each domain. This naturally leads to an architecture with:

- A critic trained on simulation data (the "anchor" that preserves our intent)
- A critic trained on real data (adapting to actual dynamics)
- An actor that optimizes the FPL composition of both

We call the simulation critic an "anchor" because it anchors the policy to the comprehensive behavioral specification we designed. But crucially, this isn't a new technique we invented—it's the natural implementation of treating adaptation as specification composition.
#algorithm(title: [Compositional Adaptation via Dual Critics])[
  Given: Simulation-trained policy $pi_("sim")$ and critic $Q_("sim")$
  
  *Adaptation Phase:*
  1. Initialize $Q_("real")$ to learn real-world values
  2. Keep $Q_("sim")$ as the anchor (updating it on simulation data)
  3. For each update:
     - Update $Q_("real")$ on real transitions
     - Update $Q_("sim")$ on simulation transitions  
     - Update $pi$ to maximize: $f"Q"_("sim")(state(s),action(pi(state(s)))) and^0 f"Q"_("real")(state(s),action(pi(state(s))))$
] <algo:comp-adapt>

=== Theoretical Guarantees from Composition <chap:adaptation_anchors:solution:guarantees>

By framing adaptation as FPL composition, we inherit the theoretical guarantees from @chap:encoding_intentionality:

From the *Minimum Fulfillment Bound* (@thm:min-fulfillment-bound): Achieving high composed value guarantees minimum performance on both specifications. We can't achieve high overall fulfillment while failing on either domain.

From *Semantic Preservation* (@thm:semantic-preservation): Improving performance on either specification monotonically improves the overall objective. There are no hidden trade-offs where getting better at reality makes us worse overall.

== Empirical Validation: Composition in Practice <chap:adaptation_anchors:validation>

=== Understanding Distributional Mismatch <chap:adaptation_anchors:validation:mismatch>

To validate that catastrophic forgetting is indeed a specification problem, we first tested in controlled environments where only the task distribution changed:

#figure(
  table(
    columns: 3,
    align: center,
    [*Environment*], [*Simulation Tasks*], [*Real-World Tasks*],
    [Reacher-v4], [Targets within 0.2m radius], [Targets within 0.1m radius],
    [Pendulum-v0], [Balance at +10°], [Balance at -10°],
    [LunarLander-v2], [High gravity (10 m/s²)], [Low gravity (2 m/s²)]
  ),
  caption: [Controlled experiments with identical dynamics but different task distributions. This isolates the effect of distributional mismatch from dynamics changes.]
)

The Reacher environment provides the clearest demonstration. Despite *identical dynamics*, policies fine-tuned on the restricted target distribution catastrophically forgot how to reach distant targets. This confirms that forgetting stems from optimizing an incomplete specification, not from technical adaptation challenges.

=== The Cost of Missing Specifications <chap:adaptation_anchors:validation:cost>

#let StoT(withPsi: false) = [S#text(size:0.4em, box(rotate(90deg, $triangle$))+(if withPsi {place(text(size: 1.3em, $psi$), dx: -1.3em, dy: -2.45em)}))T]

#figure(
  image("/figures/sim2sim_violins.svg", width: 100%),
  caption: [Comparitive violin plots showing the difference of the distribution of performance of the three polices $pi_"S"$ (middle violins), the policy trained on the source domain S,  $pi_#StoT()$ the policy trained on the source domain S and then fine tuned to the target domain T (left violins), and $pi_#StoT(withPsi: true)$ the policy trained on S and then fine tuned to T using anchor critics (right violins). Arrows indicate how the agents perform after fine tuning, with red indicating a loss of performance and green showing improvement. We observe catastrophic forgetting with standard adaptation versus preservation with compositional specification.]
) <fig:composition_results>

Standard adaptation shows severe performance degradation on the original tasks—not because the algorithm failed, but because we never specified that we cared about preserving them. The compositional approach maintains performance on both domains, validating our thesis.

=== Real-World Validation: Quadrotor Control <chap:adaptation_anchors:validation:quadrotor>

The most compelling evidence comes from real quadrotor experiments where both dynamics and distributional shifts occur:

#figure(
  image("/figures/with_vs_without_ac.svg", width: 100%),
  caption: [Real-world adaptation results. Standard adaptation (red) shows dangerous error spikes when encountering rare aggressive commands. Compositional adaptation (blue) maintains safety while improving smoothness, demonstrating successful dual specification satisfaction.]
)

During real flights, safety constraints meant the drone mostly performed gentle maneuvers. Standard adaptation quickly forgot how to handle aggressive commands—when they occasionally occurred, errors spiked dangerously. This isn't surprising: we optimized for the limited real distribution without specifying that aggressive maneuvering capability should be preserved.

The compositional approach succeeded because it correctly specified our actual intent: adapt to reality *while preserving* the full behavioral repertoire from simulation.

=== Quantitative Results <chap:adaptation_anchors:validation:results>

#figure(
  table(
    columns: 3,
    align: center,
    [*Metric*], [*Before Adaptation*], [*After Compositional Adaptation*],
    [Power (A)], [13.7 ± 8.47], [7.24 ± 3.97],
    [Tracking (°/s)], [12.55 ± 12.22], [14.13 ± 5.21],
    [Smoothness], [12.6 ± 0.98], [5.85 ± 0.96]
  ),
  caption: [Compositional adaptation achieves 50% power reduction through improved smoothness while maintaining tracking performance across the full operational envelope.]
)

== Integration with Universal Behavioral Fulfillments <chap:adaptation_anchors:ubf>

As discussed in @chap:ubo, real robotic systems often have additional universal requirements beyond task performance. Using the compositional nature of FPL, we can seamlessly integrate a criteria for smoothness:

$ phi_("complete") = (f"Q"_("sim") and^0 f"Q"_("real")) and^0 f_("smoothness") $

This single formula captures the complete specification: maintain simulation capabilities, adapt to reality, and learn smooth control to maximize power efficiency. Each component has clear meaning, and their composition is principled.

=== The Full Pipeline Realized <chap:adaptation_anchors:complete:pipeline>

With compositional adaptation, we complete the intent-to-reality pipeline:

1. *Intent to Specification*: Encode complex objectives as fulfillments (@chap:encoding_intentionality)
2. *Specification to Behavior*: Optimize policies using FPL composition (@chap:encoding_intentionality)  
3. *Simulation to Reality*: Preserve intent through compositional adaptation (this chapter)

At each stage, we maintain semantic clarity by treating objectives as specifications to be fulfilled rather than rewards to be maximized.

=== Limitations and Extensions <chap:adaptation_anchors:complete:limitations>

While compositional adaptation effectively prevents catastrophic forgetting, some challenges remain. First, the approach assumes the simulation specification captures important behaviors. Poor simulation design cannot be overcome by composition alone. Second, anchors can limit the ability for the policy to perform optimally in reality as it is limited by performing well in the simulation as well, learning a sort of common denominator behavior. Third, maintaining multiple critics increases memory and computation, though this is often manageable on modern hardware.

== Summary <chap:adaptation_anchors:summary>

This chapter completes our framework for bridging the intent-to-reality gap by recognizing that adaptation is fundamentally a specification problem. When policies catastrophically forget their training, it's not because our algorithms are broken—it's because we failed to specify that we care about preserving those behaviors.

By applying the fulfillment framework to compose specifications from both simulation and reality, we arrive at a principled solution that prevents forgetting while enabling adaptation. The resulting "anchor critics" aren't a clever trick but the natural implementation of compositional specification.

This final piece demonstrates the power of the fulfillment-centric view: by treating objectives as specifications to be composed rather than rewards to be maximized, we can solve long-standing problems in robot learning through semantic clarity rather than technical complexity. The complete pipeline—from encoding intent to composing specifications to adapting to reality—provides a principled path from human intentions to robust robot behaviors.