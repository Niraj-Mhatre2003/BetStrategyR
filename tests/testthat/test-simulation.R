test_that("simulate_match returns valid structure", {
  
  set.seed(42)
  
  params <- list(
    scale_mean = c(8, 0.05, 1),
    bias = 5.050939,
    weights = c(0.5, 0.2, 0.3)
  )
  
  res <- simulate_match(
    team_a_stats = c(8, 0.05, 1),
    team_b_stats = c(7, 0.06, 1),
    params = params,
    iterations = 100
  )
  
  expect_true(is.list(res))
  expect_true(res$win_prob >= 0 && res$win_prob <= 1)
  expect_equal(length(res$team_a_scores), 100)
  expect_equal(length(res$team_b_scores), 100)
  expect_false(any(is.na(res$team_a_scores)))
  expect_false(any(is.na(res$team_b_scores)))
})

test_that("scores are non-negative", {
  
  set.seed(42)
  
  params <- list(
    scale_mean = c(8, 0.05, 1),
    bias = 5.050939,
    weights = c(0.5, 0.2, 0.3)
  )
  
  res <- simulate_match(
    team_a_stats = c(8, 0.05, 1),
    team_b_stats = c(7, 0.06, 1),
    params = params,
    iterations = 100
  )
  
  expect_true(all(res$team_a_scores >= 0))
  expect_true(all(res$team_b_scores >= 0))
})
