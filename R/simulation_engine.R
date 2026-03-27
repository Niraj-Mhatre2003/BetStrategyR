# --- R/simulation_engine.R ---
#' Simulate T20 Cricket Match
#' 
#' Performs a Monte Carlo simulation of a T20 match between two teams based on 
#' Poisson-distributed run scoring and Binomial-distributed wicket events.
#' @param team1_stats Numeric vector of scaled stats for Team 1 (RR, WR, VenueIdx).
#' @param team2_stats Numeric vector of scaled stats for Team 2 (RR, WR, VenueIdx).
#' @param model_params A list containing the 'intercept' and 'weights' from the trained model.
#' @param overs Number of overs per innings (default 20).
#' @param iterations Number of simulation trials (default 10,000 for stability).
#' @return A list containing the win probability for Team 1 and vectors of all simulated scores.
#' @export
simulate_match = function(team1_stats, team2_stats, model_params, overs = 20, iterations = 10000) {
  
  exp_total1 = predict_expected_runs(model_params, team1_stats)
  exp_total2 = predict_expected_runs(model_params, team2_stats)
  
  scores_a = numeric(iterations)
  scores_b = numeric(iterations)
  team1_wins = 0
  
  for (i in 1:iterations) {
    # SAFETY FIX: probabilities between 0.01 and 0.99
    # This prevents rbinom from producing NAs when stats are extreme
    raw_p1 = 0.3 + (1 - team1_stats[2]) * 0.2 
    raw_p2 = 0.3 + (1 - team2_stats[2]) * 0.2
    
    p1 = max(0.01, min(0.99, raw_p1))
    p2 = max(0.01, min(0.99, raw_p2))
    
    wickets1 = rbinom(1, 10, p1)
    wickets2 = rbinom(1, 10, p2)
    
    # 3. Apply Penalty
    adj_total1 = exp_total1 * (1 - (wickets1 * 0.05))
    adj_total2 = exp_total2 * (1 - (wickets2 * 0.05))
    
    # SAFETY FIX: Ensure Poisson lambda is at least 0.01
    # rpois(1, 0) or negative numbers produce NAs
    sim_score1 = rpois(1, max(0.01, adj_total1))
    sim_score2 = rpois(1, max(0.01, adj_total2))
    
    scores_a[i] = sim_score1
    scores_b[i] = sim_score2
    
    # 5. Comparison 
    if (sim_score1 > sim_score2) {
      team1_wins = team1_wins + 1
    } else if (sim_score1 == sim_score2) {
      team1_wins = team1_wins + 0.5
    }
  }
  
  return(list(
    win_prob = team1_wins / iterations,
    team_a_scores = scores_a,
    team_b_scores = scores_b
  ))
}