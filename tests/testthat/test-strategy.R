test_that("strategy returns valid output", {
  
  sim <- list(win_prob = 0.6, team_a_scores = 1:100, team_b_scores = 1:100)
  
  res <- apply_betting_strategy(sim, 2.0, 1000)
  
  expect_true(is.numeric(res$stake))
  expect_false(is.na(res$stake))
  expect_true(res$stake >= 0)
})

test_that("martingale increases after loss", {
  
  sim <- list(win_prob = 0.5, team_a_scores = 1:100, team_b_scores = 1:100)
  
  res <- apply_betting_strategy(
    sim, 2.0, 1000,
    method = "martingale",
    last_outcome = "loss",
    prev_stake = 10
  )
  
  expect_true(res$stake >= 20)
})

test_that("different strategies produce different outcomes", {
  
  set.seed(42)
  
  dummy_match <- list(
    team_a_stats = c(8, 0.05, 1),
    team_b_stats = c(7, 0.06, 1),
    market_odds = 2.0
  )
  
  matches <- replicate(50, dummy_match, simplify = FALSE)
  
  params <- list(
    scale_mean = c(8, 0.05, 1),
    bias = 5.050939,
    weights = c(0.5, 0.2, 0.3)
  )
  
  kelly <- simulate_bankroll(matches, params, strategy_method = "kelly")
  flat  <- simulate_bankroll(matches, params, strategy_method = "flat")
  
  expect_false(all(kelly == flat))
})
