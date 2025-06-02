#import "/src/style.typ": *

Robot learning faces fundamental challenges that have hindered real-world deployment. Methods struggle with deployment failures when transferring to real environments, policy adaptation across domains, achieving control smoothness, and sample-efficient learning. This thesis's hypothesis is that these issues are affected by a crisis in expressivity. Contemporary reward functions are difficult to interpret, contain redundant terms, and exhibit poor generalization. Practitioners resort to reusing algorithm-specific reward formulations, yielding controllers overfit to particular methods, instances, and environments. This manifests as the "intent-to-reality gap"—the discrepancy between designer intention and deployed robot behavior.

These seemingly disparate challenges stem from the inherent lack of structure in existing reward and value functions. To address this, I introduce fulfillment—reconceptualizing objectives as continuous logical values to fulfill rather than scalar values to maximize. Fulfillment functions serve as semantic bridges, translating intuitive judgments like "this action is 80% as smooth as I want" into mathematical values that remain aligned with intention throughout optimization. Using generalized means as continuous logic operators, fulfillments enable semantic-preserving composition with gradient-based optimization.

This perspective allowed turning the aforementioned challenges into specification design issues such that addressing them yielded state-of-the-art results: the first RL system outperforming classical PID controllers in quadrotor deployment with 50-80% power reductions, live and robust neural network adaptation, and consistent policy search with up to 6.4× speedup across various robotic domains.


#manual_sampler(fill: accent1_gradient, width: 100%, height: 2em, samples: 100)
#manual_sampler(fill: accent2_gradient, width: 100%, height: 2em, samples: 100)
#manual_sampler(fill: accent3_gradient, width: 100%, height: 2em, samples: 100)
#manual_sampler(fill: primary_gradient, width: 100%, height: 2em, samples: 100)