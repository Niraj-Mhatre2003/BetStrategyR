# --- simulation_engine.R ---

#' Predict Expected Total Using Trained Weights
#' @param model_params List containing 'weights' and 'bias' from train_model
#' @param features Vector [Team_RR, Team_WR, Venue_Index]
predict_expected_runs = function(model_params, features) {
  # Convert vector to 1-row matrix to ensure %*% works correctly
  f_matrix = matrix(features, nrow = 1)
  
  # Linear combination: Y = XW + b
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
  
  # Get Predicted Totals from the trained model
  exp_total1 = predict_expected_runs(model_params, team1_stats)
  exp_total2 = predict_expected_runs(model_params, team2_stats)
  
  # Convert to ball-by-ball Lambda (Poisson Mean)
  # Safety: Ensure lambda isn't negative
  total_balls = overs * 6
  lambda1 = max(0, exp_total1 / total_balls)
  lambda2 = max(0, exp_total2 / total_balls)
  
  team1_wins = 0
  
  # Monte Carlo Simulation Loop
  for (i in 1:iterations) {
    # rpois generates random counts based on the predicted average
    sim_score1 = sum(rpois(total_balls, lambda1))
    sim_score2 = sum(rpois(total_balls, lambda2))
    
    #  Scoring Logic
    if (sim_score1 > sim_score2) {
      team1_wins = team1_wins + 1
    } else if (sim_score1 == sim_score2) {
      # Handle ties by splitting the win (standard for win probability)
      team1_wins = team1_wins + 0.5
    }
  }
  
  # Return the probability of Team 1 winning
  return(team1_wins / iterations)
}

