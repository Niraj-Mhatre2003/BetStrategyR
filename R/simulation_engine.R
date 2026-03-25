simulate_match = function(team1_features, team2_features, model_params, iterations = 10000) {
  
  # 1. Get the "Smart" Expected Total for both teams based on Pre-training
  exp_score1 = predict_expected_runs(model_params, team1_features)
  exp_score2 = predict_expected_runs(model_params, team2_features)
  
  # 2. Convert Expected Total back to a per-ball probability
  # (Assuming 20 overs for this example)
  balls = 120 
  lambda1 = exp_score1 / balls
  lambda2 = exp_score2 / balls
  
  team1_wins = 0
  
  # 3. Monte Carlo Loop
  for (i in 1:iterations) {
    # Generate random scores based on the Poisson distribution of the predicted rate
    # rpois(1, lambda) gives us a random ball-by-ball result
    sim_score1 = sum(rpois(balls, lambda1))
    sim_score2 = sum(rpois(balls, lambda2))
    
    if (sim_score1 > sim_score2) {
      team1_wins = team1_wins + 1
    }
  }
  
  # Return the win probability for Team 1
  return(team1_wins / iterations)
}
##################################################################
# --- simulation_engine.R ---

#' Predict Expected Total Using Trained Weights
#' @param features Vector [Team_RR, Team_WR, Venue_Index]
#' @param model_params List containing 'weights' and 'bias' from train_model
predict_expected_runs = function(model_params, features) {
  # Perform matrix multiplication for the prediction
  # Ensuring features is treated as a matrix for %*%
  f_matrix = matrix(features, nrow = 1)
  prediction = (f_matrix %*% model_params$weights) + model_params$bias
  return(as.numeric(prediction))
}

#' Monte Carlo Match Simulator
#' @param team1_stats Vector [RR, WR, VenueIndex]
#' @param team2_stats Vector [RR, WR, VenueIndex]
#' @param model_params The weights learned via Gradient Descent
#' @param overs Total overs for the match (default 20 for T20)
#' @param iterations Number of matches to simulate (default 10000)
simulate_match = function(team1_stats, team2_stats, model_params, overs = 20, iterations = 10000) {
  
  # 1. Get Predicted "Smart" Totals from the Pre-trained model
  exp_total1 = predict_expected_runs(model_params, team1_stats)
  exp_total2 = predict_expected_runs(model_params, team2_stats)
  
  # 2. Convert to ball-by-ball Lambda (Poisson Mean)
  total_balls = overs * 6
  lambda1 = exp_total1 / total_balls
  lambda2 = exp_total2 / total_balls
  
  team1_wins = 0
  
  # 3. Monte Carlo Simulation Loop
  for (i in 1:iterations) {
    # Generate scores ball-by-ball to account for variance
    # rpois generates random counts based on the predicted average
    sim_score1 = sum(rpois(total_balls, lambda1))
    sim_score2 = sum(rpois(total_balls, lambda2))
    
    # Check for winner
    if (sim_score1 > sim_score2) {
      team1_wins = team1_wins + 1
    } else if (sim_score1 == sim_score2) {
      # Handle ties (0.5 win)
      team1_wins = team1_wins + 0.5
    }
  }
  
  # Return the probability of Team 1 winning
  win_prob = team1_wins / iterations
  return(win_prob)
}
