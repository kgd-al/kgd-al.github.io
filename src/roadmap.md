---
order: 99
layout: page
title: Roadmap
hidden: true
permalink: /roadmap
---

Todolist:
- [ ] Research page:
  - [ ] NeuroEvolution
    - [ ] ABrain
    - [ ] VfMRI
  - [ ] Evolutionary Robotics
    - [ ] Splinoids
    - [ ] Revolve
  - [ ] Open-Ended Evolution
    - [ ] BOC
    - [ ] APOGeT
    - [ ] EDEnS
- [ ] Post for articles?
- [ ] Post for abrain v1.1

Maybe:
- [ ]  Banner:
   - [ ]  VfMRI (activation patterns of ann)

{% assign stubs = site.pages | where_exp: "page", "page.stub" %}
{% assign n_stubs = stubs | size %}
{% if n_stubs > 0 %}
{{n_stubs}} stubs:
  {% for page in stubs %}
* {{page.label | default: page.title}} [{{page.url}}]({{page.url}})
  {% endfor %} 
{% endif %}