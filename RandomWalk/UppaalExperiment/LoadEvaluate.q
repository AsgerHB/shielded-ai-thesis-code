//Load a strategy for cost of death in {1000, 100, 10}, then evaluate it.

/* formula 1 */
strategy DeatCosts1000 = loadStrategy {} -> {x, t}  ("/home/asger/Documents/Files/AAU/10.Semester/Speciale/Speciale-Code/RandomWalk/UppaalExperiment/Results/DeathCosts1000.strategy.json")

/* formula 2 */
E[#<=30;1000] (max:total_cost) under DeatCosts1000

/* formula 3 */
E[#<=30;1000] (max:t>1) under DeatCosts1000

/* formula 4 */
E[#<=30;1000] (max:interventions) under DeatCosts1000

/* formula 5 */
strategy DeatCosts100 = loadStrategy {} -> {x, t}  ("/home/asger/Documents/Files/AAU/10.Semester/Speciale/Speciale-Code/RandomWalk/UppaalExperiment/Results/DeathCosts100.strategy.json")

/* formula 6 */
E[#<=30;1000] (max:total_cost) under DeatCosts100

/* formula 7 */
E[#<=30;1000] (max:t>1) under DeatCosts100

/* formula 8 */
E[#<=30;1000] (max:interventions) under DeatCosts100

/* formula 9 */
strategy DeatCosts10 = loadStrategy {} -> {x, t}  ("/home/asger/Documents/Files/AAU/10.Semester/Speciale/Speciale-Code/RandomWalk/UppaalExperiment/Results/DeathCosts10.strategy.json")

/* formula 10 */
E[#<=30;1000] (max:total_cost) under DeatCosts10

/* formula 11 */
E[#<=30;1000] (max:t>1) under DeatCosts10

/* formula 12 */
E[#<=30;1000] (max:interventions) under DeatCosts10

