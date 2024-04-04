---
layout: research_item
title: NeuroEvolution
image: /resources/banner/ann.gif
order: 1
stub: True
---

NeuroEvolution is a research field regrouping all techniques by which an Artificial Neural Network (ANN) can be made "better" via an Evolutionary approach with either direct or indirect encodings.
Better, refers to the comparison, through a (multi-objective) fitness function, of performance between individuals, either on a population or species level.

The vagueness in the definition above stems from the variety of approaches taken by researcher in the field: from the evolution weights in fixed, fully-connected topologies to the indirect encoding of emerging structures in large-scale brains.
In the context of my research, NeuroEvolution implies the evolution of *at least* the network's topology and weights.
To that end, I rely heavily on ES-HyperNEAT{% cite Risi2012 %} which is both a convoluted indirect encoding for neural networks and an evolutionary algorithm with built-in speciation features.

Historically, the field of NeuroEvolution dates back to the beginning of the 90' e.g. with {% cite Montana1989 %} although it was not named as such right away.
In the following decade, multiple researchers led similar investigation leading to the field's rapid growth with a multitude of approaches for both the encoding and evolution {% cite Dasgupta1992 Fullmer1992 Braun1993 Mandischer1993 Zhang1993 Angeline1994 Maniezzo1994 Gruau1996 Lee1996 Opitz1997 Pujol1998 %}

* Full range: {% cite Dasgupta1992 Fullmer1992 Braun1993 Mandischer1993 Zhang1993 Angeline1994 Maniezzo1994 Gruau1996 Lee1996 Opitz1997 Pujol1998 %}
* Multiple ranges: {% cite Dasgupta1992 Fullmer1992 Braun1993 Zhang1993 Angeline1994 Maniezzo1994 Lee1996 Opitz1997 Pujol1998 %}
* Solitary items: {% cite Dasgupta1992 Braun1993 Zhang1993 Maniezzo1994 Lee1996 Pujol1998 %}
{% cite Dasgupta1992 Fullmer1992 Braun1993 Zhang1993 Maniezzo1994 Lee1996 Opitz1997 Pujol1998 %}
* Pairs: {% cite Dasgupta1992 Fullmer1992 Mandischer1993 Zhang1993 Angeline1994 Gruau1996 Opitz1997 Pujol1998 %}
* Reversed: {% cite Pujol1998 Opitz1997 Lee1996 Gruau1996 Maniezzo1994 Angeline1994 Zhang1993 Mandischer1993 Braun1993 Fullmer1992 Dasgupta1992 %}
* Reverse with holes: {% cite Pujol1998 Lee1996 Gruau1996 Angeline1994 Zhang1993 Mandischer1993 Fullmer1992 Dasgupta1992 %}

first building block was NEAT{% cite Stanley2002 %} (NeuroEvolution through Augmenting Topologies) which described the initial evolutionary algorithm and a *direct* encoding for neural networks.
The crossover and built-in speciation was made possible by the use of historical markings, unique identifiers assigned to mutations that allowed tracking during mating.

[//]: # (* {% cite McCulloch1943 %} Neuron)

[//]: # (* {% cite Rosenblatt1957 %} Report on perceptrons)

[//]: # (* {% cite Farber1962 %} Perceptrons)

[//]: # (* {% cite Minsky1969 %} XOR Book)

[//]: # (* {% cite Lighthill1972 %} AI report)

[//]: # (* {% cite Rumelhart1986 %} Backpropagation)

[//]: # (* {% cite Montana1989 %} 1st neuroevolution?)

{% cite Baldominos2020 %} A timeline of NeuroEvolution with a bias for CNNs

Todolist of articles to introduce:
* {% cite Dasgupta1992 %} sGA (Structured Genetic Algorithm)
* {% cite Fullmer1992 %} no name, marker-based chromosomes
* {% cite Braun1993 %} ENZO (Evolutiver Netzwerk–Optimierer), bounded topology
* {% cite Mandischer1993 %} Densely indirect encoding
* {% cite Zhang1993 %} BGP, Occam's razor
* {% cite Angeline1994 %} GNARL (GeNeralized Acquisition of Recurrent Links)
* {% cite Maniezzo1994 %} Uses GA-simplex
* {% cite Gruau1996 %} Cellular (neuron) growth with evolved program
* {% cite Lee1996 %} OON? linked-list representation
* {% cite Opitz1997 %} Regent
* {% cite Pujol1998 %} PDGP+, double representation
* {% cite Stanley2002c %} NEAT, not the first but a massive contribution
 
* {% cite Branke1995 %} Big field review, also a lot about backpropagation
* {% cite Yao1999 %} Another field review
 
* {% cite Stanley2007a %} CPPN
* {% cite Stanley2009 %} HyperNEAT,
* {% cite Verbancsics2011 %} LEO for hyperNEAT
* {% cite Clune2011 %} Indirect encoding is generally better (but not always)
* {% cite Risi2012 %} ES-HyperNEAT

* {% cite Stanley2019 %} Field overview

* {% cite Miconi2018 %} Differentiable indirect plasticity (read!)

* {% cite GodinDubois2023 %}

{%- include subfolders_overview.html -%}
