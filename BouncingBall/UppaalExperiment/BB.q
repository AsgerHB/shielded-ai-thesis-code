//This file was generated from (Academic) UPPAAL 4.1.20-stratego-10-beta2 (rev. FC359288E59BAC4F), May 2022

/*
Layabout Queries:
*/
//NO_QUERY

/*

*/
E[<=120] (max:LearnerPlayer.fired + number_deaths*1000)

/*

*/
Pr[<=120] (<> number_deaths > 0)

/*

*/
E[<=120] (max:interventions)

/*

*/
//NO_QUERY

/*
Training Queries:
*/
//NO_QUERY

/*

*/
strategy HitWell1000 = minE (LearnerPlayer.fired + number_deaths*1000 ) [<=120] {} -> {p, v}: <> time >= 120

/*

*/
saveStrategy("/home/asger/Documents/Files/AAU/10.Semester/Speciale/Speciale-Code/BouncingBall/UppaalExperiment/Strategies/HitWell1000.strategy.json", HitWell1000)

/*

*/
E[<=120] (max:LearnerPlayer.fired) under HitWell1000

/*

*/
Pr[<=120] (<> number_deaths > 0) under HitWell1000

/*

*/
E[<=120] (max:interventions) under HitWell1000

/*

*/
//NO_QUERY

/*

*/
strategy HitWell100 = minE (LearnerPlayer.fired + number_deaths*100 ) [<=120] {} -> {p, v}: <> time >= 120

/*

*/
saveStrategy("/home/asger/Documents/Files/AAU/10.Semester/Speciale/Speciale-Code/BouncingBall/UppaalExperiment/Strategies/HitWell100.strategy.json", HitWell100)

/*

*/
E[<=120] (max:LearnerPlayer.fired) under HitWell100

/*

*/
Pr[<=120] (<> number_deaths > 0) under HitWell100

/*

*/
E[<=120] (max:interventions) under HitWell100
//NO_QUERY

/*

*/
strategy HitWell10 = minE (LearnerPlayer.fired + number_deaths*10 ) [<=120] {} -> {p, v}: <> time >= 120

/*

*/
saveStrategy("/home/asger/Documents/Files/AAU/10.Semester/Speciale/Speciale-Code/BouncingBall/UppaalExperiment/Strategies/HitWell10.strategy.json", HitWell10)

/*

*/
E[<=120] (max:LearnerPlayer.fired) under HitWell10

/*

*/
Pr[<=120] (<> number_deaths > 0) under HitWell10

/*

*/
E[<=120] (max:interventions) under HitWell10

/*

*/
//NO_QUERY

/*

*/
strategy HitWell1000 = loadStrategy {} -> {p, v} ("/home/asger/Documents/Files/AAU/10.Semester/Speciale/Speciale-Code/BouncingBall/UppaalExperiment/Strategies/HitWell1000.strategy.json")
