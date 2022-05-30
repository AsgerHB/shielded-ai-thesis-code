import os
import re

uppaaldir = "/home/asger/Documents/Files/AAU/10.Semester/uppaal/uppaal-4.1.20-stratego-10-beta2-linux64"



def clear_results():
    header = "Experiment;Runs;(Death costs 1000) Average cost;Probability of death;Expected Interventions;(Death costs 100) Average cost;Probability of death;Expected Interventions;(Death costs 10) Average cost;Probability of death;Expected Interventions"
    print(header)
    os.system(f"echo '{header}' > Results.csv")



def append_results(results_list):
    # Pad the list so that it has 11 elements
    if len(results_list) < 11:
        results_list += [''] * (11 - len(results_list))
    
    results_csv = ";".join(results_list)
    print(results_csv)
    os.system(f"echo '{results_csv}' >> Results.csv")

pattern = re.compile("mean=([\d.]+)")



def run_experiment(experiment, model, queries, runs):
    resultsdir = f"Results/{experiment}/{runs}Runs" if runs != None else f"Results/{experiment}"
    runs = runs or 0
    os.system(f"mkdir -p {resultsdir}")
    
    # Command to run UPPAAL verifier
    command = f"{uppaaldir}/bin/verifyta --epsilon 0.001 --max-iterations 1 --good-runs {runs} --total-runs {runs} --runs-pr-state {runs} {model} {queries}"
    print(f"        Running: {command}")

    queryresults = f"{resultsdir}/{experiment}.queryresults.txt"

    # Save the query so we know what we just ran
    os.system(f"cat {queries} > {queryresults}")
    # Run the command and save append it to the queryresults file.
    os.system(f"{command} >> {queryresults}")

    # Do regex on the queryresults and save the mean values using append_results.
    csvline = [experiment, str(runs)]
    with open(queryresults, "r") as f:
        for line in f:
            csvline += pattern.findall(line)
    append_results(csvline)



# Move the strategies into ther correct folder. 
# Can't be done in the run_experiment step since I need the unshielded strategies for the post-shielding experiment.
def cleanup_strategies( experiment, model):
    resultsdir = f"Results/{experiment}/{runs}Runs"
    os.system(f"mv Results/*.strategy.json {resultsdir}")



if __name__ == "__main__":
    clear_results()
    os.system("rm -rd Results/*")

    # No learning occurs in the Layabout model, so it is only run once.
    run_experiment( experiment = "Layabout",
                    model = "BB__ShieldedLayabout.xml",          # shield_enabled = true; layabout = true
                    queries = "NoStrategyEvaluate.q",    # Run the three queries without a strategy.
                    runs = None)

    # The number of runs in it runs. The models they have more learning with more runs. Am tierd.
    for runs in [1500, 3000, 6000]:
        run_experiment( experiment = "NoShield",
                        model = "BB__Unshielded.xml",    # shield_enabled = false
                        queries = "TrainSaveEvaluate.q", # Train a strategy, save it, then evaluate it.
                        runs = runs)

        run_experiment( experiment = "PreShielded",
                        model = "BB__Shielded.xml",      # shield_enabled = true
                        queries = "LoadEvaluate.q",      # Load the previous strategy, then evaluate it.
                        runs = runs)

        cleanup_strategies( experiment = "NoShield", model = "BB__Unshielded.xml")

        run_experiment( experiment = "PostShielded",
                        model = "BB__Shielded.xml",      # shield_enabled = true
                        queries = "TrainSaveEvaluateSingle.q", # Train a strategy, save it, then evaluate it.
                        runs = runs)

        cleanup_strategies( experiment = "PostShielded", model = "BB__Shielded.xml")