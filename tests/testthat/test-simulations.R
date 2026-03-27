test_that("Simulation produces valid probabilities", {
  # 1. Load actual params if available, or mock them properly
  if(file.exists("pretrained_bet_model.rds")) {
    params = readRDS("pretrained_bet_model.rds")
  } else {
    # MOCK: weights MUST be a matrix for %*% to work
    params = list(
      weights = matrix(c(0.5, -0.2, 0.1), ncol = 1), 
      scale_mean = c(8.5, 0.05, 1.0), 
      scale_std = c(1.2, 0.01, 0.1)
    )
  }
  
  t1 = c(8.5, 0.05, 1.0)
  t2 = c(7.0, 0.08, 1.0)
  
  # Run simulation
  res = simulate_match(t1, t2, params, iterations = 100)
  
  expect_gte(res$win_prob, 0)
  expect_lte(res$win_prob, 1)
})