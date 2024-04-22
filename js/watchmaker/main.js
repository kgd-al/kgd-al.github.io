import {Button} from './button.js';
import {Genome} from './genome.js';

const N = 4;
const S = 4;

let canvas = document.getElementById("canvas")
const ctx = canvas.getContext("2d");
const styles = window.getComputedStyle(canvas);
ctx.strokeStyle = styles.borderColor;

Button.updateStyles(styles);

let controls_html = document.getElementById("controls")

let buttons = [];
let hoveredButton = null;

let controls = new Map();

function make_controls(){
    let c = controls_html;
    function input(type, id, text, config) {
        console.log(`Created input ${type}, id=${id} with text ${text}`)
        c.innerHTML += "<div>";
        switch (type) {
            case "button":
                c.innerHTML += `<input type="${type}" id="${id}" value="${text}">`;
                break;
            case "number":
                c.innerHTML += `<label for="${id}">${text}</label>`;
                c.innerHTML += `<input type="${type}" id="${id}" ${config}/>`;
                break;
        }
        c.innerHTML += "</div>";
        controls.set(id, document.getElementById(id))
    }
    input("button", "b_restart", "Restart");
    input("number", "n_splines", "Splines",
        `min="0" max="4" value="${S}" style="width: 3em"`);
}

function init() {
    make_controls()
    Genome.splines = parseInt(controls.get("n_splines").value);

    for (let i = 0; i < N; i++) {
        for (let j = 0; j < N; j++) {
            let b = new Button(i * N + j)
            buttons.push(b);
        }
    }

    resized()
}

function draw(){
    ctx.strokeStyle = styles.borderColor;
    // ctx.strokeRect(1, 1, s-1, s-1);
    buttons.forEach(b => b.draw(ctx))
}

function resized() {
    // let size = Math.min(window.innerWidth, window.innerHeight)
    let size = canvas.parentElement.offsetWidth
    canvas.style.width = size + "px";
    canvas.width = size;
    canvas.style.height = size + "px";
    canvas.height = size;

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

    Button.update_path(bs)

    // canvas.style.backgroundColor = "red";
    draw()
}

window.onresize = resized
init()

window.matchMedia('(prefers-color-scheme: dark)')
    .addEventListener('change',({ matches }) => {
        Button.updateStyles(styles);
        buttons.forEach((b) => b.draw(ctx));
    });

function event_button(event) {
    let x = event.pageX - (canvas.clientLeft + canvas.offsetLeft);
    let y = event.pageY - (canvas.clientTop + canvas.offsetTop);

    let button = null;
    for (let i=0; i<buttons.length && !button; i++)
        if (buttons[i].inside(x, y))
            button = buttons[i];
    return button;
}

canvas.addEventListener('mousemove', (event) => {
    let button = event_button(event);

    if (hoveredButton && hoveredButton != button) {
        hoveredButton.hover_leave(ctx)
        hoveredButton = null;
    }

    if (button && !button.hovered) {
        button.hover_enter(ctx);
        hoveredButton = button;
    }
});

canvas.addEventListener('mouseleave', () => {
    if (hoveredButton) {
        hoveredButton.hover_leave(ctx);
        hoveredButton = null;
    }
});

canvas.addEventListener('click', (event) => {
    let b = event_button(event);
    if (b) b.clicked();
});

canvas.addEventListener('mousedown', (event) => {
    let b = event_button(event);
    if (b) b.mouse_down(ctx);
});

canvas.addEventListener('mouseup', (event) => {
    let b = event_button(event);
    if (b) b.mouse_up(ctx);
});
