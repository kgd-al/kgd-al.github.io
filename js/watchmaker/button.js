import {Config} from "./config.js"
import {draw as draw_phenotype} from "./phenotype.js"

const zoomSVG = new Path2D(
    "M1024 672v64q0 13-9.5 22.5T992 768H768v224q0 13-9.5 22.5T736 1024h-64q-13 0-22.5-9.5T640 992V768H416q-13" +
    " 0-22.5-9.5T384 736v-64q0-13 9.5-22.5T416 640h224V416q0-13 9.5-22.5T672 384h64q13 0 22.5 9.5T768 416v224h224q13" +
    " 0 22.5 9.5t9.5 22.5m128 32q0-185-131.5-316.5T704 256T387.5 387.5T256 704t131.5 316.5T704 1152t316.5-131.5T1152" +
    " 704m512 832q0 53-37.5 90.5T1536 1664q-54 0-90-38l-343-342q-179 124-399 124q-143 0-273.5-55.5t-225-150t-150-225T0" +
    " 704t55.5-273.5t150-225t225-150T704 0t273.5 55.5t225 150t150 225T1408 704q0 220-124 399l343 343q37 37 37 90");

export class Button {
    ctx;

    x;
    y;
    s;

    hovered;
    down;
    zoomed;

    static path;
    static overlayPath;

    static fillStyle;
    static strokeStyle;
    static hoverStyle;

    static shadowOffset = 3;
    static shadowBlur = 5;
    static margin = Button.shadowOffset + Button.shadowBlur;
    static zoomIconSize = 0.1;

    constructor(ctx, ix, genotypes) {
        this.ctx = ctx;
        this.ix = ix;
        this.genotypes = genotypes;
        this.hovered = this.down = this.zoomed = false;
    }

    setGeom(x, y, s) {
        this.x = x;
        this.y = y;
        this.s = s;
    }

    draw() {
        let ctx = this.ctx;
        ctx.save()
        ctx.translate(this.x, this.y);
        ctx.clearRect(-1, -1, this.s + 2, this.s + 2);

        ctx.fillStyle = Button.fillStyle;
        ctx.fill(Button.path);

        if (this.hovered || this.down) {
            ctx.save();
            ctx.fillStyle = Button.hoverStyle;
            ctx.globalAlpha = .5;
            if (this.hovered) ctx.fill(Button.path);
            if (this.down) ctx.fill(Button.path);
            ctx.restore();
        }

        ctx.save()
        ctx.clip(Button.path);
        ctx.globalCompositeOperation = "source-atop";
        // ctx.strokeStyle = "transparent";
        ctx.translate(-this.s, -this.s);
        ctx.globalAlpha = .8;
        ctx.shadowColor = "white";
        ctx.shadowOffsetX = ctx.shadowOffsetY = this.s + Button.shadowOffset;
        ctx.shadowBlur = Button.shadowBlur;
        ctx.stroke(Button.path);
        ctx.shadowColor = "black";
        ctx.shadowOffsetX = ctx.shadowOffsetY = this.s - Button.shadowOffset;
        ctx.stroke(Button.path);
        ctx.restore();

        // ctx.stroke(Button.path);

        ctx.restore()

        ctx.save();
        ctx.translate(this.x + this.s / 2, this.y + this.s / 2);
        draw_phenotype(
            ctx, this.genotypes.genome(this.ix),
            this.s - Button.margin, Button.strokeStyle);
        ctx.restore();

        ctx.save();
        ctx.translate(this.x+Button.margin, this.y+Button.margin);
        ctx.globalAlpha = .5;
        const scale = Button.zoomIconSize * this.s / 1664;
        ctx.scale(scale, scale);

        ctx.fillStyle = Button.strokeStyle;
        ctx.fill(zoomSVG);
        ctx.restore();
    }

    draw_zoomed(){
        let ctx = this.ctx;
        let w = ctx.canvas.width;
        let h = ctx.canvas.height;
        let s = Math.min(w, h);
        ctx.save();
        ctx.fillStyle = Button.fillStyle;
        ctx.fill(Button.overlayPath);
        ctx.stroke(Button.overlayPath);

        ctx.translate(.5 * w, .5 * h);
        draw_phenotype(ctx, this.genotypes.genome(this.ix), s, Button.fillStyle);
        ctx.restore();
    }

    inside(x, y) {
        return this.x <= x && x <= this.x + this.s
            && this.y <= y && y <= this.y + this.s;
    }

    mouse_moved(x, y) {
        let s = 2 * this.s * Button.zoomIconSize;
        if (x < s && y < s) {
            this.zoomed = true;
            this.draw_zoomed();
        } else if (this.zoomed) {
            this.zoomed = false;
        }
    }

    hover_enter() {
        this.hovered = true;
        this.draw();
    }

    hover_leave() {
        this.hovered = false;
        this.draw();
    }

    mouse_down() {
        if (Config.parents === 1)
            this.down = true;
        else
            this.down = !this.down;
        this.draw();
    }

    mouse_up() {
        if (Config.parents === 1)
            this.down = false;
        this.draw();
    }

    static update_path(s, bs) {
        Button.path = new Path2D();
        Button.path.roundRect(0, 0, bs, bs, [10]);
        Button.overlayPath = new Path2D();
        Button.overlayPath.roundRect(.01*s, .01*s, .98*s, .98*s, [10]);
    }

    static updateStyles(styles) {
        Button.fillStyle = styles.getPropertyValue("--minima-background-color");
        Button.hoverStyle = styles.getPropertyValue("--minima-brand-color");

        let pad = (str) => {
            return (new Array(2).join('0') + str).slice(-str.length);
        };
        let inv = (i) => {
            return pad((255 - parseInt(Button.fillStyle.slice(i, i+2), 16)).toString(16));
        };
        Button.strokeStyle = "#" + inv(1) + inv(3) + inv(5);

    }
}
