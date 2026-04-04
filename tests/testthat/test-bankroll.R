test_that("simulate_bankroll runs correctly", {
  
  set.seed(42)
  
  dummy_match = list(
    team_a_stats = c(8, 0.05, 1),
    team_b_stats = c(7, 0.06, 1),
    market_odds = 2.0
  )
  
  matches = replicate(50, dummy_match, simplify = FALSE)
  
  params = list(scale_mean = c(8, 0.05, 1), bias = 5.050939)
  
  path = simulate_bankroll(matches, params)
  
  expect_true(is.numeric(path))
  expect_equal(length(path), 51)
  expect_false(any(is.na(path)))
  expect_true(all(path >= 0))
})
