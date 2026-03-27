library(testthat)

test_that("Kelly Criterion calculates correct stakes", {
  # Scenario: 60% win prob, 2.0 odds ($1 profit on $1 bet)
  # Formula: ((1 * 0.6) - 0.4) / 1 = 0.2 (20% of bankroll)
  expect_equal(calculate_kelly_stake(0.6, 2.0, 1000, fraction = 1), 200)
  
  # Scenario: No edge (Prob matches Odds) -> Stake should be 0
  expect_equal(calculate_kelly_stake(0.5, 2.0, 1000), 0)
  
  # Scenario: Negative edge (Prob lower than Odds) -> Stake should be 0
  expect_equal(calculate_kelly_stake(0.4, 2.0, 1000), 0)
})

test_that("Strategy logic returns valid list structure", {
  sim_mock = list(win_prob = 0.55)
  result = apply_betting_strategy(sim_mock, 1.90, 1000, method = "kelly")
  
  expect_type(result, "list")
  expect_true("stake" %in% names(result))
  expect_true("prob" %in% names(result))
})