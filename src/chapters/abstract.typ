#import "/src/style.typ": *

With advances in real-time cyber-physical systems we can now run sophisticated neural network controllers entirely on-board mobile robots. Yet when practitioners train reinforcement-learning (RL) policies destined for real-world deployment they stumble on four recurring problems: (1) scalar rewards are notoriously hard to design; (2) policies that excel in simulation often oscillate or crash on real robots; (3) fine-tuning on real data causes catastrophic forgetting; and (4) popular RL algorithms remain sample-hungry. These shortcomings are reflected in a wide "intent-to-reality gap"---the discrepancy between designer intent and deployed robot behaviour.

We bridge this gap by replacing opaque rewards with continuous, bounded fulfillment values that can be composed logically. Statements such as "80% smooth and 30% fast" become mathematically precise, differentiable targets that stay aligned with intent throughout optimisation. This fulfillment-centric view unifies reward design, policy regularisation, and live adaptation within a single framework.

By treating human intent as first-class fulfilment values, threading them through learning algorithms and carefully managing the resource-constrained embedded stack, we achieve: (i) the first RL attitude controller to outperform a tuned PID on a racing quadrotor; (ii) 50–80% cuts in power consumption; (iii) robust on-the-fly policy adaptation via our SwaNNFlight architecture; and (iv) up to 5$times$ faster learning than Soft Actor Critic on standard Gymnasium benchmark tasks.


// #manual_sampler(fill: accent1_gradient, width: 100%, height: 2em, samples: 100)
// #manual_sampler(fill: accent2_gradient, width: 100%, height: 2em, samples: 100)
// #manual_sampler(fill: accent3_gradient, width: 100%, height: 2em, samples: 100)
// #manual_sampler(fill: primary_gradient, width: 100%, height: 2em, samples: 100)