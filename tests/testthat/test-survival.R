test_that("stop loss triggers", {
  
  set.seed(42)
  
  dummy_match <- list(
    team_a_stats = c(1, 0.5, 1),   # very weak
    team_b_stats = c(20, 0.01, 1), # very strong
    market_odds = 1.2              # low payout → bad bets
  )
  
  matches <- replicate(300, dummy_match, simplify = FALSE)
  
  params <- list(
    scale_mean = c(8, 0.05, 1),
    bias = 5.050939,
    weights = c(0.5, 0.2, 0.3)
  )
  
  path <- simulate_bankroll(matches, params, stop_loss_pct = 0.2, strategy_method = "flat")
  
  stop_loss_value <- 1000 * 0.8
  
  expect_true(min(path) <= stop_loss_value)
})
