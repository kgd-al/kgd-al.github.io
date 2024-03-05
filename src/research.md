---
order: 1
layout: page
title: Research
permalink: /research/
---

{% assign items = site.data.banner | sort: 'date' %}
{%- for item in items -%}

{% assign page_name = "/research/PAGE.md" | replace: "PAGE", item.name | downcase %}
{% assign page = site.pages | where_exp: "item", "item.path contains page_name" | first %}
{% assign desc = page.content | strip_html | newline_to_br | split: "<br />" %}

<h3>{{item.desc}}</h3>

<div>
<img src="{{baseurl}}{{item.src}}" alt="{{item.name}}" width="20%" align="left" hspace="2%"/>

{% if page %}
<p>
{{desc[0]}}
<br />
<a href="{{page.url}}">Read more</a>
</p>
{% else %}
Under construction
{% endif %}

<div>
<div style="clear: both"></div>

{% endfor %}

