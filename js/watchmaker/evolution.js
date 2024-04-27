import {Genome} from "./genome.js";
import {Config} from "./config.js";

class RNG {
    constructor(seed) {
        // LCG using GCC's constants
        this.m = 0x80000000; // 2**31;
        this.a = 1103515245;
        this.c = 12345;

        this.state = seed ? seed : Math.floor(Math.random() * (this.m - 1));
    }

    int () {
        this.state = (this.a * this.state + this.c) % this.m;
        return this.state;
    }

    random () {
        // returns in range [0,1]
        return this.int() / (this.m - 1);
    }

    nextRange (start, end) {
        // returns in range [start, end): including start, excluding end
        // can't modulu nextInt because of weak randomness in lower bits
        const rangeSize = end - start;
        const randomUnder1 = this.int() / this.m;
        return start + Math.floor(randomUnder1 * rangeSize);
    }

    choice (array) {
        return array[this.nextRange(0, array.length)];
    }
}

export class Evolver {
    constructor() {
        this.generation = 0;
        this.genomes = null;
        this.rng = new RNG(3);
    }

    reset() {
        let n = Config.sqrtPop;
        this.generation = 0;
        this.genomes = Array.from(
            {length: n*n},
            () => Genome.random(this.rng));
    }

    popSize() { return this.genomes.length; }

    genome(i) {
        return this.genomes[i];
    }

    next_gen(ids) {
        let increment = true;
        let new_genomes = null;
        if (ids.length === 1) {
            increment = ids[0] > 0;
            let parent = this.genomes[ids[0]];
            new_genomes = [parent];
            while (new_genomes.length < this.genomes.length) {
                new_genomes.push(parent.mutated());
            }
        } else {
            new_genomes = ids.map((i) => this.genomes[i]);
            while (new_genomes.length < this.genomes.length) {
                let parents = getRandomSubarray(ids, 2).map((i) => this.genomes[i]);
                let child = parents[0].crossover(parents[1]);
                if (child.data.length !== parents[0].data.length
                    || child.data.length !== parents[1].data.length)
                    throw new Error("You, evil you");
                child.mutate();
                new_genomes.push(child);
            }
        }

        this.genomes = new_genomes;
        if (increment)
            this.generation += 1;
    }
}


