export class Genome {
    s_data;
    c_data;

    static splines = 0;

    static SplineFields = Object.freeze({
        alpha: 0,
        beta: 1,
        length: 2,
        dx0: 3, dx1: 4,
        dy0: 5, dy1: 6,
        w0: 7, w1: 8, w2: 9,
    });

    static Color = Object.freeze({
        r: 0, g: 1, b: 2
    });

    constructor(){
        this.s_data = Array.from(
            {length: Genome.splines_fields(Genome.splines)},
            () => Math.random());
        this.c_data = Array.from(
            {length: Genome.colors_fields(Genome.splines)},
            () => Math.random());
    }

    toString(){
        return JSON.stringify({splines: this.s_data, colors: this.c_data});
    }

    spline(i) {
        let n = Genome.fields_per_spline(), ix = i*n;
        return this.s_data.slice(ix, ix+n);
    }

    color(i) {
        let n = Genome.fields_per_color(), ix = (i+1)*n;
        return this.c_data.slice(ix, ix+n);
    }

    static fields_per_spline(){ return Object.keys(Genome.SplineFields).length;    }
    static fields_per_color(){  return Object.keys(Genome.Color).length;           }
    static splines_fields(n_splines) {  return n_splines * Genome.fields_per_spline();      }
    static colors_fields(n_splines) {   return (n_splines + 1) * Genome.fields_per_color(); }
}
