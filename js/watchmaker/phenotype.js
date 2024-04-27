import {Genome} from "./genome.js"
import {Config} from "./config.js";

class Phenotype {
    static W0_RANGE = Math.PI/2;

    constructor (genome, r) {
        let n = Genome.splinesCount();
        this.bodyColor = Phenotype.color(genome, -1);
        this.colors = new Array(n);
        this.splines = new Array(n);
        for (let i=0; i<n; i++) {
            this.colors[i] = Phenotype.color(genome, i);

            function rotate_scale(x) { return x < .5 ? x : x-1; }

            let [a, b, l, dx0, dx1, dy0, dy1, w0, w1, w2] = genome.spline(i);
            a *= Math.PI;
            b = 2 * rotate_scale(b) * Math.PI;
            l *= r;
            dy0 = rotate_scale(dy0);
            dy1 = rotate_scale(dy1);
            w0 /= 2;
            w1 /= 2;
            w2 /= 2;

            let p0 = Point.fromPolar(a, r);
            let al = a + w0 * Phenotype.W0_RANGE, pl0 = Point.fromPolar(al, r);
            let ar = a - w0 * Phenotype.W0_RANGE, pr0 = Point.fromPolar(ar, r);

            let p1 = Point.fromPolar(a + b, r + l);

            let v = p1.minus(p0);
            let t = new Point(-v.y, v.x);

            let cl0 = p0.plus(v.times(dx0)).plus(t.times(dy0 * (1+w1)));
            let cl1 = p0.plus(v.times(dx1)).plus(t.times(dy1 * (1+w2)));

            let cr0 = p0.plus(v.times(dx0)).minus(t.times(dy0 * (1+w1)));
            let cr1 = p0.plus(v.times(dx1)).minus(t.times(dy1 * (1+w2)));

            this.splines[i] = {
                p0: p0, pl0: pl0, pr0: pr0, p1: p1, al: al, ar: ar,
                cl0: cl0, cl1: cl1, cr0: cr0, cr1: cr1
            }
        }
    }

    static color(genome, i) {
        let cs = (c) => 255*c;
        let [r, g, b] = genome.color(i).map(cs);
        return `rgb(${r}, ${g}, ${b})`
    }
}

export function draw (ctx, genome, size, shadowStyle) {
    let s = size/4;

    const phenotype = new Phenotype(genome, s);

    [true, false].forEach((shadow) => {
        ctx.save();

        if (shadow) {
            ctx.shadowColor = shadowStyle;
            ctx.shadowBlur = 3;
        }

        ctx.fillStyle = phenotype.bodyColor;

        ctx.beginPath();
        ctx.arc(0, 0, s, 0, 2*Math.PI, true);
        ctx.closePath();
        ctx.fill();

        for (let i=0; i<Genome.splinesCount(); i++)
            draw_spline(ctx, phenotype, s, i)

        ctx.restore();
    });
}

export function draw_svg(ctx, genome, size, shadowstyle) {
    const r = size/4;
    const phenotype = new Phenotype(genome, r);

    function element(type) {
        return document.createElementNS('http://www.w3.org/2000/svg', type);
    }
    let svg = element('svg');
    svg.setAttribute("fill", "none");
    svg.setAttribute("viewBox", `-${size/2} -${size/2} ${size} ${size}`);
    svg.setAttribute('stroke', 'black');

    let body = element("circle");
    body.setAttribute("cx", "0");
    body.setAttribute("cy", "0");
    body.setAttribute("r", r.toString());
    body.setAttribute("fill", phenotype.bodyColor);
    body.setAttribute("stroke", "none");
    svg.appendChild(body);

    const n = Genome.splinesCount();
    for (let i=0; i<n; i++) {
        [1, -1].forEach((side) => {
            let path = element("path");
            let {pl0: pl0, pr0: pr0, p1: p1,
                cl0: cl0, cl1: cl1, cr0: cr0, cr1: cr1} = phenotype.splines[i];
            pl0.y *= side;
            pr0.y *= side;
            p1.y *= side;
            cl0.y *= side;
            cl1.y *= side;
            cr0.y *= side;
            cr1.y *= side;
            path.setAttribute("fill", phenotype.colors[i]);
            path.setAttribute("stroke", "none");
            path.setAttribute("transform", "rotate(-90)");

            const sweep_flag = side == 1 ? 1 : 0;
            const pathData = [
                `M ${pl0.x} ${pl0.y}`,
                `C ${cl0.x} ${cl0.y} ${cl1.x} ${cl1.y} ${p1.x} ${p1.y}`,
                `C ${cr1.x} ${cr1.y} ${cr0.x} ${cr0.y} ${pr0.x} ${pr0.y}`,
                `A ${r} ${r} 0 0 ${sweep_flag} ${pl0.x} ${pl0.y}`

            ]
            // console.log("svg path data:", pathData);
            path.setAttribute('d', pathData.join(" "));
            svg.appendChild(path);
        });
    }

    return svg;
}

function draw_spline(ctx, phenotype, r, i) {
    ctx.save();
    ctx.rotate(-Math.PI/2);

    // console.log(color(genome, i));
    // console.log(genome.spline(i));

    ctx.fillStyle = phenotype.colors[i];
    let {p0: p0, pl0: pl0, pr0: pr0, p1: p1, al: al, ar: ar,
         cl0: cl0, cl1: cl1, cr0: cr0, cr1: cr1} = phenotype.splines[i];

    function draw_once() {
        ctx.beginPath();
        ctx.moveTo(pl0.x, pl0.y);
        ctx.bezierCurveTo(cl0.x, cl0.y, cl1.x, cl1.y, p1.x, p1.y);
        ctx.bezierCurveTo(cr1.x, cr1.y, cr0.x, cr0.y, pr0.x, pr0.y);
        ctx.arc(0, 0, r, ar, al, false);
        // console.log("canvas path data:", [
        //     [pl0.x, pl0.y],
        //     [cl0.x, cl0.y, cl1.x, cl1.y, p1.x, p1.y],
        //     [cr1.x, cr1.y, cr0.x, cr0.y, pr0.x, pr0.y],
        // ]);
        ctx.closePath();
        ctx.fill();
    }
    draw_once();

    function debug_draw(flag) {
        if (flag & 0x1) {
            ctx.strokeStyle = "red";
            ctx.setLineDash([2, 2])
            ctx.beginPath();
            ctx.moveTo(p0.x, p0.y);
            ctx.lineTo(p1.x, p1.y);
            ctx.stroke();
        }

        if (flag & 0x2) {
            ctx.strokeStyle = "green";
            ctx.setLineDash([3, 1])
            ctx.beginPath();
            ctx.moveTo(pl0.x, pl0.y);
            ctx.lineTo(p1.x, p1.y);
            ctx.lineTo(pr0.x, pr0.y);
            ctx.closePath();
            ctx.stroke();
        }

        if (flag & 0x4) {
            ctx.strokeStyle = "blue";
            ctx.setLineDash([1, 3]);
            ctx.beginPath();
            [[pl0, cl0], [cl1, p1], [pr0, cr0], [cr1, p1]].forEach(([a, b]) => {
                ctx.moveTo(a.x, a.y);
                ctx.lineTo(b.x, b.y);
            });
            ctx.stroke();
        }
    }

    ctx.scale(1, -1);
    draw_once();

    ctx.shadowBlur = 0;
    // debug_draw(7);

    ctx.restore();
}

class Point {
    constructor(x, y) {
        this.x = x;
        this.y = y;
    }

    static fromPolar(a, r) {
        return new Point(r * Math.cos(a), r * Math.sin(a));
    }

    minus(other) {
        return new Point(this.x - other.x, this.y - other.y);
    }

    plus(other) {
        return new Point(this.x + other.x, this.y + other.y);
    }

    times(value) {
        return new Point(this.x * value, this.y * value);
    }
}
