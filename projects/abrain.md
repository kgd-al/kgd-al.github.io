---
title: ABrain
order: 2
image: /resources/banner/ann.gif
---

[ABrain](/software#abrain) is a C++ library with Python bindings implementing the encoding of ES-HyperNEAT.
Its main purpose is to give straightforward access to an expressive genetic space for the manipulation of large-scale neural networks.
From the experimenter, it only requires the specification on a robot's inputs and outputs: the topology *and* the functionality are emergent properties.

Currently, abrain is solely maintained by me and, as such, only a subset of the targeted features are available.
The list of planned improvements is:
* Removing templating in C++ CPPNs
* Allowing for 2D ANNs 
  * Tricky because of branching visualization
* Adding historical markings
* Adding crossover
* Integrating VfMRI 
* Adding built-in evolutionary algorithms:
  * or at least links with existing libraries

Feel free to contact me to participate in the development.
