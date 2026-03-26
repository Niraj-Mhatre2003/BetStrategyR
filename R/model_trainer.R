# --- model_trainer.R ---

#' Gradient Descent Optimizer--------------------------------------------------------------------
train_model = function(X, Y, learning_rate = 0.0001, iterations = 2000) {
  
  # Remove rows with NAs to prevent matrix multiplication failure
  keep_idx = complete.cases(X) & !is.na(Y)
  X = X[keep_idx, , drop = FALSE]
  Y = Y[keep_idx]
  
  num_features = ncol(X)
  weights = runif(num_features, -0.1, 0.1)
  bias = 0
  n = length(Y)
  
  for (i in 1:iterations) {
    # Prediction (Linear Combination)
    predictions = (X %*% weights) + bias
    
    # Error Calculation
    errors = predictions - Y
    
    # Gradient Calculation
    dw = (1/n) * (t(X) %*% errors)
    db = (1/n) * sum(errors)
    
    # Parameter Update
    weights = weights - (learning_rate * dw)
    bias = bias - (learning_rate * db)
    
    if (i %% 500 == 0) {
      mse = mean(errors^2)
      cat("Step:", i, " - MSE:", mse, "\n")
    }
  }
  
  return(list(weights = weights, bias = bias))
}

#' Optimized Prediction-------------------------------------------------------------------
predict_expected_runs = function(model_params, features) {
  # 'features' must be a vector or matrix matching the training columns
  prediction = (features %*% model_params$weights) + model_params$bias
  return(as.numeric(prediction))
}

#investor part--------------------------------------------------------------------------------
invest_advisor = function(team_stats1, team_stats2, market_odds, bankroll, model_params) {
  # 1. Get Model Probability
  our_prob = simulate_match(team_stats1, team_stats2, model_params)
  
  # 2. Get Market Probability (De-vighed)
  market_prob = 1 / market_odds
  
  # 3. Calculate Edge
  edge = our_prob - market_prob
  
  # 4. Kelly Criterion (Half-Kelly for safety)
  # b = decimal odds - 1
  b = market_odds - 1
  kelly_f = ((b * our_prob) - (1 - our_prob)) / b
  suggested_stake = max(0, (kelly_f * 0.5) * bankroll)
  
  # 5. Summary Output
  cat("\n--- STRATEGIC INVESTMENT ADVICE ---\n")
  cat("Confidence Score: ", round(our_prob * 100, 2), "%\n")
  cat("Market Implied:  ", round(market_prob * 100, 2), "%\n")
  cat("Calculated Edge: ", round(edge * 100, 2), "%\n")
  
  if(edge > 0.03) {
    cat("DECISION:        INVEST\n")
    cat("SUGGESTED STAKE: $", round(suggested_stake, 2), "(", round((suggested_stake/bankroll)*100, 1), "% of Bankroll)\n")
  } else {
    cat("DECISION:        PASS (Insufficient Edge)\n")
  }
}