// Train a single strategy, save it, then evaluate it.

/* formula 1 */
strategy PreShielded = minE (LearnerPlayer.fired + number_deaths*1000 ) [<=120] {} -> {p, v}: <> time >= 120

/* formula 2 */
saveStrategy("/home/asger/Documents/Files/AAU/10.Semester/Speciale/Speciale-Code/BouncingBall/UppaalExperiment/Results/PreShielded.strategy.json", PreShielded)

/* formula 3 */
E[<=120] (max:LearnerPlayer.fired) under PreShielded

/* formula 4 */
E[<=120] (max:number_deaths) under PreShielded

/* formula 5 */
E[<=120] (max:interventions) under PreShielded