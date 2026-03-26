# --- simulation_engine.R ---

#' Predict Expected Total Using Trained Weights
#' @param model_params List containing 'weights' and 'bias' from train_model
#' @param features Vector [Team_RR, Team_WR, Venue_Index]
predict_expected_runs = function(model_params, features) {
  # Ensure features is a 1-row matrix for the %*% operator
  f_matrix = matrix(features, nrow = 1)
  prediction = (f_matrix %*% model_params$weights) + model_params$bias
  return(as.numeric(prediction))
}

#' Monte Carlo Match Simulator
#' @param team1_stats Vector [RR, WR, VenueIndex]
#' @param team2_stats Vector [RR, WR, VenueIndex]
#' @param model_params The weights learned via Gradient Descent
#' @param overs Total overs for the match (default 20)
#' @param iterations Number of matches to simulate (default 10000)
simulate_match = function(team1_stats, team2_stats, model_params, overs = 20, iterations = 10000) {
  # 1. Get the 'Ideal' total from Linear Model
  exp_total1 = predict_expected_runs(model_params, team1_stats)
  exp_total2 = predict_expected_runs(model_params, team2_stats)
  
  team1_wins = 0
  
  for (i in 1:iterations) {
    # 2. Simulate Wickets for this specific match (Binomial)
    # p increases slightly if the team is 'weaker' (lower Win Rate)
    p1 = 0.3 + (1 - team1_stats[2]) * 0.2 
    p2 = 0.3 + (1 - team2_stats[2]) * 0.2
    
    wickets1 = rbinom(1, 10, p1)
    wickets2 = rbinom(1, 10, p2)
    
    # 3. Apply Penalty: Each wicket reduces the expected total by 5%
    adj_total1 = exp_total1 * (1 - (wickets1 * 0.05))
    adj_total2 = exp_total2 * (1 - (wickets2 * 0.05))
    
    # 4. Generate Poisson scores based on Adjusted Totals
    sim_score1 = rpois(1, max(0, adj_total1))
    sim_score2 = rpois(1, max(0, adj_total2))
    
    if (sim_score1 > sim_score2) team1_wins = team1_wins + 1
    else if (sim_score1 == sim_score2) team1_wins = team1_wins + 0.5
  }
  
  return(team1_wins / iterations)
}
