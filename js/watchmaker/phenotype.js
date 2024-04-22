import {Genome} from "./genome.js"

export function draw (ctx, genome, size, fillStyle) {
    let s = size/6;

    // console.log("Drawing genome", genome.toString());

    [true, false].forEach((shadow) => {
        ctx.save();

        if (shadow) {
            let pad = (str) => {
                return (new Array(2).join('0') + str).slice(-str.length);
            };
            let inv = (i) => {
                return pad((255 - parseInt(fillStyle.slice(i, i+2), 16)).toString(16));
            };
            let shadowStyle= "#" + inv(1) + inv(3) + inv(5);
            console.log(fillStyle, shadowStyle);
            ctx.shadowColor = shadowStyle;
            ctx.shadowBlur = 5;
        }
        // ctx.translate(size/2, size/2);
        // ctx.

        const c = genome.c_data;
        ctx.fillStyle = color(genome,-1);

        ctx.beginPath();
        ctx.arc(0, 0, s, 0, 2*Math.PI, true);
        ctx.closePath();
        ctx.fill();

        for (let i=0; i<Genome.splines; i++)
            draw_spline(ctx, genome, s, i)

        ctx.restore();
    });
}

function color(genome, i) {
    let cs = (c) => 255*c;
    let [r, g, b] = genome.color(i).map(cs);
    return `rgb(${r}, ${g}, ${b})`
}

function draw_spline(ctx, genome, r, i) {
    const W0_RANGE = Math.PI/2;

    ctx.save();
    ctx.rotate(-Math.PI/2);

    ctx.fillStyle = color(genome, i);

    let [a, b, l, dx0, dx1, dy0, dy1, w0, w1, w2] = genome.spline(i);
    a *= Math.PI;
    b = (2*b - 0.5) * Math.PI;
    l = 1;
    l *= r;
    dy0 -= .5
    dy1 -= .5
    w0 /= 2;
    w1 /= 2;
    w2 /= 2;

    let p0 = Point.fromPolar(a, r);
    let al = a + w0 * W0_RANGE, pl0 = Point.fromPolar(al, r);
    let ar = a - w0 * W0_RANGE, pr0 = Point.fromPolar(ar, r);

    let p1 = Point.fromPolar(a + b, r + l);

    let v = p1.minus(p0);
    let t = new Point(-v.y, v.x);

    let cl0 = p0.plus(v.times(dx0)).plus(t.times(dy0 * (1+w1)));
    let cl1 = p0.plus(v.times(dx1)).plus(t.times(dy1 * (1+w2)));

    let cr0 = p0.plus(v.times(dx0)).minus(t.times(dy0 * (1+w1)));
    let cr1 = p0.plus(v.times(dx1)).minus(t.times(dy1 * (1+w2)));

    function draw_once() {
        ctx.beginPath();
        ctx.moveTo(pl0.x, pl0.y);
        ctx.bezierCurveTo(cl0.x, cl0.y, cl1.x, cl1.y, p1.x, p1.y);
        ctx.bezierCurveTo(cr1.x, cr1.y, cr0.x, cr0.y, pr0.x, pr0.y);
        ctx.arc(0, 0, r, ar, al, false);
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
    // debug_draw(7);

    ctx.scale(1, -1);
    draw_once();

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
