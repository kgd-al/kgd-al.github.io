---
order: 11
layout: page
title: Software
permalink: /software
---

{%- assign H = "140px" -%}

The list below highlights my most prominent software contributions to Artificial Life in general.
Recent libraries/frameworks are coded in Python for maximal inter-operability while older ones are expected to be either ported or binded in the near future.

## AMaze

<div>
<img src="/resources/banner/amaze.gif" alt="amaze" width="{{H}}" align="left" hspace="2%"/>

A lightweight maze navigation task generator for sighted AI agents.
This library is meant to serve as a fast-prototyping platform to test various algorithms while being:
a) computationally cheap; b) unbounded in complexity; and c) intuitively understandable by a human.
The library works with either fully discrete perception and action spaces; fully continuous; or with continuous perceptions and discrete actions.
<br/>
Multiple investigations into its properties are detailed on its <a href="/projects/abrain.html">project</a> page, join in!
<br/>
Available as a pure-python library on
<a href="https://pypi.org/project/amaze-benchmarker/">pypi</a>.
<br/>
More information on <a href="https://amaze.readthedocs.io/">read the docs</a>.
</div>

## ABrain

<div>
<img src="/resources/banner/ann.gif" alt="abrain" width="{{H}}" align="left" hspace="2%"/>

A C++ library, with python binding, implementing the Evolvable Substrate Hyper NeuroEvolution through Augmenting Topologies (ES-HyperNEAT) algorithms.
Works, by default, on three dimensional substrates and can handle large input/output spaces.
Also provides numerous tools for visualizing both the 3D ANN (dynamically or not) and the underlying CPPN. Currently under active development, see the related <a href="/projects/abrain.html">project</a> for more details.
<br/>
Available on
<a href="https://pypi.org/project/abrain/">pypi</a>.
<br/>
More information on <a href="https://abrain.readthedocs.io/">read the docs</a>.
</div>

## Splinoids

<div>
<img src="/resources/banner/splinoids.gif" alt="splinoids" width="{{H}}" align="left" hspace="2%"/>

A C++ framework for modeling 2D robots with evolvable morphological components based on cubic splines, hence the name.
The robots are endowed with vision, touch and hearing; can locomote via two wheels and speak on multiple frequencies.
When morphologically appropriate, they also have control over each articulation allowing them to use their arms offensively or defensively.
<br/>
Available on <a href="https://github.com/kgd-al/Splinoids">github</a>.
</div>

## APOGeT

<div>
<img src="/resources/banner/apoget.gif" alt="splinoids" width="{{H}}" align="left" hspace="2%"/>

A C++ tool for producing phylogenetic trees from genealogical data.
The Automated Phylogeny Over Geological Timelines uses a (evolvable) genetic distance metric to separate species.
The underlying algorithms rely on a methaphorical membrane that is extended through genetic divergence until a child species is created from its parent.
The methology has been used for both asexual and sexual reproductions and can handle most corner cases such as hybridation from distant species.
<br/>
Available on <a href="https://github.com/kgd-al/APOGeT">github</a>.
<br/>
<a href="/publications/bib#GodinDubois2019c">Citation</a>
</div>
