export class Config {
    static sqrtPop = 5;
    static splines = 4;
    static initMutationRange = 0;

    static parents = 2;
    static mutationsCount = 100;
    static mutationsAmplitude = .05;

    static preset = "Incremental";
    static presets = {
        "Custom": {},
        "Incremental": {
            "initMutationRange": 0,
            "parents": 1,
            "mutationsCount": 100,
            "mutationsAmplitude": .05
        },
        "Fast": {
            "initMutationRange": .5,
            "parents": 1,
            "mutationsCount": 1,
            "mutationsAmplitude": 1
        },
        "Nuclear": {
            "initMutationRange": 1,
            "parents": 1,
            "mutationsCount": 50,
            "mutationsAmplitude": 1
        },
        "Pure crossover": {
            "initMutationRange": 1,
            "parents": 2,
            "mutationsCount": 0,
            "mutationsAmplitude": 0
        }
    }
}
