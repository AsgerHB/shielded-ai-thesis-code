# Experimental results for the bouncing ball

If you are reading this much later, good luck. UPPAAL doesn't really support relative file paths in a sane way, so enjoy changing them all manually. 

Sorry for the mess. Everything is tied together in `RunExperiment.py`. Run from inside this directory. It spits out a file `Results.csv` and a folder `Results`. 

The folder structure of `Results` should be such that the root contains folders corresponding to a model. (One of {Layabout, No Shield, Pre-shielded, Post-shielded}) For the Layabout, the raw query results of running the thing is directly in its folder, since no learning occurs.

For the other models, there are multiple folders depending on the number of "Runs" (learning iterations?) the strategies were trained with. Strategies are saved for No Shield and Post-shielded. The Pre-shielded model re-uses the strategies trained for the No Shield model, so that folder only contains the raw query results. 

The raw query results are the query files used (see below) followed by the result of running them together with whatever xml file was chosen. Which queries are run with which models is stated below.

There's a lot of duplicate files here. I don't have any other tools to control some of the parameters of the experiment, so the UPPAAL model has been copied a bunch of times with its parameters changed, and multiple query-files have been written to support the different variants. 

Some of the query files have different costs of dying, while others do not. This is because if the model is shielded, death should not occur and  therefore it doesn't make sense to run the experiments a bunch more times. 

BB.xml is the UPPAAL STRATEGO base file which I'll make changes to. BB.q is a scratchpad query file with  the same deal. 

The other files are respectively:

 - **BB__Unhielded.xml** : shield_enabled = false; layabout = false;
 - **BB__Shielded.xml** : shield_enabled = true; layabout = false;
 - **BB__Layabout.xml** : shield_enabled = true; layabout = true;
 - **TrainSaveEvaluate.q** : For cost of death in {1000, 100, 10}, train a strategy, save it, then evaluate it.
 - **TrainSaveEvaluateSingle.q** : Train a single strategy, save it, then evaluate it.
 - **NoStrategyEvaluate.q** : Evaluate the queries with no strategy applied.
 - **LoadEvaluate.q** : Load a strategy for cost of death in {1000, 100, 10}, then evaluate it.

The following experiments are built using these files:

 - **Layabout**  : "BB__ShieldedLayabout.xml",  "NoStrategyEvaluate.q"
 - **NoShield**  : "BB__Unshielded.xml",  "TrainSaveEvaluate.q"
 - **PreShielded**  : "BB__Shielded.xml",  "LoadEvaluate.q"
 - **PostShielded**  : "BB__Shielded.xml",  "TrainSaveEvaluateSingle.q"