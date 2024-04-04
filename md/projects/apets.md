---
layout: research_item
title: Artificial Pets
image: /resources/apets/diagram.png
order: 1
image-width: 100%
image-hide: true
---

Creating artificial agents that can exhibit emotional and social intelligence for human interaction is an open challenge currently tackled through top-down approaches.
In this project, we instead aim to do so incrementally, by exploiting the analogy with domestic animals: autonomous agents we create a harmonious relation with through mutual efforts and understanding.

This project addresses two complementary research questions:

* How to combine NeuroEvolution and Reinforcement Learning to automatically produce artificial brains that can adapt, especially when interacting with humans?
* How to get "natural" interaction, through a top-bottom approach, similar to what is seen between humans and domestic animals

For the first question, the goal is to produce large-scale (about 1K inputs) neural networks automatically without much human input.
To that end we use the ES-HyperNEAT encoding {% cite Risi2012 %} bypassing the usually time-consuming task of topology tweaking required by Deep Learning (DL).
Furthermore, as the robots morphologies are meant to change during evolution, it also precludes the need to do transfer learning.

For natural interaction, the objective is to promote human-machine interaction with another tack than that of expert AI.
On the one hand, we want to study how collaboration can emerge, meaning that we should introduce as little bias as possible.
On other hand, these artificial life-forms should be autonomous in the same sense that domestic animals are.
To approach that natural interaction we would, initially, leverage simple communication channels such as blinking lights or simple sounds.

![Interactive evolution for artificial domestic agents]({{page.image}})

The figure above, describes the cycle interactive evolution with its multiple nested loops.
First, we start we the usual evolution loop with the added twist that some learning occurs to ensure that the agents show some degree of adaptability.
Regularly, a pre-selection is performed on the current population to show a promising subset to the human agent.
The result of their selection can then either be directly used to guide evolution towards desirable regions of the genetic space or, more infrequently, to assemble a physical robot.
In the latter case, the instantiated agent would interact with the human on whatever task is currently investigated.
Following that interaction, either the results are used to further drive evolution or the agent is considered successful and ready for deployment.

To make the whole process practical, modular robots will serve as the backbone of the evolutionary protocol, specifically those of the [revolve](https://github.com/ci-group/revolve2) platform {% cite Hupkes2018 %}.
In latter cycles of the project, the assembly step should be fully automated as with {% cite Angus2023 %}. 

While first and foremost concerned with the study of emotional and social intelligence, this project is also applicable to a broad context of interactions that do not require expert knowledge but, instead, harmonious cooperation {% cite Akata2020 Pianca2022a %}:
* Soft monitoring both at home and in hospitals
* Evaluation in serious games 
* Reduction of observer bias
