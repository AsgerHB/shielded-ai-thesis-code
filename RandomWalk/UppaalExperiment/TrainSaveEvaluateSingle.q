// Train a single strategy, save it, then evaluate it.

/* formula 1 */
strategy PreShielded = minE (total_cost + (t>1)*1000) [#<=30] {} -> {x, t} : <> x>=1 or t>=1

/* formula 2 */
saveStrategy("/home/asger/Documents/Files/AAU/10.Semester/Speciale/Speciale-Code/RandomWalk/UppaalExperiment/Results/PreShielded.strategy.json", PreShielded)

/* formula 3 */
E[#<=30;1000] (max:total_cost) under PreShielded

/* formula 4 */
E[#<=30;100000] (max:t>1) under PreShielded

/* formula 5 */
E[#<=30;1000] (max:interventions) under PreShielded