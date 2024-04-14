---
order: 98
layout: page
hidden: true
title: Site gallery
permalink: /gallery
---

<div class="gallery" id="gallery-div">
</div>
<div class="checkbox">
    <input type="checkbox" id="duplicates"/>
    <label for="duplicates">Show duplicates?</label>
</div>

<script>
    imgs = [
        {%- for img in site.data.__generated.images -%}
            ["{{img.file}}", "{{img.src}}"],
        {% endfor %}
    ];
    cb = document.getElementById("duplicates");
    cb.addEventListener("change", evt => { do_work() });

    function shuffleArray(array) {
        for (let i = array.length - 1; i > 0; i--) {
            const j = Math.floor(Math.random() * (i + 1));
            [array[i], array[j]] = [array[j], array[i]];
        }
    }
    function uniq_fast(a) {
        var seen = {};
        var out = [];
        var len = a.length;
        var j = 0;
        for(var i = 0; i < len; i++) {
             var item = a[i];
             var key = item[1];
             if(seen[key] !== 1) {
                   seen[key] = 1;
                   out[j++] = item;
             } else {
                console.log("Filtered out", item);
             }
        }
        return out;
    }
    function do_work(){
        shuffleArray(imgs);
        console.log(cb.checked);
        if (!cb.checked) {
            _imgs = uniq_fast(imgs);
        } else {
            _imgs = imgs;
        }
        console.log(_imgs);
        holder = document.getElementById("gallery-div");
        holder.innerHTML = "";
        for (let item of _imgs) {
            holder.innerHTML += `
                <span class="responsive-gallery-item">
                    <a href="${item[0]}">
                        <img class="responsive-gallery-image" src="${item[1]}"/>
                    </a>
                </span>
            `;
        }
        console.log(holder);
    }
    
    do_work();

</script>
