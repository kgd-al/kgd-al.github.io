---
title: NeuroEvolution
image: /resources/banner/ann.gif
order: 1
math: True
---

NeuroEvolution is a research field regrouping all techniques by which an Artificial Neural Network (ANN) can be made "better" via an Evolutionary approach with either direct or indirect encodings.
Better, refers to the comparison, through a (multi-objective) fitness function, of performance between individuals, either on a population or species level.

The vagueness in the definition above stems from the variety of approaches taken by researcher in the field: from the evolution weights in fixed, fully-connected topologies to the indirect encoding of emerging structures in large-scale brains.
In the context of my research, NeuroEvolution implies the evolution of *at least* the network's topology and weights.
To that end, I rely heavily on ES-HyperNEAT{% cite Risi2012 %} which is both a convoluted indirect encoding for neural networks and an evolutionary algorithm with built-in speciation features.

## Field overview

ANNs are built upon the initial definition of the formal neuron{% cite McCulloch1943 %} and its subsequent use in perceptrons.
Following the AI Winter{% cite Rosenblatt1957 Farber1962 Minsky1969 Lighthill1972 %}, they gained a renewed interest thanks to backpropagation{% cite Rumelhart1986 %}.
However, ANNs again fell into disuse into mainstream Machine Learning (ML) until the beginning of the 90's with the birth of the field of NeuroEvolution (e.g. {% cite_author Montana1989 %}) although it was not named as such right away.

In the following decade, multiple researchers led similar investigation leading to the field's rapid growth with a multitude of approaches for both the encoding and evolution{% cite Dasgupta1992 Fullmer1992 Braun1993 Mandischer1993 Zhang1993 Angeline1994 Maniezzo1994 Gruau1996 Lee1996 Opitz1997 Pujol1998 %}.
For an overview of early-stage works on NeuroEvolution refer to {% cite_author Branke1995 %} and {% cite_author Yao1999 %}.

In the early 2000's a seminal contribution was made with NEAT{% cite Stanley2002 %} (NeuroEvolution through Augmenting Topologies) which described an innovative evolutionary algorithm and a *direct* encoding for neural networks.
To solve the common problem of competing conventions, the authors introduced historical markings in their genotypes which tracked mutations by assigning them with unique identifiers.
This made it possible to implement a more robust crossover operator that used said markings to align genotypic elements before combining them.
Another advantage was the built-in speciation capabilities which also leverage the historical markings to provide a genetic distance metrics between individuals, allowing the clustering of similar individuals into independent niches.
As these individuals only compete inside their niches, innovation is more preserved than in open population where suboptimal candidates would be discarded despite their potential. 

However, as NEAT uses a direct encoding, it is not scalable to even medium-sized input/output spaces (> 100 neurons) due to the combinatorial explosion of optimizing every neuron and connection through a practically infinite phenotypic space.
A solution to that was brought on by HyperNEAT{% cite Stanley2009 %} which uses a Composite Pattern-Producing Network{% cite Stanley2007a %} (CPPN) to encode a pattern of connectivity, instead of each individual weight.
This *indirect* encoding is made possible by the CPPN, an $$ \mathbb{R}^{2n} \to \mathbb{R} $$ function mapping two coordinates in $$ \mathbb{R}^n $$ to a connection weight.
Through the combination of each internal nodes' elementary function ($$ sin(x), exp^x, |x|, ...$$) a CPPN is powerfully expressive, allowing the discovery of repetitions, symmetries or repetitions with variations.
Furthermore, as it is independent on the number of neurons, it is well suited for used in large-scale networks where direct encodings would struggle to explore efficiently such a high dimensional space.
In case of tasks where the geometry of e.g. a robot is relevant to solving more efficiently said task, the use of an indirect encoding that leverages such geometrical relationship has been found quite useful{% cite Clune2011 %}.

In most cases the CPPN is more complex than in its initial definition.
In my usual implementations it is more often $$ \mathbb{R}^{2n+2} \to \mathbb{R}^3 $$, where the two additional inputs are the euclidian distance between the two coordinates, so that the CPPN does not have to discover it by itself, and a bias, to ensure potential activation for null coordinates.
The two additional outputs are the Level Of Expression{% cite Verbancsics2011 %} (LEO) which a binary flag stating whether a connection should be made and the per-neuron bias.
In the former case, it has been traditionally assumed that under a specific connection weight threshold, the connection would be disabled and the weight scaled accordingly.
While usable, in practice it is often useful to decouple both information (weight and connection).
The latter is used to generate every neurons internal bias by querying the CPPN with the corresponding neuron's position as a source and $$ \vec 0 $$ as an output.

Finally, one major problem remained in HyperNEAT, namely that the hidden neurons had to be placed manually by the experimenter.
The obvious issue caused by this limitation is that it drastically reduces the ANNs' potential for growth as it can never have more computational power than that envisioned by the experimenter.
Through the *Evolvable Substrate*{% cite Risi2012 %} extension to HyperNEAT, the hidden neurons are instead discovered by quantization of the CPPN's patterns.
In short, areas of high variance (read complex motif) are those where hidden neurons will be instantiated.
This way, the experimenter only job is to place the input and output neurons at appropriate location, with respect to the robot's geometry, and ES-HyperNEAT would generate a (potentially) complex ANN.
One that would grow more complex as generations go by.

To conclude on this (brief) overview of the field, the inquisitive reader is referred to more recent literature reviews{% cite Stanley2019 Baldominos2020 %}.

## In my research

NeuroEvolution is central to my research lines since early 2020, and has been a personal interest for much longer.
As illustrated above, it is a subject I find fascinating by the opportunity it offers to create intelligent Artificial Life.
Not Artificial Intelligence, mind.
Autonomous, self-sufficient life forms made, not from biology, but from science.

While we quite far off that lovely objective, preliminary research into the mechanism of spontaneous self-organisation in ANNs already show promising results with respect to primitive mental states{% cite GodinDubois2021a %}, communication{% cite GodinDubois2021b %} or coordination{% cite GodinDubois2022a %}.
Thanks to their emerging properties, one can investigate a plethora of phenomenon, *if* these ANNs are faced with sufficiently complex environments and given enough evolutionqry budget{% cite GodinDubois2023 %}.

The following sections, highlight some prominent aspects of from my recent research. 

{%- include subfolders_overview.html -%}

## Personal notes

* {% cite_author Miconi2018 %} Differentiable indirect plasticity (useful?)
