# --- model_trainer.R ---

#' Gradient Descent Optimizer
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
    # 1. Prediction (Linear Combination)
    predictions = (X %*% weights) + bias
    
    # 2. Error Calculation
    errors = predictions - Y
    
    # 3. Gradient Calculation
    dw = (1/n) * (t(X) %*% errors)
    db = (1/n) * sum(errors)
    
    # 4. Parameter Update
    weights = weights - (learning_rate * dw)
    bias = bias - (learning_rate * db)
    
    if (i %% 500 == 0) {
      mse = mean(errors^2)
      cat("Step:", i, " - MSE:", mse, "\n")
    }
  }
  
  return(list(weights = weights, bias = bias))
}

#' Optimized Prediction
predict_expected_runs = function(model_params, features) {
  # 'features' must be a vector or matrix matching the training columns
  prediction = (features %*% model_params$weights) + model_params$bias
  return(as.numeric(prediction))
}