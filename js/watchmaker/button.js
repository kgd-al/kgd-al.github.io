import {Genome} from "./genome.js"
import {draw as draw_phenotype} from "./phenotype.js"

export class Button {
    genome;

    x;
    y;
    s;

    hovered;
    down;

    static path;

    static fillStyle;
    static hoverStyle;

    constructor(ix) {
        this.ix = ix;
        this.genome = new Genome();
        this.hovered = this.down = false;
    }

    setGeom(x, y, s) {
        this.x = x;
        this.y = y;
        this.s = s;
    }

    draw(ctx) {
        ctx.save()
        ctx.translate(this.x, this.y);
        ctx.clearRect(-1, -1, this.s+2, this.s+2);

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
        ctx.shadowOffsetX = ctx.shadowOffsetY = this.s + 3;
        ctx.shadowBlur = 5;
        ctx.stroke(Button.path);
        ctx.shadowColor = "black";
        ctx.shadowOffsetX = ctx.shadowOffsetY = this.s - 3;
        ctx.stroke(Button.path);
        ctx.restore();

        // ctx.stroke(Button.path);

        ctx.restore()

        ctx.save();
        ctx.translate(this.x + this.s / 2, this.y + this.s / 2);
        draw_phenotype(ctx, this.genome, this.s, Button.fillStyle);
        ctx.restore();
    }

    inside(x, y) {
        return this.x <= x && x <= this.x + this.s
            && this.y <= y && y <= this.y + this.s;
    }

    clicked() {
        console.log("Button", this.ix, "clicked");
    }

    hover_enter(ctx) {
        this.hovered = true;
        this.draw(ctx);
    }

    hover_leave(ctx) {
        this.hovered = false;
        this.draw(ctx);
    }

    mouse_down(ctx) {
        this.down = true;
        this.draw(ctx);
    }

    mouse_up(ctx) {
        this.down = false;
        this.draw(ctx);
    }

    static update_path(s) {
        Button.path = new Path2D();
        Button.path.roundRect(0, 0, s, s, [10]);
    }

    static updateStyles(styles) {
        Button.fillStyle = styles.getPropertyValue("--minima-background-color")
        Button.hoverStyle = styles.getPropertyValue("--minima-brand-color")
    }
}
