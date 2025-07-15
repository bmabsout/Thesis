#import "/src/style.typ": *

With advances in real-time cyber-physical systems we can now run sophisticated neural network controllers entirely aboard mobile robots. Yet when practitioners train reinforcement-learning (RL) policies destined for real-world deployment they stumble on four recurring problems: (1) scalar rewards are notoriously hard to design; (2) policies that excel in simulation often fail on real robots, causing crashes and oscillations among other issues; (3) fine-tuning on real data causes catastrophic forgetting; and (4) popular RL algorithms remain sample-inefficient. These shortcomings are reflected in a wide "intent-to-reality gap"---the discrepancy between designer intent and deployed robot behaviour.

We examine and bridge traditionally underexplored subparts of these gaps by replacing opaque rewards with continuous, bounded fulfillment values that can be composed logically. Statements such as "80% smooth and 30% fast" become mathematically precise, differentiable targets that stay aligned with intent throughout optimisation. This fulfillment-centric perspective unifies reward design, policy regularisation, and live adaptation.

By treating human intent as first-class fulfilment values, threading them 
through learning algorithms and carefully managing the resource-constrained 
embedded stack, we achieve: (i) the first RL attitude controller to 
outperform a tuned PID on a racing quadrotor; (ii) 50–80% reductions in power consumption relative to Neuroflight, with broadly generalizable gains across environments; (iii) robust on-the-fly policy adaptation via our 
SwaNNFlight architecture; and (iv) up to 5$times$ better sample efficiency 
than Soft Actor Critic on standard Gymnasium benchmark tasks.




// #manual_sampler(fill: accent1_gradient, width: 100%, height: 2em, samples: 100)
// #manual_sampler(fill: accent2_gradient, width: 100%, height: 2em, samples: 100)
// #manual_sampler(fill: accent3_gradient, width: 100%, height: 2em, samples: 100)
// #manual_sampler(fill: primary_gradient, width: 100%, height: 2em, samples: 100)