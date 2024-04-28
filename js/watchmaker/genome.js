import {Config} from "./config.js";

export class Genome {
    data;

    static #fields_per_spline = NaN;
    static #fields_per_color = NaN;
    static #splines_fields = NaN;
    static #colors_fields = NaN;

    static SplineFields = Object.freeze({
        alpha: 0,
        beta: 1,
        length: 2,
        dx0: 3, dx1: 4,
        dy0: 5, dy1: 6,
        w0: 7, w1: 8, w2: 9,
    });
    static #splinesFieldsArray = Object.keys(Genome.SplineFields);

    static Color = Object.freeze({
        r: 0, g: 1, b: 2
    });

    constructor(data){
        this.data = data;
    }

    static random(random){
        return new Genome(
            Array.from(
                {length: this.#splines_fields + this.#colors_fields},
                () => random() * Config.initMutationRange));
    }

    mutate() {
        for (let i=0; i<Config.mutationsCount; i++) {
            let ix = Math.floor(Math.random() * this.data.length);
            let v = this.data[ix]
            this.data[ix] = Math.max(
                0,
                Math.min(
                    v + gaussianRandom(0, Config.mutationsAmplitude),
                    1));
            // console.log(`${ix} (${this.fieldToString(ix)}) ${v} >> ${child.data[i]}`);
        }
    }

    mutated(){
        let child= new Genome([...this.data]);
        child.mutate();
        return child;
    }

    crossover(other) {
        let ix = Math.floor(Math.random() * (this.data.length-2)) + 1;
        return new Genome(this.data.slice(0, ix).concat(other.data.slice(ix, other.data.length)));

    }

    fieldToString(ix) {
        if (ix < Genome.#colors_fields) {
            return `C[${Math.floor(ix/Genome.#fields_per_color)}].${"RGB"[ix%Genome.#fields_per_color]}`;
        } else {
            ix -= Genome.#colors_fields;
            return `S[${Math.floor(ix/Genome.#fields_per_spline)}]`
                +  `.${Genome.#splinesFieldsArray[ix%Genome.#fields_per_spline]}`;
        }
    }

    toString(){
        return JSON.stringify(this.data);
    }

    spline(i) {
        let n = Genome.#fields_per_spline, ix = Genome.#colors_fields + i*n;
        return this.data.slice(ix, ix+n);
    }

    color(i) {
        let n = Genome.#fields_per_color, ix = (i+1)*n;
        return this.data.slice(ix, ix+n);
    }

    static splinesCount() {
        return Config.splines;
    }

    static setSplinesCount(n) {
        Config.splines = n;
        Genome.#fields_per_spline = Object.keys(Genome.SplineFields).length;
        Genome.#fields_per_color = Object.keys(Genome.Color).length;
        Genome.#splines_fields = n * Genome.#fields_per_spline;
        Genome.#colors_fields = (n + 1) * Genome.#fields_per_color;
    }

}

// Standard Normal variate using Box-Muller transform.
// Credit: https://stackoverflow.com/a/36481059/5946661
function gaussianRandom(mean=0, stdev=1) {
    const u = 1 - Math.random(); // Converting [0,1) to (0,1]
    const v = Math.random();
    const z = Math.sqrt( -2.0 * Math.log( u ) ) * Math.cos( 2.0 * Math.PI * v );
    // Transform to the desired mean and standard deviation:
    return z * stdev + mean;
}
