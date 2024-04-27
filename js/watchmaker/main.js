import {Button} from './button.js';
import {Genome} from './genome.js';
import {Config} from './config.js';
import {draw_svg} from './phenotype.js';
import {Evolver} from './evolution.js';

let canvas = document.getElementById("canvas")
const ctx = canvas.getContext("2d");
const styles = window.getComputedStyle(canvas);
ctx.strokeStyle = styles.borderColor;

Button.updateStyles(styles);

let contextMenu = document.getElementById("context-menu")
let controls_html = document.getElementById("controls")

let evolver = new Evolver()
let buttons = [];
let hoveredButton = null;

let controlItems = new Map();
let controlToConfig = new Map();
let configToControl = new Map();

function make_controls(){
    let c = controls_html;
    function input(id, config = {}, field = null, connect = true) {
        // console.log("Configuring input", id)
        let item = document.getElementById(id);
        controlItems.set(id, item);
        if (config) {
            Object.entries(config).forEach(([k, v]) => item.setAttribute(k, v));
        }
        if (field) {
            controlToConfig.set(id, field);
            configToControl.set(field, id);

            const value = Config[field];
            if (connect)
                item.addEventListener("change", (e) => {
                   console.log(`Value changed for ${id} from Config.${field}=${value} to ${e.target.value}`);
                   Config[field] = parseFloat(e.target.value);
                   console.log(">>", Config[field]);
                });
            item.setAttribute("value", value);
        }
    }
    input("s_preset");
    input("b_restart");
    input("f_complexity",
          {min: 0, max: 1, step: .01}, "initMutationRange", false);
    input("n_splines",
          {min: 0, max: 4}, "splines", false);
    input("n_buttons",
          {min: 2, max: 5}, "sqrtPop", false);
    input("n_parents",
          {min: 1, max: .5*Config.sqrtPop**2},
          "parents");
    input("f_mutations_amplitude",
          {min: 0, max: 2, step: .05},
          "mutationsAmplitude");
    input("n_mutations_count",
          {min: 1, max: 100},
          "mutationsCount");

    function destructive_event(id, field, f = null) {
        document.getElementById(id).addEventListener("change", (e) => {
            let v = e.target.value;
            if (evolver.generation === 0 ||
                window.confirm(`Restart evolution with ${field} = ${v}?`)) {
                Config[field] = parseFloat(v);
                if (f) f(e.target.value, e);
                reset();

                console.log(`Restarted evolution with ${field} = ${v}`)
            }
        });
    }

    document.getElementById("b_restart").addEventListener("click", () => {
        if (evolver.generation === 0 ||
            window.confirm(`Restart evolution?`)) {
                reset();
                console.log("Restarted evolution")
        }
    });
    destructive_event("f_complexity", "initMutationRange");
    destructive_event("n_splines", "splines", Genome.setSplinesCount);
    destructive_event("n_buttons", "sqrtPop", (v) => {
        create_buttons();
        reset();
    });

    let presets = document.getElementById("s_preset");
    Object.entries(Config.presets).forEach(([k, v]) => {
        let opt = document.createElement("option");
        opt.text = k;
        presets.add(opt);
    })
    destructive_event("s_preset", "preset", (v, e) => {
        // console.log("Switching to preset", v);
        Config.preset = e.target.options[e.target.selectedIndex].text;
        use_preset();
        reset();
    });

    presets.selectedIndex = Array.from(presets.options).findIndex((opt) => opt.text == Config.preset);
    use_preset()
}

function create_buttons() {
    buttons.length = 0;
    let N = Config.sqrtPop;
    for (let i = 0; i < N; i++) {
        for (let j = 0; j < N; j++) {
            let b = new Button(ctx, i * N + j, evolver);
            buttons.push(b);
        }
    }
}

function init() {
    make_controls()

    Genome.setSplinesCount(parseInt(controlItems.get("n_splines").value));

    Config.sqrtPop = parseInt(controlItems.get("n_buttons").value);
    evolver.reset();
    create_buttons();

    fullscreen();
    resized();
}

function use_preset(){
    Object.entries(Config.presets[Config.preset]).forEach(([k, v]) => {
        Config[k] = v;
        controlItems.get(configToControl.get(k)).value = v;
    });
}

function reset(){
    evolver.reset();
    create_buttons();
    resized();
}

function draw(){
    ctx.clearRect(0, 0, ctx.canvas.width, ctx.canvas.height);
    ctx.strokeStyle = styles.borderColor;
    // ctx.strokeRect(1, 1, s-1, s-1);
    buttons.forEach(b => b.draw(ctx))
}

function fullscreen() {
    let promise = canvas.requestFullscreen();
    console.log(promise)
}

function contextMenuOn(target, x, y) {
    contextMenu.style.display = "block";
    contextMenu.style.left = x + "px";
    contextMenu.style.top = y + "px";
    contextMenu.target = target;
}

function contextMenuOff() {
    contextMenu.style.display = "none";
    contextMenu.target = null;
}

function contextMenuEvent(id) {
    console.log("Context menu event", id, "with target", contextMenu.target);
    const size = 512;
    let ix = contextMenu.target.ix;
    let svg = draw_svg(ctx, evolver.genomes[ix], size, "black");
    let blob = new Blob(
        [new XMLSerializer().serializeToString(svg)],
        {type: 'image/svg+xml'})
    const blobURL = window.URL.createObjectURL(blob);

    // let dbgImg = new Image();
    // dbgImg.src = blobURL;
    // dbgImg.style.width = dbgImg.style.height = `${size}px`;
    // dbgImg.style.border = "1px solid red";
    // document.body.prepend(dbgImg)

    const link = document.createElement("a");
    link.href = blobURL;
    link.setAttribute('download', `splinoid-${evolver.generation}-${ix}.svg`);
    document.body.appendChild(link);
    link.click();
    link.remove();
    window.URL.revokeObjectURL(blobURL);
}

function resized() {
    let size = Math.min(
            .9*window.innerWidth - canvas.nextElementSibling.offsetWidth - 5,
        .9*window.innerHeight)
    // let size = Math.min(canvas.parentElement.offsetWidth, canvas.parentElement.offsetHeight);
    canvas.style.width = size + "px";
    canvas.width = size;
    canvas.style.height = size + "px";
    canvas.height = size;

    const N = Config.sqrtPop;
    let m = 10;
    let bs = (size - m * (N+1)) / N;

    for (let i=0; i<N; i++) {
        for (let j=0; j<N; j++) {
            let ix = i * N + j;
            buttons[ix].setGeom(
                j * bs + (j + 1) * m,
                i * bs + (i + 1) * m,
                bs);
        }
    }

    Button.update_path(size, bs)

    draw()
}

function update_generation_label() {
    let l_gen = document.getElementById("l_generation");
    l_gen.innerHTML = `Generation ${evolver.generation}`;
}

function new_generation(ixs) {
    evolver.next_gen(ixs);
    buttons.forEach((b) => b.down = false);
    draw();
    update_generation_label();
}

init()
window.addEventListener("resize", resized);

window.matchMedia('(prefers-color-scheme: dark)')
    .addEventListener('change',({ matches }) => {
        Button.updateStyles(styles);
        buttons.forEach((b) => b.draw(ctx));
    });

function event_location(e) {
    return [e.pageX - (canvas.clientLeft + canvas.offsetLeft), e.pageY - (canvas.clientTop + canvas.offsetTop)];
}

function event_button(event) {
    let [x, y] = event_location(event);

    let button = null;
    for (let i=0; i<buttons.length && !button; i++)
        if (buttons[i].inside(x, y))
            button = buttons[i];
    return button;
}

canvas.addEventListener('mousemove', (event) => {
    let button = event_button(event);

    if (hoveredButton && hoveredButton !== button) {
        const wasZoomed = hoveredButton.zoomed;
        hoveredButton.hover_leave();
        hoveredButton = null;
        if (wasZoomed) draw();
    }

    if (button) {
        if (!button.hovered) {
            button.hover_enter();
            hoveredButton = button;
        }

        let [x, y] = event_location(event);
        const wasZoomed = button.zoomed;
        button.mouse_moved(x - button.x, y - button.y);
        if (wasZoomed && !button.zoomed) draw();
    }
});

canvas.addEventListener('mouseleave', () => {
    if (hoveredButton) {
        const wasZoomed = hoveredButton.zoomed;
        hoveredButton.hover_leave();
        if (wasZoomed) draw();
        hoveredButton = null;
    }
});

canvas.addEventListener('click', (event) => {
    contextMenuOff();
    let b = event_button(event);
    if (!b) return;
    if (Config.parents === 1)
        new_generation([b.ix]);
    else {
        let parents = buttons.filter((b) => b.down).map((b) => b.ix);
        if (parents.length === Config.parents)
            new_generation(parents);
    }
});

canvas.addEventListener('mousedown', (event) => {
    if (event.button !== 0) return;
    let b = event_button(event);
    if (b) b.mouse_down();
});

canvas.addEventListener('mouseup', (event) => {
    if (event.button !== 0) return;
    let b = event_button(event);
    if (b) b.mouse_up();
});

canvas.addEventListener("contextmenu", (event) => {
    event.preventDefault();
    let b = event_button(event);
    if (b) {
        let [x, y] = [event.pageX, event.pageY];
        contextMenuOn(b, x, y + 4);
    } else
        contextMenuOff();
})

window.addEventListener("click", (e) => {
    console.log("window click event");
    contextMenuOff();
})

Array.from(contextMenu.getElementsByTagName("li")).forEach((i) => {
    console.log(i);
    i.addEventListener("click", (e) => {
        contextMenuEvent(e.target.id);
    })
})

// contextMenu.target = buttons[0];
// contextMenuEvent("save");
