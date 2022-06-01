//This file was generated from (Academic) UPPAAL 4.1.20-stratego-10-beta2 (rev. FC359288E59BAC4F), May 2022

/*
Layabout Queries:
*/
//NO_QUERY

/*

*/
E[<=120;1000] (max:LearnerPlayer.fired + number_deaths*1000)

/*

*/
Pr[<=120] (<> number_deaths > 0)

/*

*/
E[<=120;1000] (max:interventions)

/*

*/
//NO_QUERY

/*
Training Queries:
*/
//NO_QUERY

/*

*/
strategy DeathCosts1000 = minE (LearnerPlayer.fired + number_deaths*1000 ) [<=120] {} -> {p, v}: <> time >= 120

/*

*/
saveStrategy("/home/asger/Documents/Files/AAU/10.Semester/Speciale/Speciale-Code/BouncingBall/UppaalExperiment/Strategies/DeathCosts1000.strategy.json", DeathCosts1000)

/*

*/
E[<=120;1000] (max:LearnerPlayer.fired) under DeathCosts1000

/*

*/
Pr[<=120] (<> number_deaths > 0) under DeathCosts1000

/*

*/
E[<=120;1000] (max:interventions) under DeathCosts1000

/*

*/
//NO_QUERY

/*

*/
strategy DeathCosts100 = minE (LearnerPlayer.fired + number_deaths*100 ) [<=120] {} -> {p, v}: <> time >= 120

/*

*/
saveStrategy("/home/asger/Documents/Files/AAU/10.Semester/Speciale/Speciale-Code/BouncingBall/UppaalExperiment/Strategies/DeathCosts100.strategy.json", DeathCosts100)

/*

*/
E[<=120;1000] (max:LearnerPlayer.fired) under DeathCosts100

/*

*/
Pr[<=120] (<> number_deaths > 0) under DeathCosts100

/*

*/
E[<=120;1000] (max:interventions) under DeathCosts100

/*

*/
//NO_QUERY

/*

*/
strategy DeathCosts10 = minE (LearnerPlayer.fired + number_deaths*10 ) [<=120] {} -> {p, v}: <> time >= 120

/*

*/
saveStrategy("/home/asger/Documents/Files/AAU/10.Semester/Speciale/Speciale-Code/BouncingBall/UppaalExperiment/Strategies/DeathCosts10.strategy.json", DeathCosts10)

/*

*/
E[<=120;1000] (max:LearnerPlayer.fired) under DeathCosts10

/*

*/
Pr[<=120] (<> number_deaths > 0) under DeathCosts10

/*

*/
E[<=120;1000] (max:interventions) under DeathCosts10

/*

*/
//NO_QUERY

/*

*/
strategy DeathCosts1000 = loadStrategy {} -> {p, v} ("/home/asger/Documents/Files/AAU/10.Semester/Speciale/Speciale-Code/BouncingBall/UppaalExperiment/Strategies/DeathCosts1000.strategy.json")
