---
order: 98
layout: page
hidden: true
title: Site gallery
permalink: /gallery
---

<div class="checkbox">
    <input type="checkbox" id="duplicates"/>
    <label for="duplicates">Show duplicates?</label>
</div>
<div class="gallery" id="gallery-div">
</div>

<script type="text/javascript" src="/js/gallery.js">
    [
        {%- for img in site.data.__generated.images -%}
            ["{{img.file}}", "{{img.src}}"]
            {%- if forloop.last == false -%}
            ,
            {%- endif -%}
        {% endfor %}
    ]
</script>
