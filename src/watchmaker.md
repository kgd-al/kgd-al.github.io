---
title: Watchmaker
layout: page
order: 5
permalink: /watchmaker
stub: True
---

<style>
.post-content {
    min-width: min(90vw, 90vh);
    max-height: min(90vw, 90vh);
}
canvas {
    width: 100%;
    height: 100%;
    display: block;
}
</style>

<div style="float: left; width: calc(100% - 10em)">
<canvas id="canvas">
Some text
</canvas>
</div>
<div id="controls" style="float: right; width: 9em; padding: .5em;">
</div>

<script type="module" src="/js/watchmaker/main.js">
</script>
