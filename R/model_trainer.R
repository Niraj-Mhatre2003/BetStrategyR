# --- model_trainer.R ---

#' Gradient Descent Optimizer--------------------------------------------------------------------
#' Gradient Descent Optimizer for Cricket Run Prediction
#' 
#' Internal function used to train the linear regression model using 
#' batch gradient descent. This minimizes the Mean Squared Error (MSE) 
#' to find optimal weights for RR, WR, and Venue indices.
#' 
#' @param X Matrix of features (RR, WR, Venue Index).
#' @param Y Vector of actual runs scored.
#' @param learning_rate Speed of convergence (default 0.0001).
#' @param iterations Number of gradient steps (default 2000).
#' @return A list containing the optimized weights and bias.
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
#' Optimized Prediction for Expected Runs
#' 
#' Internal helper that performs matrix multiplication to predict runs 
#' based on team features and model parameters.
#' 
#' @param model_params List containing weights and bias.
#' @param features Numeric vector of team stats.
#' @return A numeric value representing predicted runs.
predict_expected_runs = function(model_params, features) {
  # Force input to 1-row matrix (1x3)
  x = matrix(as.numeric(features), nrow = 1)
  
  # Force weights to column matrix (3x1)
  w = as.matrix(model_params$weights)
  
  # (1x3) %*% (3x1) + scalar
  prediction = (x %*% w) + (model_params$bias %||% 0)
  
  return(as.numeric(prediction))
}